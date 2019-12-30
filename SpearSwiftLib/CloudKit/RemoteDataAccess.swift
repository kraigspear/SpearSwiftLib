//
//  RemoteDataAccess.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/25/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import CloudKit
import Combine
import Foundation
import os.log


/// A RemoteRecord
public protocol RemoteRecordProtocol {
	/// ID of this record
	var id: String { get }
	/// Provides the value of a string field, or nil if it doesn't exist
	/// - Parameter forKey: Key of the field to return a string for
	/// - Returns: Value or nil
	func string(forKey: String) -> String?
}

/// A remote record backed by a cloudkit CKRecord
struct RemoteRecordCloudKit: RemoteRecordProtocol {
	/// CKRecord providing the record information
	private let record: CKRecord
	
	/// Initialize a new instance with a `CKRecord`
	/// - Parameter record: Record providing data for this `RemoteRecordProtocol`
	init(_ record: CKRecord) {
		self.record = record
	}
	
	/// ID of this record
	public var id: String { record.recordID.recordName }
	
	/// Provides the value of a string field, or nil if it doesn't exist
	/// - Parameter forKey: Key of the field to return a string for
	/// - Returns: Value or nil
	public func string(forKey: String) -> String? {
		guard let recordValue = record[forKey] else { return nil }
		return recordValue as? String
	}
}

/// Access to remote data
/// Abstract out CloudKit to allow testability
/// This could be backed by somthing other than CloudKit
public protocol RemoteDataAccessible {
	/// Query for a record matching the given predicate
	/// - Parameters:
	///   - predicate: Predicate of the record to find
	/// - recordType: The type of record (tablename)
	func query(_ predicate: NSPredicate,
	           recordType: String) -> AnyPublisher<RemoteRecordProtocol?, Error>
	
	/// Subscribe to changes on the remote server
	/// - Parameters:
	/// - predicate: Predicate matching record that we want to save
	/// - recordType: The type of record (tablename)
	/// - returns: Publisher with the ID of the subscription or error
	func subscribeToUpdates(_ predicate: NSPredicate, recordType: String) -> AnyPublisher<String, Error>
}

public final class RemoteDataAccess: RemoteDataAccessible {
	private let log = Log.remoteData
	
	public init() {}
	
	private func queryOnCloudKit(_ predicate: NSPredicate,
	                             recordType: String) -> AnyPublisher<CKRecord?, Error> {
		os_log("Running query: %s recordType: %s",
		       log: log,
		       type: .info,
		       predicate.description,
		       recordType)
		
		return Future<CKRecord?, Error> { promise in
			let publicDb = CKContainer.default().publicCloudDatabase
			let query = CKQuery(recordType: recordType, predicate: predicate)
			
			publicDb.perform(query, inZoneWith: nil) { records, error in
				if let error = error {
					os_log("Error getting quering key %{public}s",
					       log: self.log,
					       type: .error,
					       error.localizedDescription)
					
					promise(.failure(error))
					return
				}
				
				guard let record = records?.first else {
					os_log("Record not found",
					       log: self.log,
					       type: .info)
					
					promise(.success(nil))
					return
				}
				
				promise(.success(record))
			}
		}.eraseToAnyPublisher()
	}
	
	public func query(_ predicate: NSPredicate,
	                  recordType: String) -> AnyPublisher<RemoteRecordProtocol?, Error> {
		return queryOnCloudKit(predicate, recordType: recordType)
			.map { record -> RemoteRecordProtocol? in
				if let record = record {
					return RemoteRecordCloudKit(record)
				} else {
					return nil
				}
			}.eraseToAnyPublisher()
	}
	
	// MARK: - Subscriptions
	
	public func subscribeToUpdates(_ predicate: NSPredicate, recordType: String) -> AnyPublisher<String, Error> {
		return query(predicate, recordType: recordType)
			.compactMap { $0?.id }
			.map { recordId -> CKQuerySubscription in
				let subscriptionPredicate = NSPredicate(format: "recordID = %@", [recordId])
				return CKQuerySubscription(recordType: recordType, predicate: subscriptionPredicate)
			}.flatMap { subscription -> AnyPublisher<CKSubscription, Error> in
				self.saveSubscription(subscription)
			}.map { savedSubscription in savedSubscription.subscriptionID }
			.eraseToAnyPublisher()
	}
	
	private func saveSubscription(_ subscription: CKSubscription) -> AnyPublisher<CKSubscription, Error> {
		return Future<CKSubscription, Error> { promise in
			
			let publicDb = CKContainer.default().publicCloudDatabase
			publicDb.save(subscription) { savedSubscription, error in
				
				if let error = error {
					promise(.failure(error))
					return
				}
				
				if let savedSubscription = savedSubscription {
					promise(.success(savedSubscription))
				} else {
					fatalError("No error, no subscription")
				}
			}
		}.eraseToAnyPublisher()
	}
}
