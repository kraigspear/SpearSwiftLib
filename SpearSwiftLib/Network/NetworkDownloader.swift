//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation


/**
	A type that knows how to download data from the network.

	This class can be used to download an image, JSON ext...

	It only retrieves data. A more specific type could be used to transform the data into a specific type,
	such as an image or JSON.

	- SeeAlso: `ImageDownloader`
*/
public final class NetworkDownloader: NetworkDownloadable  {

	public init() {}

	//MARK: - Downloading

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
	public func download(from: URL, completed: @escaping (NetworkResult<Data>) -> Void) {

		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

		let task = session.dataTask(with: from) {(data: Data?, response: URLResponse?, error: Error?) in

			DispatchQueue.main.async {

				if let error = error {
					completed(NetworkResult<Data>.error(error: error))
					return
				}

				//If response is not a HTTPURLResponse, then we need to deal with it.
				//When this was written it was always true. If that was to change, we would need to
				//write new code to handle it.
				let response = response as! HTTPURLResponse

				if response.statusCode != 200 {
					completed(NetworkResult<Data>.response(code: response.statusCode))
					return
				}

				//

				if let data = data {
					completed(NetworkResult<Data>.success(result: data))
				}
				else {
					preconditionFailure("No error, status code = 200, but data was nil?")
				}
			}

		}

		task.resume()
		session.finishTasksAndInvalidate()
	}
}