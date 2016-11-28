//
//  NetworkOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public typealias NetworkImageDownloadBlock = (_ image: UIImage) -> Void
///Block for receving an error
public typealias ErrorBlock = ((_ error:Error) -> Void)

/**
Errors that can happen when fetching data.
- HTTPError: Any status other than 200
- JSONError: The data received could not be converted into JSON
- ResponseError: An error was return from the network call
- InvalidUrl: The URL wasn't valid
- None: An error was not received
*/
public enum FetchError: Error {
	case httpError(Int)
	case jsonError(Error)
	case invalidUrl(String)
	case responseError(Error)
	case responseNil
	case none
}

public enum ImageFetchError: Error {
	case httpError(Int)
	case responseError(NSError)
}

public typealias ImageFetchErrorBlock = (ImageFetchError) -> Void

/**
Fetch JSON from a source, such as a file or network operation
*/
public protocol JSONFetchable {
	
	///  fetchJSON: Fetches JSON calling success with the JSON on success, or failure if there was an error getting the JSON
	///
	///  - parameter success:Called with the JSON on success
	///  - parameter failure:Called with an error when there was an error getting the JSON
	func fetchJSON(success: @escaping JsonBlock, failure: @escaping ErrorBlock)
}

public enum ResponseCode: Int {
	case success = 200
}

extension HTTPURLResponse {
	var isStatusOk: Bool {
		guard let status = ResponseCode.init(rawValue: statusCode) else {
			return false
		}
		return status == .success
	}
}

extension Data {
	func toImage() -> UIImage? {
		return UIImage(data: self)
	}
}

public enum Method: String {
	case GET = "GET"
	case POST = "POST"
	
	/**
	Sets the method for NSMutableURLRequest
	*/
	func setMethod(_ request: URLRequest) -> URLRequest {
		var r = request
		r.httpMethod = rawValue
		return r
	}
}

//MARK: - Fetch Image
extension NetworkOperation {
	public func fetchUIImage(_ success: @escaping NetworkImageDownloadBlock, failure: @escaping ImageFetchErrorBlock) {
		let request: URLRequest = try! createRequest()
		
		//Add caching
		let handler = {(data: Data?, response: URLResponse?, error: Error?) in
			if let error = error {
				failure(ImageFetchError.responseError(error as NSError))
			} else {
				let urlResponse = (response as! HTTPURLResponse)
				if urlResponse.isStatusOk {
					precondition(data != nil, "We are in a success state, but data is invalid?")
					if let image = data!.toImage() {
						DispatchQueue.main.async {
							success(image)
						}
					}
				} else {
					DispatchQueue.main.async {
						failure(ImageFetchError.httpError(urlResponse.statusCode))
					}
				}
			}
		}
		
		let task = session.dataTask(with: request, completionHandler: handler)
		task.resume()
	}
}

//MARK: - Fetch JSON
extension NetworkOperation {
	public func fetchJSON(success: @escaping JsonBlock, failure: @escaping ErrorBlock) {
		
		let request = try! createRequest()
		
		let handler = {[weak self] (data: Data?, response: URLResponse?, error: Error?) in
			
			if let error = error {
				if let cachedData = self?.fetchCachedResponseData(request as URLRequest) {
					do {
						if let cachedJson = try self?.jsonFromData(cachedData) {
							success(cachedJson)
						}
					} catch let jsonCachedError as NSError {
						failure(FetchError.jsonError(jsonCachedError))
					}
				} else {
					failure(FetchError.responseError(error))
				}
				return
			}
			
			if let response = response as? HTTPURLResponse {
				if response.statusCode != 200 {
					self?.fetchError = FetchError.httpError(response.statusCode)
					failure(FetchError.httpError(response.statusCode))
				} else if let data = data {
					
					self?.storeReponse(request as URLRequest, response: response, data: data)
					
					do {
						if let jsonObject = try self?.jsonFromData(data) {
							success(jsonObject)
						}
					} catch let jsonError as NSError {
						failure(FetchError.jsonError(jsonError))
					}
				}
			}
			
		}
		
		let task = session.dataTask(with: request, completionHandler: handler)
		task.resume()
	}
	
	private func jsonFromData(_ data: Data) throws -> JsonKeyValue? {
		return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
	}
}

public protocol NetworkParameterType {
	mutating func addParam(_ key: String, value: String) -> NetworkParameterType
	func stringFromQueryParameters() -> String
	func NSURLByAppendingQueryParameters(_ url: URL) -> URL
}

public class RequestHeaders {
	private var headers: [String : String] = [ : ]
	
	public func addHeader(_ key: String, value: String) {
		headers[key] = value
	}
	
	public func addJsonHeader() {
		headers["Content-Type"] = "application/json"
	}

	func addToRequest(_ request: URLRequest) -> URLRequest {
		
		var r = request
		
		for (name, value) in headers {
			r.addValue(value, forHTTPHeaderField: name)
		}
		
		return r
	}
}

public class RequestBody {
	internal var json: JsonKeyValue = [:]
	
	public func addValue(_ key: String, value: AnyObject) {
		json[key] = value
	}
	
	func addToRequest(_ request: URLRequest) -> URLRequest {
		
		var r = request
		
		guard json.count >= 1 else {
			return r
		}
		
		r.httpBody = try! JSONSerialization.data(withJSONObject: json, options: [])
		
		return r
	}
}

/**
A network operation that fetches JSON
*/
public final class NetworkOperation: JSONFetchable {
	
	private let urlStr: String
	private var method: Method = .GET
	public var fetchError: FetchError = FetchError.none
	
	public var parameters: NetworkParameterType = NetworkParameters()
	public let body: RequestBody = RequestBody()
	public let headers = RequestHeaders()
	
	//MARK: - Init
	public init(urlStr: String) {
		self.urlStr = urlStr
	}
	
	//MARK: - session
	lazy internal var session: URLSession = {
		let sessionConfig = URLSessionConfiguration.default
		return URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}()
	
	//MARK: - request
	func createRequest() throws -> URLRequest {
		guard var url = URL(string: urlStr) else {
			throw FetchError.invalidUrl(urlStr)
		}
		
		url = parameters.NSURLByAppendingQueryParameters(url)
		
		var request = URLRequest(url: url)
		
		if body.json.count > 0 {
			method = .POST
			request = method.setMethod(request)
		} else {
			method = .GET
		}
		
		request = headers.addToRequest(request)
		request = body.addToRequest(request)
		
		return request
	}
	
	/**
	Store a response to the cache that can then be loaded later
	- Parameter request: The request to cache
	- Parameter response: The reponse to cache
	- Parameter data: The data to cache
	*/
	func storeReponse(_ request: URLRequest, response: URLResponse, data: Data) {
		let cached = CachedURLResponse(response: response, data: data)
		URLCache.shared.storeCachedResponse(cached, for: request)
	}
	
	//MARK: - Cache
	/**
	Fetch a previously stored cached response
	- Parameter request: The request to fetch
	- Returns: The data for the cached request, or nil if it couldn't be fetched
	*/
	internal func fetchCachedResponseData(_ request: URLRequest) -> Data? {
		guard let cached = URLCache.shared.cachedResponse(for: request) else {
			return nil
		}
		return cached.data
	}
}
