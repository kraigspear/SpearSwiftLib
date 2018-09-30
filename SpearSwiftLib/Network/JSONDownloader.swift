//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import os.log

/// Class that downloading JSON from the network.
public final class JsonDownloader {
    public let networkDownloader: NetworkDownloadable

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
    public func download(from: RequestBuildable, completed: @escaping (NetworkResult<JsonKeyValue>) -> Void) {
        os_log("Sending request %s",
               log: Log.network,
               type: .debug,
               from.request.url!.absoluteString)

        networkDownloader.download(from: from) { result in
            assert(Thread.isMainThread, "Expected main thread")
            switch result {
            case let .success(result: dataResult):
                let json = try! JSONSerialization.jsonObject(with: dataResult, options: []) as! JsonKeyValue

                os_log("Response from request %s",
                       log: Log.network,
                       type: .debug,
                       json.description)

                completed(NetworkResult<JsonKeyValue>.success(result: json))
            case let .error(error: error):

                os_log("Error from request: %{public}s error: %s",
                       log: Log.network,
                       type: .error,
                       from.request.url!.absoluteString,
                       error.localizedDescription)

                completed(NetworkResult<JsonKeyValue>.error(error: error))
            case let .response(code: code):

                os_log("Network response error from request: %s error: %d",
                       log: Log.network,
                       type: .error,
                       from.request.url!.absoluteString,
                       code)

                completed(NetworkResult<JsonKeyValue>.response(code: code))
            }
        }
    }
}
