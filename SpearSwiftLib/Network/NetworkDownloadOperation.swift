//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

open class NetworkDownloadOperation<Type>: BaseOperation {
    private let requestBuilder: RequestBuildable
    private let timeout: Double
    private var pinningCert: Data?

    public private(set) var result: Type?

    private var task: URLSessionDataTask!

    private let logContext = Log.network
    private let log = SwiftyBeaver.self

    public init(requestBuilder: RequestBuildable,
                timeout: Double = 10.0,
                pinningCertTo: Data? = nil) {
        self.requestBuilder = requestBuilder
        self.timeout = timeout
        pinningCert = pinningCertTo
    }

    open override func cancel() {
        log.debug("Network download operation cancelled", context: logContext)
        super.cancel()
    }

    open override func main() {
        log.info("Main", context: logContext)

        guard isCancelled == false else {
            log.debug("Operation cancelled", context: logContext)
            done()
            return
        }

        let request = requestBuilder.request
        let url = request.url!.debugDescription

        log.debug("Downloading: \(url) ", context: logContext)

        let pinningDelegate: URLSessionPinningDelegate?
        if let pinningCertTo = pinningCert {
            pinningDelegate = URLSessionPinningDelegate(certificate: pinningCertTo)

        } else {
            pinningDelegate = nil
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: sessionConfig,
                                 delegate: pinningDelegate,
                                 delegateQueue: nil)

        var time = ElaspedTime()

        task = session.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in

            guard let self = self else { return }

            self.log.debug("Finshed download of: \(url) in: \(time.stop())", context: self.logContext)

            defer {
                assert(!(self.result == nil && self.error == nil) || self.isCancelled,
                       "Either result or error should have been set")
                self.done()
            }

            self.log.debug("Request completed: \(url)", context: self.logContext)

            guard self.isCancelled == false else {
                self.log.debug("Request cancelled: \(url)", context: self.logContext)
                return
            }

            if let error = error {
                self.log.error("Error downloading data: \(error.localizedDescription) url: \(url)", context: self.logContext)
                self.error = error
                return
            }

            // If response is not a HTTPURLResponse, then we need to deal with it.
            // When this was written it was always true. If that was to change, we would need to
            // write new code to handle it.
            let response = response as! HTTPURLResponse

            self.log.debug("Download Status code: \(response.statusCode) for url: \(url)", context: self.logContext)

            guard response.statusCode == 200 else {
                self.log.warning("Download Status code not 200: \(response.statusCode) for url: \(url)", context: self.logContext)

                self.error = NetworkError.statusCodeError(statusCode: response.statusCode)
                return
            }

            if let data = data {
                self.log.debug("Attempt to convert data from service to Operation Type", context: self.logContext)

                self.result = self.convertTo(data)

                if self.result == nil {
                    self.log.error("Data is nil, failed to convert url: \(url)", url)

                    fatalError("Data is nil, failed to convert")
                } else {
                    self.log.debug("Successfully convert data from service to: \(String(describing: Type.self))", context: self.logContext)
                }

            } else {
                preconditionFailure("No error, status code = 200, but data was nil? \(String(describing: request.url))")
            }
        }

        log.info("Starting download url: \(url)", context: logContext)

        task.resume()
        session.finishTasksAndInvalidate()
    }

    /**
     Convert data from the network into a specific type (Image, JSON ext....)
     */
    open func convertTo(_: Data) -> Type? {
        fatalError("Override in child class")
    }
}
