//
// Created by Kraig Spear on 6/2/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation
import os.log

open class NetworkDownloadOperation<Type>: BaseOperation {
    private let requestBuilder: RequestBuildable
    private let timeout: Double
    private var pinningCert: Data?

    public private(set) var result: Type?

    private var task: URLSessionDataTask!

    private let log = Log.network

    public init(requestBuilder: RequestBuildable,
                timeout: Double = 10.0,
                pinningCertTo: Data? = nil) {
        self.requestBuilder = requestBuilder
        self.timeout = timeout
        pinningCert = pinningCertTo
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
				
				os_log("equest cancelled:: %s",
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
        session.finishTasksAndInvalidate()
    }

    /**
     Convert data from the network into a specific type (Image, JSON ext....)
     */
    open func convertTo(_: Data) -> Type? {
        fatalError("Override in child class")
    }
}
