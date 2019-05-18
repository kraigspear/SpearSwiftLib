//
//  TableSync.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/17/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import CloudKit
import Foundation
import SwiftyBeaver

public enum SyncError: Error {
    case cloudKitNotEnabled
    case recordZoneFailed
    case recordZoneCreateFailed
    case cloudKitSaveFailed
    case cloudKitFetchFailed
    case unexpectedError(error: Error)
}

public typealias SyncResult = Result<Void, SyncError>
public typealias SyncCompleted = (SyncResult) -> Void

private class _AnyLocalSyncingBase<SyncRecordType>: LocalSyncing {
    init() {
        guard type(of: self) != _AnyLocalSyncingBase.self else {
            fatalError("_AnyLocalSyncing<SyncRecordType> can't be created, create a subclass")
        }
    }

    var syncRecords: [SyncRecordType] {
        fatalError("Override in child class")
    }

    func updateLocalRecordsAsBeingSynched(fromCloudKit _: [CKRecord]) {
        fatalError("Override in child class")
    }

    func deleteLocalRecords(_: [CKRecord.ID]) {
        fatalError("Override in child class")
    }

    func deleteAll() {
        fatalError("Override in child class")
    }

    func saveCloudKitRecordsLocally(remoteRecordsUpdated _: [CKRecord], remoteRecordsDeleted _: [CKRecord.ID]) {
        fatalError("Override in child class")
    }
}

private final class _AnyLocalSyncingBox<Concrete: LocalSyncing>: _AnyLocalSyncingBase<Concrete.SyncRecordType> {
    var concrete: Concrete
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }

    override var syncRecords: [Concrete.SyncRecordType] {
        return self.concrete.syncRecords
    }

    override func updateLocalRecordsAsBeingSynched(fromCloudKit records: [CKRecord]) {
        concrete.updateLocalRecordsAsBeingSynched(fromCloudKit: records)
    }

    override func deleteLocalRecords(_ recordIDs: [CKRecord.ID]) {
        concrete.deleteLocalRecords(recordIDs)
    }

    override func deleteAll() {
        concrete.deleteAll()
    }

    override func saveCloudKitRecordsLocally(remoteRecordsUpdated ckRecords: [CKRecord], remoteRecordsDeleted: [CKRecord.ID]) {
        concrete.saveCloudKitRecordsLocally(remoteRecordsUpdated: ckRecords,
                                            remoteRecordsDeleted: remoteRecordsDeleted)
    }
}

public final class AnyLocalSyncing<SyncRecordType>: LocalSyncing {
    private let box: _AnyLocalSyncingBase<SyncRecordType>

    public init<Concrete: LocalSyncing>(_ concrete: Concrete) where Concrete.SyncRecordType == SyncRecordType {
        box = _AnyLocalSyncingBox(concrete)
    }

    public var syncRecords: [SyncRecordType] {
        return box.syncRecords
    }

    public func updateLocalRecordsAsBeingSynched(fromCloudKit records: [CKRecord]) {
        box.updateLocalRecordsAsBeingSynched(fromCloudKit: records)
    }

    public func deleteLocalRecords(_ recordIDs: [CKRecord.ID]) {
        box.deleteLocalRecords(recordIDs)
    }

    public func deleteAll() {
        box.deleteAll()
    }

    public func saveCloudKitRecordsLocally(remoteRecordsUpdated ckRecords: [CKRecord], remoteRecordsDeleted: [CKRecord.ID]) {
        box.saveCloudKitRecordsLocally(remoteRecordsUpdated: ckRecords,
                                       remoteRecordsDeleted: remoteRecordsDeleted)
    }
}

/**
 Local datastore capabibilites related to Syncing
 */
public protocol LocalSyncing {
    associatedtype SyncRecordType

    var syncRecords: [SyncRecordType] { get }

    /**
     Changes have been saved to CloudKit
     Mark the local records as being synched
     */
    func updateLocalRecordsAsBeingSynched(fromCloudKit records: [CKRecord])
    /**
     Delete all local records matching CKRecord.ID's
     - parameter recordIDs: ID's to deelte
     */
    func deleteLocalRecords(_ recordIDs: [CKRecord.ID])
    /**
     Delete all local data
     */
    func deleteAll()
    /**
     Save changes from CloudKit to the local DataStore
     - parameter remoteRecordsUpdated: Records with info that needs to be update
     - parameter remoteRecordsDeleted: Records that should be deleted
     */
    func saveCloudKitRecordsLocally(remoteRecordsUpdated ckRecords: [CKRecord],
                                    remoteRecordsDeleted: [CKRecord.ID])
}

