//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import UIKit
import SwiftyBeaver

/**

Implementation of the `ImageDownloadable` protocol.

Downloads an image from a network.

- SeeAlso: `NetworkDownloadable`
- SeeAlso: `ImageDownloadable`

```swift
func downloadImage(from: URL, whenCompleted: @escaping (NetworkResult<[UIImage]>) -> Void ) {
	let getRequest = GetRequest(url: from)
	log.debug("Downloading radar image from URL \(from)")
	imageDownloader.download(from: getRequest, completed: whenCompleted)
}
```
*/
public final class ImageDownloader {

	//MARK: - Members

	///Provides the ability to download data from the network
	fileprivate let networkDownloader: NetworkDownloadable
	
	///Logging
	fileprivate let log = SwiftyBeaver.self

	//MARK: - Init
	/**
	Initializer with the `NetworkDownloadable` providing access to Data from the network

	- parameter networkDownloader: Providing access to Data from the network
	*/
	public init(networkDownloader: NetworkDownloadable) {
		self.networkDownloader = networkDownloader
	}
	
	///Initializer using a default implementation of a `NetworkDownloadable`
	public convenience init() {
		self.init(networkDownloader: NetworkDownloader())
	}

}

//MARK: - ImageDownloadable
extension ImageDownloader: ImageDownloadable {

	//MARK: - Downloading

	/**
	Download 1 or more images from the network.

	If the URL points to an animated GIF, then there is a UIImage for each frame.

	- parameter from: The URL where the image is to be downloaded from.
	- parameter completed: Called on completion with the result of the call
	*/
	public func download(from: RequestBuildable, completed: @escaping (NetworkResult<[UIImage]>) -> Void) {

		log.verbose("Downloading from \(from)")
		
		networkDownloader.download(from: from) {[weak self] (result) in
			
			guard let mySelf = self else { return }
			
			switch result {
			case .error(let error):
				mySelf.log.error("Error downloading image \(error)")
				completed(NetworkResult<[UIImage]>.error(error: error))
			case .response(let response):
				mySelf.log.error("Unsuccessful response downloading \(response)")
				completed(NetworkResult<[UIImage]>.response(code: response))
			case .success(let data):
				mySelf.log.verbose("Converting data to UIImage(s)")
				data.toImages {(images) in
					mySelf.log.verbose("Data converted to images")
					completed(NetworkResult<[UIImage]>.success(result: images))
				}
			}
		}

	}
}

//MARK: - Data
private extension Data {
	/**
	Convert the contents of this Data Object to 1 or more UIImages

     - parameter completed: Called with the result on completion
	**/
	func toImages(completed: @escaping (_ images: [UIImage]) -> Void) {
		DispatchQueue.global().async {
			let extractor = GifExtractor(imageData: self as NSData)
			let images = extractor.extracted()
			DispatchQueue.main.async {
				completed(images)
			}
		}
	}
}
