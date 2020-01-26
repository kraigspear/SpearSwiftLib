//
//  DataCache.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import Foundation
import os.log

/// Object that can be cached
class Cached: NSObject {
	private let created = Date()
	public let data: Data
	private let expiresInMinutes: Int

	init(data: Data,
	     expiresInMinutes: Int) {
		self.data = data
		self.expiresInMinutes = expiresInMinutes
	}

	var isExpired: Bool {
		return created.numberOfMinutesBetweenNow() >= expiresInMinutes
	}
}

public protocol DataCachable: class {
	func data(forKey: String) -> Data?
	func set(data: Data, forKey: String, expireingInMinutes: Int)
	func removeItemsOlderThan(minutes: Int)
	func exist(forKey: String) -> Bool
}

/// Helper class to cache Data objects
public class DataCache: DataCachable {
	private let cache = NSCache<NSString, Cached>()
	private let log = Log.cache

	public init() {
	}

	/// Does an object with this key exist in the cache
	/// - Parameter forKey: Key to check cache
	public func exist(forKey: String) -> Bool {
		
		if memoryCacheData(forKey: forKey) != nil {
			
			os_log("Found in memory cache: %s",
				   log: log,
				   type: .debug,
				   forKey)
			
			return true
		}
		
		if fileCacheData(key: forKey) != nil {
			os_log("Found in disk cache: %s",
				   log: log,
				   type: .debug,
				   forKey)
			
			return true
		}
		
		os_log("Not found in cache: %s",
			   log: log,
			   type: .debug,
			   forKey)

		return false
	}

	/// Get data from the cache
	/// Returns nil, if key doesn't exist, or has expired
	/// - Parameter forKey: Key used to retrive from cache
	public func data(forKey: String) -> Data? {
		if let dataFromMemory = memoryCacheData(forKey: forKey) {
			os_log("Retrived data from memory cache: %s",
			       log: log,
			       type: .debug,
			       forKey)

			return dataFromMemory
		}

		if let fileCacheData = fileCacheData(key: forKey) {
			os_log("Retrived data from file cache: %s",
			       log: log,
			       type: .debug,
			       forKey)

			set(data: fileCacheData, forKey: forKey)
			return fileCacheData
		}

		os_log("%s not found in cache",
		       log: log,
		       type: .debug,
		       forKey)

		return nil
	}

	private func memoryCacheData(forKey: String) -> Data? {
		let nsKey = NSString(string: forKey)

		if let cachedObject = cache.object(forKey: nsKey) {
			if cachedObject.isExpired {
				os_log("Removing old object",
				       log: log,
				       type: .debug)

				cache.removeObject(forKey: nsKey)
				return nil
			}
			os_log("Using cached object for key: %s",
			       log: log,
			       type: .debug,
			       forKey)
			return cachedObject.data
		}

		return nil
	}

	/// Set an object in the cache
	/// - Parameter data: Data to cache
	/// - Parameter forKey: Key for retrival of cache
	/// - Parameter expireingInMinutes: How long before the data should be considered fresh
	public func set(data: Data, forKey key: String, expireingInMinutes: Int = 10) {
		os_log("Store %s in cache",
		       log: log,
		       type: .debug,
		       key)

		let cached = Cached(data: data, expiresInMinutes: expireingInMinutes)
		cache.setObject(cached, forKey: NSString(string: key))

		writeToFileCache(data, key: key)

		os_log("stored cached object: %s",
		       log: self.log,
		       type: .debug,
		       key)
	}

	// MARK: - File Cache

	private func writeToFileCache(_ data: Data, key: String) {
		DispatchQueue.global().async {
			let cacheUrl = self.cachPathFor(key)

			do {
				try data.write(to: cacheUrl)

				os_log("Wrote %s to disk cache",
				       log: self.log,
				       type: .debug,
				       cacheUrl.absoluteString)

			} catch {
				os_log("Error writing to cache error: %s for key: %s",
				       log: self.log,
				       type: .error,
				       error.localizedDescription,
				       key)
			}
		}
	}

	private func fileCacheData(key: String) -> Data? {
		let cacheUrl = self.cachPathFor(key)
		return try? Data(contentsOf: cacheUrl)
	}

	private func cachPathFor(_ key: String) -> URL {
		URL(fileURLWithPath: FileManager.default.cachePathFile(key))
	}

	/// Remove any older files
	public func removeItemsOlderThan(minutes: Int) {
		os_log("Removing cache items older than: %d minutes",
		       log: log,
		       type: .info,
		       minutes)

		DispatchQueue.global().async {
			let fileManager = FileManager.default
			let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

			urls.filter { url in fileManager.numberOfMinutesSinceCreated(url) >= minutes }
				.forEach { oldUrl in

					do {
						try fileManager.removeItem(at: oldUrl)
						os_log("File: %s deleted",
						       log: self.log,
						       type: .debug,
						       oldUrl.absoluteString)
					} catch {
						os_log("Error deleting %s %s",
						       log: self.log,
						       type: .error,
						       oldUrl.absoluteString,
						       error.localizedDescription)
					}
				}
		}
	}
}
