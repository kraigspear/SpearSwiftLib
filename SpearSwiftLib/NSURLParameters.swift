//
//  NSURLParameters.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

public struct NetworkParameters: NetworkParameterType {
	private var params: [String:String] = [:]
	
	public init() {}
	
	public mutating func addParam(key: String, value: String) -> NetworkParameterType {
		params[key] = value
		return self
	}
	
	public func stringFromQueryParameters() -> String {
		var parts: [String] = []
		
		for (name, value) in params {
			
			let nameStr = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			
			let valueStr = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			
			let part = NSString(format: "%@=%@",
			                    nameStr,
			                    valueStr)
			parts.append(part as String)
		}
		
		return parts.joinWithSeparator("&")
	}
	
	public func NSURLByAppendingQueryParameters(url: NSURL) -> NSURL {
		let URLString: NSString = NSString(format: "%@?%@", url.absoluteString, stringFromQueryParameters())
		return NSURL(string: URLString as String)!
	}
}