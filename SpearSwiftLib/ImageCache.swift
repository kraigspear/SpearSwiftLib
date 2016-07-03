//
//  ImageCache.swift
//  SportsmanTracker
//
//  Created by Kraig Spear on 5/1/15.
//  Copyright (c) 2015 Sportsman Tracker. All rights reserved.
//

import UIKit

public typealias ImageBlock = ( (image:UIImage?) -> Void)?
public typealias ImagesBlock = ( (image:[UIImage]) -> Void)?

/**
*  Loads an image from cache or downloads the image, stores in cache.
*/
public final class ImageCache
{
	/// One shared instance
	public static let sharedInstance = ImageCache()
	
	private let memoryCache: NSCache
	
	private init()
	{
		memoryCache = NSCache()
	}
	
 /**
 Fetch multiple images and return back on the completed block when finished
 
 - parameter urlStrs: Array of URL's to download
 - parameter completed: Called when all of the images have been fetched
 */
	public func fetchImages(urlStrs: [String], completed: ImagesBlock)
	{
		if let unwrapCompleted = completed
		{
			let que = dispatch_queue_create(
				"com.st.imageque", DISPATCH_QUEUE_CONCURRENT)
			
			var images:[UIImage] = [UIImage]()
			
			dispatch_async(que,
			               {
							for urlStr in urlStrs
							{
								if let image = self.fetchImage(urlStr)
								{
									images.append(image)
								}
							}
							
							dispatch_async(dispatch_get_main_queue())
							{
								unwrapCompleted(image: images)
							}
							
			});
		}
	}
	
	/**
	Fetch one image
	
	 - parameter ulrStr: URL of the image to fetch
	 - returns: The image, or nil if it can't be loaded
	*/
	public func fetchImage(ulrStr: String) -> UIImage?
	{
		if let fromMemory = self.fetchFromMemory(ulrStr)
		{
			return fromMemory
		}
		else if let fromCache = self.fetchFromDisk(ulrStr)
		{
			return fromCache
		}
		else if let fromUrl = fetchFromUrl(ulrStr)
		{
			return fromUrl
		}
		else
		{
			return nil
		}
	}
	
	private func fetchFromMemory(urlStr: String) -> UIImage?
	{
		return self.memoryCache.objectForKey(urlStr) as? UIImage
	}
	
	private func fetchFromDisk(urlStr: String) -> UIImage?
	{
		let fileNameCache = self.fileNameFromCache(urlStr)
		
		if self.fileExistInCacheDirectory(urlStr)
		{
			if let imageFromCache = UIImage(contentsOfFile: fileNameCache)
			{
				self.memoryCache.setObject(imageFromCache, forKey: urlStr)
				return imageFromCache
			}
		}
		return nil
	}
	
	private func fetchFromUrl(urlStr: String) -> UIImage?
	{
		let fileNameCache = self.fileNameFromCache(urlStr)
		
		if let url = NSURL(string: urlStr)
		{
			if let imageData = NSData(contentsOfURL: url)
			{
				if let imageFromURL = UIImage(data: imageData)
				{
					self.memoryCache.setObject(imageFromURL, forKey: self.fileForUrl(urlStr))
					imageData.writeToFile(fileNameCache, atomically: true)
					return imageFromURL
				}
			}
		}
		return nil
	}
	
	/**
	Fetches image from cache or disk
	All loading is done on a separate thread, so the caller doesn't have to worry about creating one.
	The callback (completed) is done back on the main thread.
	
	- parameter urlStr:    A url string where the file can be downloaded
	- parameter completed: Called with a valid image or nil, if the file can't be loaded
	*/
	public func fetchImage(urlStr: String, completed:ImageBlock)
	{
		if let unwrapCompleted = completed
		{
			dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) { () -> Void in
				
				if let image = self.fetchImage(urlStr)
				{
					dispatch_async(dispatch_get_main_queue())
					{
						unwrapCompleted(image:image)
					}
				}
				else
				{
					//Not able to load the image.
					dispatch_async(dispatch_get_main_queue())
					{
						print("failed to load image \(urlStr)")
						unwrapCompleted(image: nil)
					}
				}
			}
		}
	}
	
	/**
	Does the file exist in the cache directory.
	
	:param: urlStr The URL of the file being loaded
	
	:returns: true if this file is in the cache
	*/
	private func fileExistInCacheDirectory(urlStr: String) -> Bool
	{
		return NSFileManager.defaultManager().fileExistsAtPath(fileNameFromCache(urlStr))
	}
	
	/**
	<#Description#> Gets the name of the file for the url passed in that is stored in the cache directory
	
	:param: urlStr A url string to get the cache filename for
	
	:returns: File name where this file for the URL is stored
	*/
	private func fileNameFromCache(urlStr:String) -> String
	{
		let fileName = fileForUrl(urlStr)
		let cachDirFileName = cacheDirectoryAppendFileName(fileName) as String
		return cachDirFileName
	}
	
	/**
	Get just the file name portion of a URL
	
	:param: urlStr URL to extract the file name from
	
	:returns: Filename for this URL
	*/
	private func fileForUrl(urlStr:String) -> String
	{
		let urlStr = urlStr as NSString
		return urlStr.lastPathComponent
	}
	
	/**
	Gets the full path of the file including the cache path
	
	:param: fileName File name to add the cache path to
	
	:returns: File and the cache path
	*/
	private func cacheDirectoryAppendFileName(fileName:String) -> NSString
	{
		return self.cacheDirectory.stringByAppendingPathExtension(fileName)!
	}
	
	/// The location of the cache directory
	private lazy var cacheDirectory: NSString =
  {
	let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
	
	return cacheDirectory
	}()
}