public enum SyncDirection {
    case toCloudKit
    case fromCouldKit
    case both
}

/**
 Abstract base class to Sync to and from CloudKit
 */
open class TableSyncBase<SyncRecordType> {
    private let log = SwiftyBeaver.self

    private let localSync: AnyLocalSyncing<SyncRecordType>
    private let queue: OperationQueue

    public init(localSync: AnyLocalSyncing<SyncRecordType>) {
        self.localSync = localSync
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
    }

    lazy var toCloudKit: SyncToCloudKit<SyncRecordType> = {
        SyncToCloudKit<SyncRecordType>(tableSync: self,
                                       localSyncing: localSync)
    }()

    lazy var fromCloudKit: SyncFromCloudKit<SyncRecordType> = {
        SyncFromCloudKit(tableSync: self,
                         localSyncing: localSync,
                         changeTokens: changeTokens)
    }()

    private lazy var changeTokens: ChangeTokens = {
        ChangeTokens(recordChangeTokenKey: recordChangeTokenKey)
    }()

    private lazy var recordZone: RecordZone = {
        RecordZone(recordZoneId: recordZoneId,
                   changeTokens: changeTokens)
    }()

    // MARK: - Abstract

    open var recordsToSyncToCloudKit: [SyncRecordType] {
        fatalError("Implement in derived type")
    }

    open var ckRecordsToUpdate: [CKRecord] {
        fatalError("Implement in derived type")
    }

    open var ckRecordIdsToDelete: [CKRecord.ID] {
        fatalError("Implement in derived type")
    }

    open var recordZoneId: CKRecordZone.ID {
        fatalError("Implement in derived type")
    }

    /// Key for changes in this RecordZone
    open var recordChangeTokenKey: String {
        fatalError("Implement in derived type")
    }

    private final class SyncToOperation<SyncRecordType>: BaseOperation {
        private let log = SwiftyBeaver.self
        private let toCloudKit: SyncToCloudKit<SyncRecordType>

        private(set) var syncResult: SyncResult?

        init(toCloudKit: SyncToCloudKit<SyncRecordType>) {
            self.toCloudKit = toCloudKit
        }

        override func main() {
            log.info("SyncToOperation.main", context: SyncRecordType.self)

            guard isCancelled == false else {
                log.info("SyncToOperation was cancelled", context: SyncRecordType.self)
                done()
                return
            }

            log.info("Calling toCloudKit", context: SyncRecordType.self)
            toCloudKit.sync { [weak self] result in
                self?.log.info("toCloudKit completed", context: SyncRecordType.self)
                self?.syncResult = result
                self?.done()
            }
        }
    }

    private final class SyncFromOperation<SyncRecordType>: BaseOperation {
        private let log = SwiftyBeaver.self
        private let fromCloudKit: SyncFromCloudKit<SyncRecordType>

        private(set) var syncResult: SyncResult?

        var syncToOperation: SyncToOperation<SyncRecordType>? {
            didSet {
                if let syncToOperation = self.syncToOperation {
                    log.info("syncToOperation assigned", context: SyncRecordType.self)
                    addDependency(syncToOperation)
                }
            }
        }

        init(fromCloudKit: SyncFromCloudKit<SyncRecordType>) {
            self.fromCloudKit = fromCloudKit
        }

        override func main() {
            log.info("SyncFromOperation.main", context: SyncRecordType.self)

            guard isCancelled == false else {
                log.info("isCancelled", context: SyncRecordType.self)
                done()
                return
            }

            // If running with a syncToOperation, cancel if it didn't finish successfully
            if let syncToOperation = self.syncToOperation {
                log.debug("Had a SyncToOperation", context: SyncRecordType.self)
                if let syncToError = syncToOperation.error {
                    log.error("syncToOperation had error: \(syncToError)", context: SyncRecordType.self)
                    error = syncToError
                    done()
                    return
                }
            }

            fromCloudKit.sync { [weak self] result in
                self?.log.info("fromCloudKit sync complete", context: SyncRecordType.self)
                self?.syncResult = result
                self?.done()
            }
        }
    }

