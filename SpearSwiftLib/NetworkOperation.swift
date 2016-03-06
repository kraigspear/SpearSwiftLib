//
//  NetworkOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

///Block for receving an error
public typealias ErrorBlock = ((error:ErrorType) -> Void)

/**
  Errors that can happen when fetching data.
  - HTTPError: Any status other than 200
  - JSONError: The data received could not be converted into JSON
  - None: An error was not received
*/
public enum FetchError: ErrorType {

    case HTTPError(Int)
    case JSONError(NSError)
    case None
}

/**
 Fetch JSON from a source, such as a file or network operation
*/
public protocol JSONFetchable {

    ///  fetchJSON: Fetches JSON calling success with the JSON on success, or failure if there was an error getting the JSON
    ///
    ///  - parameter success:Called with the JSON on success
    ///  - parameter failure:Called with an error when there was an error getting the JSON
    func fetchJSON(success: JsonBlock, failure: ErrorBlock)
}

/**
  A network operation that fetches JSON
*/
public final class NetworkOperation: JSONFetchable {

    private let urlStr: String
    private var params: [String:String] = [:]

    public var fetchError: FetchError = FetchError.None

    public func addParam(key: String, value: String) {
        params[key] = value
    }

    public init(urlStr: String) {
        self.urlStr = urlStr
    }

    public func fetchJSON(success: JsonBlock, failure: ErrorBlock) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var URL = NSURL(string: self.urlStr)
        URL = NSURLByAppendingQueryParameters(URL!)

        let request = NSMutableURLRequest(URL: URL!)
		
		let handler = {[weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
			
			if let error = error {
				print(error)
				if let cachedData = self?.fetchCachedResponseData(request) {
					do {
						if let cachedJson = try self?.jsonFromData(cachedData) {
							success(json: cachedJson)
						}
					} catch let jsonCachedError as NSError {
						failure(error: FetchError.JSONError(jsonCachedError))
					}
					
				} else {
					failure(error: FetchError.HTTPError(error.code))
				}
				return
			}
			
			if let response = response as? NSHTTPURLResponse {
				if response.statusCode != 200 {
					self?.fetchError = FetchError.HTTPError(response.statusCode)
					failure(error: FetchError.HTTPError(response.statusCode))
				} else if let data = data {
					
					self?.storeReponse(request, response: response, data: data)
					
					do {
						if let jsonObject = try self?.jsonFromData(data) {
							success(json: jsonObject)
						}
					} catch let jsonError as NSError {
						failure(error: FetchError.JSONError(jsonError))
					}
				}
			}

		}

		let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
    }
	
	private func jsonFromData(data: NSData) throws -> JsonKeyValue? {
		return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject>
	}
	
	/**
	Store a response to the cache that can then be loaded later
	- Parameter request: The request to cache
	- Parameter response: The reponse to cache
	- Parameter data: The data to cache
	*/
	private func storeReponse(request: NSURLRequest, response: NSURLResponse, data: NSData) {
		let cached = NSCachedURLResponse(response: response, data: data)
		NSURLCache.sharedURLCache().storeCachedResponse(cached, forRequest: request)
	}
	
	/**
	Fetch a previously stored cached response
	- Parameter request: The request to fetch
	- Returns: The data for the cached request, or nil if it couldn't be fetched
	*/
	private func fetchCachedResponseData(request: NSURLRequest) -> NSData? {
		guard let cached = NSURLCache.sharedURLCache().cachedResponseForRequest(request) else {
			return nil
		}
		
		return cached.data
	}

    private func stringFromQueryParameters() -> String {
        var parts: [String] = []

        for (name, value) in self.params {

            let nameStr = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

            let valueStr = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

            let part = NSString(format: "%@=%@",
                    nameStr,
                    valueStr)
            parts.append(part as String)
        }

        return parts.joinWithSeparator("&")
    }

    private func NSURLByAppendingQueryParameters(url: NSURL) -> NSURL {
        let URLString: NSString = NSString(format: "%@?%@", url.absoluteString, self.stringFromQueryParameters())
        return NSURL(string: URLString as String)!
    }
}


