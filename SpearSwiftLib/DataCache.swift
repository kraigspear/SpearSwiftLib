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
}

/// Helper class to cache Data objects
public class DataCache: DataCachable {

    private let cache = NSCache<NSString, Cached>()
	private let log = Log.general

    public init() {}

    /// Get data from the cache
    /// Returns nil, if key doesn't exist, or has expired
    /// - Parameter forKey: Key used to retrive from cache
    public func data(forKey: String) -> Data? {
        let nsKey = NSString(string: forKey)

        if let cachedObject = cache.object(forKey: nsKey) {
            if cachedObject.isExpired {
				os_log("Removing old object",
					   log: log,
					   type: .debug)
				
                cache.removeObject(forKey: nsKey)
                return nil
            }
			os_log("Using cached object",
				   log: log,
				   type: .debug)
            return cachedObject.data
        }

        return nil
    }

    /// Set an object in the cache
    /// - Parameter data: Data to cache
    /// - Parameter forKey: Key for retrival of cache
    /// - Parameter expireingInMinutes: How long before the data should be considered fresh
    public func set(data: Data, forKey: String, expireingInMinutes: Int = 10) {
        let cached = Cached(data: data, expiresInMinutes: expireingInMinutes)
        cache.setObject(cached, forKey: NSString(string: forKey))
		os_log("stored cached object: %s",
			   log: self.log,
			   type: .debug,
			   forKey)
    }
}