    /**
     Sync To/From/Both Cloudkit
     - parameter direction: The direction to sync
     - parameter completed: Called when completed with the result of the sync
     */
    public func sync(direction: SyncDirection,
                     completed: @escaping SyncCompleted) {
        log.info("sync direction: \(direction)", context: SyncRecordType.self)

        switch direction {
        case .fromCouldKit:

            let fromOperation = SyncFromOperation(fromCloudKit: fromCloudKit)

            fromOperation.completionBlock = { [weak self] in
                if let result = fromOperation.syncResult {
                    DispatchQueue.main.async {
                        completed(result)
                    }
                } else {
                    self?.log.error("complete without a result", context: SyncRecordType.self)
                    preconditionFailure("complete without a result")
                }
            }

            log.info("Adding from operation to queue", context: SyncRecordType.self)
            queue.addOperation(fromOperation)
        case .toCloudKit:

            let toOperation = SyncToOperation(toCloudKit: toCloudKit)

            toOperation.completionBlock = { [weak self] in
                self?.log.info("SyncToOperation: completed", context: SyncRecordType.self)

                if let result = toOperation.syncResult {
                    DispatchQueue.main.async {
                        completed(result)
                    }
                } else {
                    self?.log.error("complete without a result")
                    preconditionFailure("complete without a result")
                }
            }
            log.info("SyncToOperation adding operation", context: SyncRecordType.self)
            queue.addOperation(toOperation)
        case .both:

            log.info("Calling both from & to sync operations", context: SyncRecordType.self)
            let fromOperation = SyncFromOperation(fromCloudKit: fromCloudKit)
            let toOperation = SyncToOperation(toCloudKit: toCloudKit)

            fromOperation.syncToOperation = toOperation

            fromOperation.completionBlock = { [weak self] in
                self?.log.info("fromOperation completed", context: SyncRecordType.self)
            }

            toOperation.completionBlock = { [weak self] in
                self?.log.info("from and to operations complete", context: SyncRecordType.self)
                if let result = toOperation.syncResult {
                    DispatchQueue.main.async {
                        completed(result)
                    }
                } else {
                    self?.log.error("complete without a result", context: SyncRecordType.self)
                    preconditionFailure("complete without a result")
                }
            }

            log.info("Adding operations to queue: current count is: \(queue.operationCount)", context: SyncRecordType.self)

            if queue.operationCount > 0 {
                log.warning("Existing operations?")

                queue.operations.forEach {
                    log.warning("Operation still in queue: \($0)", context: SyncRecordType.self)
                }

                assertionFailure("Existing operations?")
            }

            queue.addOperations([fromOperation, toOperation], waitUntilFinished: false)
        }
    }

    public func syncToCloudKit(completed: @escaping SyncCompleted) {
        log.info("syncToCloudKit", context: SyncRecordType.self)
        toCloudKit.sync(completed: completed)
    }

    public func syncFromCloudKit(completed: @escaping SyncCompleted) {
        log.info("syncFromCloudKit", context: SyncRecordType.self)
        fromCloudKit.sync(completed: completed)
    }

    private final class CloudKitAvailable {
        static func check(completed: @escaping (Bool) -> Void) {
            CKContainer.default().accountStatus { status, error in

                if let error = error {
                    SwiftyBeaver.self.error("Error checking for cloudkit \(error)")
                    completed(false)
                } else {
                    switch status {
                    case .available:
                        SwiftyBeaver.self.debug("CloudKit is available")
                        completed(true)
                    default:
                        SwiftyBeaver.self.debug("CloudKit is NOT available")
                        completed(false)
                    }
                }
            }
        }
    }

