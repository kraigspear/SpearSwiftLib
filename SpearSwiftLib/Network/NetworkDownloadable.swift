//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

/**
 A type that knows how to download data from the network.

 This protocol can be used to download an image, JSON ext...

 It only retrieves data. A more specific type could be used to transform the data into a specific type,
 such as an image or JSON.

 - SeeAlso: `ImageDownloader`
 */
public protocol NetworkDownloadable {
    // MARK: - Downloading

    /**
     Download data from a URL

     - parameter from: The URL where data is downloaded from.
     - parameter completed: Called when completed with the result.

     ```swift
     extension ImageDownloader: ImageDownloadable {
     public func download(from: URL, completed: @escaping (NetworkResult<[UIImage]>) -> Void) {

     //networkDownloader is a type that implements the NetworkDownloadable protocol.
     networkDownloader.download(from: from) {(result) in
     switch result {
     case .error(let error):
     completed(NetworkResult<[UIImage]>.error(error: error))
     case .response(let response):
     completed(NetworkResult<[UIImage]>.response(code: response))
     case .success(let data):
     data.toImages {(images) in
     completed(NetworkResult<[UIImage]>.success(result: images))
     }
     }
     }
     }
     }
     ```
     */
    func download(from: RequestBuildable,
				  pinningCertTo: Data?,
				  completed: @escaping (NetworkResult<Data>) -> Void)
	
	/**
	Cancel this download
	*/
	func cancel()
}
