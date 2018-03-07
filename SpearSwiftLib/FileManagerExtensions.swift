//
//  FileManagerExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/13/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

extension FileManager {
    /// The users cache path location
    public var cachePath: String {
        let directories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return directories[0]
    }

    /*!
     Return a filename with the cache path added
     :returns: Filename with cache path added
     */
    public func cachePathFile(_ fileName: String) -> String {
        let cachePath = self.cachePath as NSString
        return cachePath.appendingPathComponent(fileName)
    }

    /*!
     Returns the file date/time or nil, if the file doesn't exist
     :returns: The file date/time or nil
     */
    public func fileDateTime(_ fileName: String) -> Date? {
        if !fileExists(atPath: fileName) {
            return nil
        }

        do {
            let attributes = try attributesOfItem(atPath: fileName)
            return attributes[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
}