    fileprivate final class ChangeTokens {
        private let log = SwiftyBeaver.self
        private let defaults = UserDefaults.standard

        private let zonesChangedInDatabaseKey = "databaseChangeKey"
        private let recordChangeTokenKey: String

        init(recordChangeTokenKey: String) {
            self.recordChangeTokenKey = recordChangeTokenKey
        }

        /// Token for changes in the database
        /// What RecordZones have changes since this token
        var zonesChangedInDatabaseToken: CKServerChangeToken? {
            get {
                guard let data = defaults.data(forKey: zonesChangedInDatabaseKey) else {
                    return nil
                }

                do {
                    return try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
                } catch {
                    assertionFailure("Can't unarchive recordChangeToken?")
                    return nil
                }
            }
            set {
                if let token = newValue {
                    let data = try! NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
                    defaults.set(data, forKey: zonesChangedInDatabaseKey)
                } else {
                    defaults.setValue(nil, forKey: zonesChangedInDatabaseKey)
                }
            }
        }

        var recordChangeToken: CKServerChangeToken? {
            get {
                log.debug("get recordChangeToken key: \(recordChangeTokenKey)")

                guard let data = defaults.data(forKey: recordChangeTokenKey) else {
                    log.debug("\(recordChangeTokenKey) is nil, returing nil")
                    return nil
                }

                do {
                    let changeToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
                    log.debug("Succesfully fetched recordChangeToken to \(recordChangeTokenKey)")
                    return changeToken
                } catch {
                    log.error("Can't unarchive recordChangeToken?: \(error)")
                    assertionFailure("Can't unarchive recordChangeToken?")
                    return nil
                }
            }
            set {
                if let token = newValue {
                    log.debug("set recordChangeToken key: \(recordChangeTokenKey)")
                    let data = try! NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
                    defaults.set(data, forKey: recordChangeTokenKey)
                } else {
                    log.debug("set recordChangeToken key: \(recordChangeTokenKey) to nil")
                    defaults.setValue(nil, forKey: recordChangeTokenKey)
                }
            }
        }

        func clear() {
            recordChangeToken = nil
            zonesChangedInDatabaseToken = nil
        }
    }

    final class SyncToCloudKit<SyncRecordType> {
        private let log = SwiftyBeaver.self
        private weak var tableSync: TableSyncBase<SyncRecordType>?
        private let localSyncing: AnyLocalSyncing<SyncRecordType>

        init(tableSync: TableSyncBase<SyncRecordType>,
             localSyncing: AnyLocalSyncing<SyncRecordType>) {
            self.tableSync = tableSync
            self.localSyncing = localSyncing
        }

        public func sync(completed: @escaping SyncCompleted) {
            log.info("SyncToCloudKit starting")

            CloudKitAvailable.check { [weak self] isAvailable in

                guard let self = self else { return }

                guard isAvailable else {
                    self.log.info("CloudKit is not enabled")
                    completed(SyncResult.failure(.cloudKitNotEnabled))
                    return
                }

                self.log.info("CloudKit is available")
                self.syncUpCloudKitAvailable(completed: completed)
            }
        }

        /**
         Sync up after it's been confirmed that CloudKit is available
         */
        private func syncUpCloudKitAvailable(completed: @escaping SyncCompleted) {
            log.info("syncUpCloudKitAvailable")
            guard let tableSync = self.tableSync else {
                log.warning("tableSync is nil, not syncing")
                return
            }

            let recordsToSyncToCloudKit = tableSync.recordsToSyncToCloudKit

            guard recordsToSyncToCloudKit.isEmpty == false else {
                log.info("recordsToSyncToCloudKit is empty, nothing to update")
                completed(SyncResult.success(()))
                return
            }

            log.info("Syncing: \(recordsToSyncToCloudKit.count) records")
            tableSync.recordZone.checkRecordZoneExisting(tableSync.recordZoneId) { [weak self] result in

                switch result {
                case let .failure(error):
                    completed(.failure(error))
                case .success:
                    self?.syncUpAfterConfirmedThatRecordZoneExist(completed: completed)
                }
            }
        }

        private func syncUpAfterConfirmedThatRecordZoneExist(completed: @escaping SyncCompleted) {
            log.info("syncUpAfterConfirmedThatRecordZoneExist")

            guard let tableSync = self.tableSync else { return }

            let ckRecordsToUpdate = tableSync.ckRecordsToUpdate
            let ckRecordIdsToDelete = tableSync.ckRecordIdsToDelete

            log.debug("ckRecordsToUpdate.count: \(ckRecordsToUpdate.count)")
            log.debug("ckRecordIdsToDelete.count: \(ckRecordIdsToDelete.count)")

            let modifyOperation = CKModifyRecordsOperation(recordsToSave: ckRecordsToUpdate,
                                                           recordIDsToDelete: ckRecordIdsToDelete.count > 0 ? ckRecordIdsToDelete : nil)

            modifyOperation.isAtomic = true
            modifyOperation.savePolicy = .changedKeys

            modifyOperation.modifyRecordsCompletionBlock = { [weak self] updated, deletedRecordIds, error in

                guard let self = self else { return }

                if let error = error {
                    self.log.error("Error updating CloudKit: \(error)")
                    completed(Result.failure(.cloudKitSaveFailed))
                    return
                }

                self.log.info("Success updating CloudKit")

                if let updated = updated {
                    self.localSyncing.updateLocalRecordsAsBeingSynched(fromCloudKit: updated)
                }

                if let deletedRecordIds = deletedRecordIds {
                    self.localSyncing.deleteLocalRecords(deletedRecordIds)
                }

                completed(Result.success(()))
            }

            log.info("modifyOperation.run")
            modifyOperation.run()
        }
    }

