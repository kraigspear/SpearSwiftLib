//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

/// Class that downloading JSON from the network.
public final class JsonDownloader {
	public let networkDownloader: NetworkDownloadable
	private let log = SwiftyBeaver.self

	/**
	 Initialize with a NetworkDownloadable

	 - parameter networkDownloader: Provides access to downloading data from the network
	 **/
	public init(networkDownloader: NetworkDownloadable) {
		self.networkDownloader = networkDownloader
	}

	/// Initializer using default implementations of dependencies
	public convenience init() {
		self.init(networkDownloader: NetworkDownloader())
	}
}

extension JsonDownloader: JSONDownloadable {
	public func download(from: RequestBuildable,
						 pinningCertTo: Data? = nil,
						 completed: @escaping (NetworkResult<JsonKeyValue>) -> Void) {
		let log = self.log

		log.verbose("Sending request: \(from.request.url!.absoluteString)")

		networkDownloader.download(from: from, pinningCertTo: pinningCertTo) { result in
			assert(Thread.isMainThread, "Expected main thread")
			switch result {
			case let .success(result: dataResult):
				let json = try! JSONSerialization.jsonObject(with: dataResult, options: []) as! JsonKeyValue

				log.verbose("Response from request: \(json.description)")

				completed(NetworkResult<JsonKeyValue>.success(result: json))
			case let .error(error: error):

				log.error("Error from request: \(from.request.url!.absoluteString) error: %s: \(error)")

				completed(NetworkResult<JsonKeyValue>.error(error: error))
			case let .response(code: code):

				log.error("Network response error from request: \(from.request.url!.absoluteString) code: \(code)")

				completed(NetworkResult<JsonKeyValue>.response(code: code))
			}
		}
	}
}
