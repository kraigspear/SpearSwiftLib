//
//  FileManageable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 2/19/20.
//  Copyright © 2020 spearware. All rights reserved.
//

import Foundation


/// Protocol around FileManager to make it testable
public protocol FileManageable {

	/// Path for the cache
	var cachePath: String { get }

	/// Returns an array of URLs for the specified common directory in the requested domains.
	func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
	
	/**
	Return a filename with the cache path added
	- Returns: Filename with cache path added
	*/
	func cachePathFile(_ fileName: String) -> String
	
	
	/// URL's of all files in cache
	func cacheFiles() -> [String]
	
	/**
	Returns the file date/time or nil, if the file doesn't exist
	- Returns: The file date/time or nil
	*/
	func fileDateTime(_ fileName: String) -> Date?
	
	/// How many minute have passed since the file at this URL has been created
	/// or -1 if the file doesn't exist.
	/// - Parameter url: URL of the file to get the number of minutes for
	func numberOfMinutesSinceCreated(_ fileNamePath: String) -> Int
	
	/// Removes the file or directory at the specified URL.
	func removeItem(at URL: URL) throws
	
	
	/// Removes the file or directory at the specified path.
	/// - Parameter path: A path string indicating the file or directory to remove. If the path specifies a directory, the contents of that directory are recursively removed. You may specify nil for this parameter.
	/// - returns: true if the item was removed successfully or if path was nil. Returns false if an error occurred. If the delegate stops the operation for a file, this method returns true. However, if the delegate stops the operation for a directory, this method returns false.
	func removeItem(atPath path: String) throws
	
}

extension FileManager: FileManageable {}