    public final class SyncFromCloudKit<SyncRecordType> {
        private let log = SwiftyBeaver.self
        private var completed: SyncCompleted!
        private weak var tableSync: TableSyncBase<SyncRecordType>?
        private let localSyncing: AnyLocalSyncing<SyncRecordType>
        private let changeTokens: ChangeTokens

        fileprivate init(tableSync: TableSyncBase<SyncRecordType>,
                         localSyncing: AnyLocalSyncing<SyncRecordType>,
                         changeTokens: ChangeTokens) {
            self.tableSync = tableSync
            self.localSyncing = localSyncing
            self.changeTokens = changeTokens
        }

        public func sync(completed: @escaping SyncCompleted) {
            log.info("SyncFromCloudKit",
                     context: SyncRecordType.self)

            guard let tableSync = self.tableSync else {
                log.error("tableSync is nil")
                preconditionFailure("tableSync is nil")
            }

            log.info("tableSync.recordZone.fetchRecordZonesChanged",
                     context: SyncRecordType.self)
            tableSync.recordZone.fetchRecordZonesChanged { [weak self] result in

                guard let self = self else { return }
                self.log.info("tableSync.recordZone.fetchRecordZonesChanged completed", context: SyncRecordType.self)

                switch result {
                case let .failure(error):
                    self.log.error("Error fetchRecordZonesChanged: \(error)")
                    completed(SyncResult.failure(error))
                case let .success(recordZoneChange):

                    if recordZoneChange.didChange {
                        self.log.info("Our recordZone has changed, updating",
                                      context: SyncRecordType.self)
                        self.updateRecords(completed: completed)
                    } else {
                        self.log.info("RecordZone has not changed, return success",
                                      context: SyncRecordType.self)
                        completed(SyncResult.success(()))
                    }
                }
            }
        }

        typealias FetchRecordsToUpdateResult = Result<Int, Error>
        private func updateRecords(completed: @escaping SyncCompleted) {
            log.info("FromCloudKit: updateRecords",
                     context: SyncRecordType.self)

            guard let tableSync = self.tableSync else {
                log.error("tableSync is nil",
                          context: SyncRecordType.self)
                preconditionFailure("tableSync is nil")
            }

            let zoneConfig = CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: changeTokens.recordChangeToken,
                                                                                 resultsLimit: nil,
                                                                                 desiredKeys: nil)

            let recordZoneId = tableSync.recordZoneId

            let config: [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration] = [recordZoneId: zoneConfig]

            log.debug("""
            CKFetchRecordZoneChangesOperation
            recordZoneId: \(recordZoneId)
            """,
                      context: SyncRecordType.self)

            let fetchRecordZoneChangesOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [recordZoneId],
                                                                                    configurationsByRecordZoneID: config)

            fetchRecordZoneChangesOperation.fetchAllChanges = true

            var recordsToUpdate: [CKRecord] = []
            var recordIDsToDelete: [CKRecord.ID] = []
            var newRecordChangeToken: CKServerChangeToken?

            fetchRecordZoneChangesOperation.recordChangedBlock = { [weak self] record in
                self?.log.debug("recordChangedBlock: \(record)",
                                context: SyncRecordType.self)
                recordsToUpdate.append(record)
            }

            fetchRecordZoneChangesOperation.recordWithIDWasDeletedBlock = { [weak self] recordId, _ in
                self?.log.debug("recordWithIDWasDeletedBlock: \(recordId)",
                                context: SyncRecordType.self)
                recordIDsToDelete.append(recordId)
            }

            fetchRecordZoneChangesOperation.recordZoneFetchCompletionBlock = { [weak self] _, recordChangeToken, _, moreComing, error in

                self?.log.debug("recordZoneFetchCompletionBlock: changeToken \(String(describing: recordChangeToken)) moreComing: \(moreComing)",
                                context: SyncRecordType.self)

                if moreComing == false, error == nil {
                    self?.log.debug("moreComing false, no error assigning token",
                                    context: SyncRecordType.self)
                    newRecordChangeToken = recordChangeToken
                }
            }

