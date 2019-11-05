//
//  DataCache.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

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

/// Helper class to cache Data objects
public class DataCache {
    private let log = SwiftyBeaver.self
    private let logContext = Log.general

    private let cache = NSCache<NSString, Cached>()

    public init() {}

    /// Get data from the cache
    /// Returns nil, if key doesn't exist, or has expired
    /// - Parameter forKey: Key used to retrive from cache
    public func data(forKey: String) -> Data? {
        let nsKey = NSString(string: forKey)

        if let cachedObject = cache.object(forKey: nsKey) {
            if cachedObject.isExpired {
                log.debug("Removing old object")
                cache.removeObject(forKey: nsKey)
                return nil
            }

            log.verbose("Using cached object", context: logContext)
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
        log.debug("stored cached object: \(forKey)", context: logContext)
    }
}
