//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

open class NetworkDownloadOperation<Type>: BaseOperation {
    let log = SwiftyBeaver.self

    private let requestBuilder: RequestBuildable
    private let timeout: Double
    private var pinningCert: Data?

    public private(set) var result: Type?

    private var task: URLSessionDataTask!

    public init(requestBuilder: RequestBuildable,
                timeout: Double = 10.0,
                pinningCertTo: Data? = nil) {
        self.requestBuilder = requestBuilder
        self.timeout = timeout
        pinningCert = pinningCertTo
    }

    open override func main() {
        guard isCancelled == false else {
            log.warning("Operation cancelled")
            done()
            return
        }

        let request = requestBuilder.request

        let context = request.url!.absoluteString

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

        task = session.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in

            guard let self = self else { return }

            defer {
                assert(!(self.result == nil && self.error == nil) || self.isCancelled,
                       "Either result or error should have been set")
                self.done()
            }

            self.log.info("Request completed", context: context)

            guard self.isCancelled == false else {
                self.log.info("Request cancelled", context: context)
                return
            }

            if let error = error {
                self.log.error("Error downloading data: \(error)", context: context)
                self.error = error
                return
            }

            // If response is not a HTTPURLResponse, then we need to deal with it.
            // When this was written it was always true. If that was to change, we would need to
            // write new code to handle it.
            let response = response as! HTTPURLResponse

            guard response.statusCode == 200 else {
                self.log.error("Status code not 200", context: context)
                self.error = NetworkError.statusCodeError(statusCode: response.statusCode)
                return
            }

            if let data = data {
                self.log.debug("Attempt to convert data from service to Operation Type")
                self.result = self.convertTo(data)

                if self.result == nil {
                    self.log.error("Data is nil, failed to convert", context: context)
                    fatalError("Data is nil, failed to convert")
                } else {
                    self.log.info("Successfully convert data from service to: \(Type.self)")
                }

            } else {
                self.log.error("No error, status code = 200, but data was nil? \(String(describing: request.url))")
                preconditionFailure("No error, status code = 200, but data was nil? \(String(describing: request.url))")
            }
        }

        log.debug("Starting Network download", context: context)
        task.resume()
        session.finishTasksAndInvalidate()
    }

    /**
     Convert data from the network into a specific type (Image, JSON ext....)
     */
    open func convertTo(_: Data) -> Type? {
        log.error("Override in child class: \(self)")
        fatalError("Override in child class")
    }

    private static func logError(statusCode: Int, request: URLRequest) {
        if let body = request.httpBody {
            if let bodyText = String(data: body, encoding: String.Encoding.utf8) {
                SwiftyBeaver.error("Unsuccessful status code: \(statusCode) request: \(request) body: \(bodyText)")
                return
            }
        }

        SwiftyBeaver.error("Unsuccessful status code: \(statusCode) request: \(request)")
    }
}
