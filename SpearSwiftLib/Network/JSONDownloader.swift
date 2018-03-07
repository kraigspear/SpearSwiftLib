//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

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
        networkDownloader.download(from: from) { result in
            assert(Thread.isMainThread, "Expected main thread")
            switch result {
            case let .success(result: dataResult):
                let json = try! JSONSerialization.jsonObject(with: dataResult, options: []) as! JsonKeyValue
                completed(NetworkResult<JsonKeyValue>.success(result: json))
            case let .error(error: error):
                completed(NetworkResult<JsonKeyValue>.error(error: error))
            case let .response(code: code):
                completed(NetworkResult<JsonKeyValue>.response(code: code))
            }
        }
    }
}
