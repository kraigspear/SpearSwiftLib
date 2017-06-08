//
//  GetRequest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/7/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation

/**
A simple get request, RequestBuildable

```swift

func downloadImage(from: URL, whenCompleted: @escaping (NetworkResult<[UIImage]>) -> Void ) {
	//Create a GetRequest from a URL
	let getRequest = GetRequest(url: from)
	log.debug("Downloading radar image from URL \(from)")
	//Use the GetRequest in a downloader
	imageDownloader.download(from: getRequest, completed: whenCompleted)
}

```
*/
public struct GetRequest: RequestBuildable {
	
	///URL to use in the request
	public let url: URL
	
	/**
	Initialize a GetRequest using the URL that makes up the request
	
	- parameter url: URL that makes up the request.
	*/
	public init(url: URL) {
		self.url = url
	}
	
	///URL request for `url`
	public var request: URLRequest {
		return URLRequest(url: url)
	}
}
