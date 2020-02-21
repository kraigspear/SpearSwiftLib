//
//  FileManagerExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/13/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation
import os.log

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
	
	public func cacheFiles() -> [String] {
		
		guard let contents = try? contentsOfDirectory(atPath: cachePath) else  {
			os_log("Error getting cache contents",
				   log: Log.general,
				   type: .error)
			return []
		}

		let cachePathNSString = self.cachePath as NSString
		
		let urls = contents.map {
			cachePathNSString.appendingPathComponent($0)
		}
		
		return urls
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
	
	public func numberOfMinutesSinceCreated(_ fileNamePath: String) -> Int {
		
		guard let fileDateTime = fileDateTime(fileNamePath) else {
			
			os_log("Didn't find file: %s",
				   log: Log.general,
				   type: .error,
				   fileNamePath)
			
			return -1
		}
		
		return fileDateTime.numberOfMinutesBetweenNow()
	}
}
