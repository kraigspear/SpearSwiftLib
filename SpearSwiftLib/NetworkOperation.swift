//
//  NetworkOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

///The base type of Json a key value pair
public typealias JsonKeyValue = Dictionary<String, AnyObject>
///Block for receving a JsonKeyValue
public typealias JsonBlock = ((json:JsonKeyValue) -> Void)
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

///Fetches JSON async.
public protocol JSONFetcher {

    ///  fetchJSON: Fetches JSON calling success with the JSON on success, or failure if there was an error getting the JSON
    ///
    ///  - parameter success:Called with the JSON on success
    ///  - parameter failure:Called with an error when there was an error getting the JSON
    func fetchJSON(success: JsonBlock, failure: ErrorBlock)
}

/**

*/
public class NetworkOperation: JSONFetcher {

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

        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in

            if let unwrapError = error {
                print(unwrapError.localizedDescription)
            }

            if let unwrapResponse = response as? NSHTTPURLResponse {
                if unwrapResponse.statusCode != 200 {
                    self.fetchError = FetchError.HTTPError(unwrapResponse.statusCode)
                } else if let unwrapData = data {
                    do {
                        if let jsonObject = try NSJSONSerialization.JSONObjectWithData(unwrapData, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject> {
                            success(json: jsonObject)
                        }
                    } catch let jsonError as NSError {
                        failure(error: FetchError.JSONError(jsonError))
                    }
                }
            }
        }

        task.resume()
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