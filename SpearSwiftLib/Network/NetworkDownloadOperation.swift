//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Combine
import Foundation
import os.log

public protocol NetworkDownloadable {
    associatedtype Downloaded

    var download: AnyPublisher<Downloaded, Error> { get }
}

open class NetworkDownloader<Downloaded>: NetworkDownloadable {
    private let log = Log.network

    private let downloadOperation: NetworkDownloadOperation<Downloaded>
    private let operationQueue: OperationQueue

    public init(downloadOperation: NetworkDownloadOperation<Downloaded>,
                operationQueue: OperationQueue) {
        self.downloadOperation = downloadOperation
        self.operationQueue = operationQueue
    }

    public var download: AnyPublisher<Downloaded, Error> {
        Future<Downloaded, Error> { [weak self] promise in

            guard let self = self else { return }

            self.downloadOperation.completionBlock = {
                if let downloaded = self.downloadOperation.result {
                    promise(.success(downloaded))
                    return
                }

                if let error = self.downloadOperation.error {
                    promise(.failure(error))
                    return
                }

                os_log("Download data and error were nil",
                       log: self.log,
                       type: .fault)

                preconditionFailure("Download data and error were nil")
            }

            self.operationQueue.addOperation(self.downloadOperation)

        }.eraseToAnyPublisher()
    }
}

open class NetworkDownloadOperation<Type>: BaseOperation {
    private let log = Log.network

    private let requestBuilder: RequestBuildable
    private let urlSession: URLSession

    public private(set) var result: Type?
    private var task: URLSessionDataTask!

    public init(requestBuilder: RequestBuildable,
                urlSession: URLSession) {
        self.requestBuilder = requestBuilder
        self.urlSession = urlSession
    }

    open override func cancel() {
        os_log("Network download operation cancelled",
               log: log,
               type: .debug)
        super.cancel()
    }

    open override func main() {
        os_log("Main",
               log: log,
               type: .info)

        guard isCancelled == false else {
            os_log("Operation cancelled",
                   log: log,
                   type: .debug)
            done()
            return
        }

        let request = requestBuilder.request
        let url = request.url!.debugDescription

        os_log("Downloading: %s",
               log: log,
               type: .debug,
               url)

        task = urlSession.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in

            guard let self = self else { return }

            os_log("Finshed download of: %s",
                   log: self.log,
                   type: .debug,
                   url)

            defer {
                assert(!(self.result == nil && self.error == nil) || self.isCancelled,
                       "Either result or error should have been set")
                self.done()
            }

            guard self.isCancelled == false else {
                os_log("Request cancelled: %s",
                       log: self.log,
                       type: .debug,
                       url)

                return
            }

            if let error = error {
                os_log("Error downloading data: %s with error: %{public}s",
                       log: self.log,
                       type: .error,
                       url,
                       error.localizedDescription)
                self.error = error
                return
            }

            // If response is not a HTTPURLResponse, then we need to deal with it.
            // When this was written it was always true. If that was to change, we would need to
            // write new code to handle it.
            let response = response as! HTTPURLResponse

            os_log("Download Status code: %d for url: %s",
                   log: self.log,
                   type: .debug,
                   response.statusCode,
                   url)

            guard response.statusCode == 200 else {
                os_log("Download Status code not 200: %d with url: %s",
                       log: self.log,
                       type: .error,
                       response.statusCode,
                       url)

                self.error = NetworkError.statusCodeError(statusCode: response.statusCode)
                return
            }

            if let data = data {
                os_log("Attempt to convert data from service to Operation Type",
                       log: self.log,
                       type: .debug)

                self.result = self.convertTo(data)

                if self.result == nil {
                    os_log("Data is nil, failed to convert url: %s",
                           log: self.log,
                           type: .error,
                           url)

                    fatalError("Data is nil, failed to convert")
                } else {
                    os_log("Successfully convert data from service to: %s",
                           log: self.log,
                           type: .debug,
                           String(describing: Type.self))
                }

            } else {
                preconditionFailure("No error, status code = 200, but data was nil? \(String(describing: request.url))")
            }
        }

        os_log("Starting download url: %s",
               log: log,
               type: .info,
               url)

        task.resume()
        urlSession.finishTasksAndInvalidate()
    }

    /**
     Convert data from the network into a specific type (Image, JSON ext....)
     */
    open func convertTo(_: Data) -> Type? {
        fatalError("Override in child class")
    }
}
