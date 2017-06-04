//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

///Class that downloading JSON from the network.
public final class JsonDownloader {

	public let networkDownloader: NetworkDownloadable

	/**
	Initialize with a NetworkDownloadable

	- parameter networkDownloader: Provides access to downloading data from the network
	**/
	public init(networkDownloader: NetworkDownloadable) {
		self.networkDownloader = networkDownloader
	}

	///Initializer using default implementations of dependencies
	public convenience init() {
		self.init(networkDownloader: NetworkDownloader())
	}
}

extension JsonDownloader: JSONDownloadable {
	public func download(from: RequestBuildable, completed: @escaping (NetworkResult<JsonKeyValue>) -> Void) {



	}
}