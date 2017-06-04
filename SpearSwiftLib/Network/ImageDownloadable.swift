//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import UIKit

/**
 Type that has the ability to download a UIImage or series of UIImages from the network.

 Animated GIFs are supported. If the URL is pointing to an Animated Gif then the result
 will contain an array of those frames.
*/
public protocol ImageDownloadable {

	//MARK: - Methods
	/**
	Download 1 or more images from the network.

	- parameter from: The RequestBuildable that provides a `URLRequest` to download from
	- parameter completed: Called on completion with the result of the call

	```swift
		isDownloading = true

		downloader.download(from: url) {[weak self] (result) in
			self?.isDownloading = false
			switch result {
			case .error(let error):
				whenCompleted(NetworkResult<[UIImage]>.error(error: error))
			case .response(let code):
				whenCompleted(NetworkResult<[UIImage]>.response(code: code))
			case .success(let images):
				whenCompleted(NetworkResult<[UIImage]>.success(result: images))
			}
		}
	```
	*/
	func download(from: RequestBuildable, completed: @escaping (NetworkResult<[UIImage]>) -> Void)

	//MARK: - Members
	///Provides the ability to download data from the network
	var networkDownloader: NetworkDownloadable {get}
}