            fetchRecordZoneChangesOperation.fetchRecordZoneChangesCompletionBlock = { [weak self] error in

                guard let self = self else { return }

                self.log.info("fetchRecordZoneChangesCompletionBlock",
                              context: SyncRecordType.self)

                if let error = error {
                    if let ckError = error as? CKError {
                        self.log.error("CloudKit error: \(ckError)", context: SyncRecordType.self)

                        // The token is no good, so we'll use nil which is starting over.
                        self.log.warning("changeTokenExpired, clear out tokens, trying again",
                                         context: SyncRecordType.self)
                        // Starting over, local data should be removed treating CloudKit as the truth.
                        self.changeTokens.clear()
                        self.localSyncing.deleteAll()
                        self.changeTokens.recordChangeToken = nil
                        self.updateRecords(completed: completed)
                        return
                    } else {
                        assertionFailure("fetchRecordZoneChanges (not CKError) error: \(error)")
                        self.log.error("fetchRecordZoneChanges (not CKError) error: \(error)",
                                       context: SyncRecordType.self)
                        completed(SyncResult.failure(SyncError.unexpectedError(error: error)))
                    }
                    return
                }

                if let newRecordChangeToken = newRecordChangeToken {
                    self.log.debug("newChangeToken, updating records",
                                   context: SyncRecordType.self)
                    self.updateRecords(toBeUpdated: recordsToUpdate,
                                       toBeDeleted: recordIDsToDelete,
                                       changeToken: newRecordChangeToken,
                                       completed: completed)
                } else {
                    self.log.error("Completed without a changeToken",
                                   context: SyncRecordType.self)
                    assertionFailure("Completed without a changeToken")
                    completed(Result.failure(SyncError.cloudKitFetchFailed))
                }
            }

