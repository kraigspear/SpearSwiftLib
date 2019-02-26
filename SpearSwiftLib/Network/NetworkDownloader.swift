//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

/**
 A type that knows how to download data from the network.

 This class can be used to download an image, JSON ext...

 It only retrieves data. A more specific type could be used to transform the data into a specific type,
 such as an image or JSON.

 - SeeAlso: `ImageDownloader`
 */
public final class NetworkDownloader: NetworkDownloadable {
	/// Task running network task
	private var task: URLSessionDataTask?

	/// Initialize a new instance of NetworkDownloader
	public init() {}

	// MARK: - Downloading

	/**
	 Download data from a URL

	 - parameter from: The URL where data is downloaded from.
	 - parameter completed: Called when completed with the result.

	 */
	public func download(from requestBuilder: RequestBuildable,
	                     pinningCertTo: Data? = nil,
	                     completed: @escaping (NetworkResult<Data>) -> Void) {
		let pinningDelegate: URLSessionPinningDelegate?
		if let pinningCertTo = pinningCertTo {
			pinningDelegate = URLSessionPinningDelegate(certificate: pinningCertTo)

		} else {
			pinningDelegate = nil
		}

		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig,
		                         delegate: pinningDelegate,
		                         delegateQueue: nil)

		let request = requestBuilder.request

		task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

			DispatchQueue.main.async {[weak self] in
				if let error = error {
					completed(NetworkResult<Data>.error(error: error))
					return
				}

				// If response is not a HTTPURLResponse, then we need to deal with it.
				// When this was written it was always true. If that was to change, we would need to
				// write new code to handle it.
				let response = response as! HTTPURLResponse

				if response.statusCode != 200 {
					self?.logError(statusCode: response.statusCode, request: request)
					completed(NetworkResult<Data>.response(code: response.statusCode))
					return
				}

				if let data = data {
					completed(NetworkResult<Data>.success(result: data))
				} else {
					SwiftyBeaver.error("No error, status code = 200, but data was nil? \(String(describing: request.url))")
					preconditionFailure("No error, status code = 200, but data was nil? \(String(describing: request.url))")
				}
			}
		}

		task!.resume()
		session.finishTasksAndInvalidate()
	}

	private func logError(statusCode: Int, request: URLRequest) {
		if let body = request.httpBody {
			if let bodyText = String(data: body, encoding: String.Encoding.utf8) {
				SwiftyBeaver.error("Unsuccessful status code: \(statusCode) request: \(request) body: \(bodyText)")
				return
			}
		}

		SwiftyBeaver.error("Unsuccessful status code: \(statusCode) request: \(request)")
	}

	public func cancel() {
		task?.cancel()
	}
}
