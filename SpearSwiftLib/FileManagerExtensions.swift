//
//  FileManagerExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/13/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation


extension NSFileManager {
    
    ///The users cache path location
    public var cachePath:String {
        let directories = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return directories[0]
    }
    
    /*!
    Return a filename with the cache path added
    :returns: Filename with cache path added
    */
    public func cachePathFile(fileName:String) -> String {
        let cachePath = self.cachePath as NSString
        return cachePath.stringByAppendingPathComponent(fileName)
    }
    
    /*!
    Returns the file date/time or nil, if the file doesn't exist
    :returns: The file date/time or nil
    */
    public func fileDateTime(fileName:String) -> NSDate? {
        if !self.fileExistsAtPath(fileName) {
            return nil
        }
        
        do {
           let attributes = try self.attributesOfItemAtPath(fileName)
           return attributes[NSFileCreationDate] as? NSDate
        } catch {
            return nil
        }
        
    }
}