            log.info("Running: fetchRecordZoneChangesOperation",
                     context: SyncRecordType.self)
            fetchRecordZoneChangesOperation.run()
        }

        private func updateRecords(toBeUpdated: [CKRecord],
                                   toBeDeleted: [CKRecord.ID],
                                   changeToken: CKServerChangeToken,
                                   completed: @escaping SyncCompleted) {
            log.info("""
            SyncFromCloudKit: updateRecords
            toBeUpdated: \(toBeUpdated.count)
            toBeDeleted: \(toBeDeleted.count)
            changeToken: \(changeToken)
            """,
                     context: SyncRecordType.self)

            localSyncing.saveCloudKitRecordsLocally(remoteRecordsUpdated: toBeUpdated,
                                                    remoteRecordsDeleted: toBeDeleted)

            // Changes saved locally. we can not mark these changes as being accounted for by
            // saving the changeToken. Next time we will changes beyond this change token
            changeTokens.recordChangeToken = changeToken

            completed(Result.success(()))
        }
    }

    /**
     Check for the existince of a recordzone, adding if it doesn't exist
     */
    private final class RecordZone {
        private let log = SwiftyBeaver.self

        private let recordZoneId: CKRecordZone.ID
        private let changeTokens: ChangeTokens

        init(recordZoneId: CKRecordZone.ID,
             changeTokens: ChangeTokens) {
            self.recordZoneId = recordZoneId
            self.changeTokens = changeTokens
        }

        typealias RecordZoneCompleted = Result<Void, SyncError>
        /**
         Check if `recordZoneId` is an existing RecordZone in CloudKit

         - parameter recordZoneId: RecordZoneID to check for
         - parameter completed: Called with the result of the check

         - Precondition: CloudKit should have been verified to be available.
         */
        func checkRecordZoneExisting(_ recordZoneId: CKRecordZone.ID,
                                     completed: @escaping (RecordZoneCompleted) -> Void) {
            log.info("checkRecordZoneExisting", context: recordZoneId)

            let operation = CKFetchRecordZonesOperation(recordZoneIDs: [recordZoneId])

            operation.fetchRecordZonesCompletionBlock = { [weak self] recordZones, error in

                guard let self = self else { return }

                if let error = error {
                    self.log.warning("Error checking for recordZone: \(error.localizedDescription)")
                    completed(RecordZoneCompleted.failure(.recordZoneFailed))
                    return
                }

                if let recordZones = recordZones {
                    if recordZones.contains(where: { $0.key == recordZoneId }) {
                        self.log.debug("RecordZone was found: \(recordZones), success")
                        completed(RecordZoneCompleted.success(()))
                    } else {
                        self.add(recordZoneId, completed: completed)
                    }
                } else {
                    self.log.warning("recordZones was nil?")
                    assertionFailure("recordZones was nil?")
                }
            }

            operation.run()
        }

        typealias FetchRecordZoneHasChangedResult = Result<(didChange: Bool, newToken: CKServerChangeToken), SyncError>

        /**
         Fetch all of the RecordZones that have changed since the last check.
         - paramter completed: Called with the result of the fetch.
         */
        func fetchRecordZonesChanged(completed: @escaping (FetchRecordZoneHasChangedResult) -> Void) {
            let log = self.log

            log.info("fetchRecordZoneChanged", context: recordZoneId)

            var recordZoneChanged = false

            let zonesChangedSinceToken = changeTokens.zonesChangedInDatabaseToken

            log.debug("RecordZoneChangesFetcher fetch token: \(zonesChangedSinceToken?.description ?? "nil")")

            let changesOperation =
                CKFetchDatabaseChangesOperation(previousServerChangeToken: zonesChangedSinceToken)
            changesOperation.fetchAllChanges = true

            var newZonesChangedSinceToken: CKServerChangeToken?

            // CloudKit doesn't respond if there isn't a network connection, manually cancel
            // Avoiding a timeout
            let cancelTask = DispatchWorkItem { [unowned self] in
                log.warning("Operation didn't respond, attempt to cancel", context: self.recordZoneId)
                changesOperation.cancel()
                completed(FetchRecordZoneHasChangedResult.failure(.cloudKitFetchFailed))
            }

            changesOperation.recordZoneWithIDChangedBlock = { [weak self] changedRecordZoneID in

                guard let self = self else { return }

                log.info("recordZoneWithIDChangedBlock", context: changedRecordZoneID)

                if changedRecordZoneID == self.recordZoneId {
                    log.debug("Found zone with matching ID", context: changedRecordZoneID)
                    recordZoneChanged = true
                } else {
                    log.debug("Changed zone found, but not what we're looking for: \(changedRecordZoneID.zoneName)", context: self.recordZoneId)
                }
            }

            changesOperation.changeTokenUpdatedBlock = { [unowned self] updatedToken in

                log.info("changeTokenUpdatedBlock: updatedToken: \(updatedToken)",
                         context: self.recordZoneId)

                newZonesChangedSinceToken = updatedToken
            }

            changesOperation.fetchDatabaseChangesCompletionBlock = { [unowned self] changeToken, moreComing, error in

                cancelTask.cancel()

                self.log.info("fetchDatabaseChangesCompletionBlock", context: self.recordZoneId)

                newZonesChangedSinceToken = changeToken

                guard moreComing == false else {
                    log.info("moreComing: exiting", context: self.recordZoneId)
                    return
                }

                if let error = error {
                    log.error("Error fetchDatabaseChangesCompletionBlock: \(error)", context: self.recordZoneId)
                    completed(FetchRecordZoneHasChangedResult.failure(.cloudKitFetchFailed))
                    return
                }

                if let newZoneToken = newZonesChangedSinceToken {
                    log.debug("newZoneToken: \(newZoneToken)",
                              context: self.recordZoneId)
                    completed(FetchRecordZoneHasChangedResult.success((recordZoneChanged, newZoneToken)))
                } else {
                    log.error("Don't have a change token",
                              context: self.recordZoneId)
                    preconditionFailure("Not sure what to do here")
                }
            }

            log.info("Running changeOperation",
                     context: recordZoneId)
            changesOperation.run()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: cancelTask)
        }

        private func add(_ recordZoneId: CKRecordZone.ID,
                         completed: @escaping (RecordZoneCompleted) -> Void) {
            let recordZone = CKRecordZone(zoneID: recordZoneId)
            let modifyOperation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone],
                                                               recordZoneIDsToDelete: nil)

            modifyOperation.modifyRecordZonesCompletionBlock = { _, _, error in

                if error != nil {
                    completed(RecordZoneCompleted.failure(.recordZoneCreateFailed))
                } else {
                    completed(RecordZoneCompleted.success(()))
                }
            }

            modifyOperation.run()
        }
    }
}

extension TableSyncBase: NameDescribable {}

private extension CKDatabaseOperation {
    func run() {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        database.add(self)
    }
}
