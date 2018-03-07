//
// Created by Kraig Spear on 6/1/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

/// Parameters used in a network query
public protocol NetworkParameterType {
    /**
     Adds a parameter

     - parameter key: Key of the value being added
     - parameter value: Value being added
     - returns: Reference to this NetworkParameterType that can be used to chain parameters together
     */
    mutating func addParam(_ key: String, value: String) -> NetworkParameterType
    /**
     Generates a string for all parameters that can be used in a URL

     - returns: A string for all parameters that can be used in a URL
     */
    func stringFromQueryParameters() -> String
    /**
     Generate a URL from the current state of this NetworkParameterType

     - parameter url: A base URL that parameters are added to

     ```swift
     guard var url = URL(string: urlStr) else {
     throw FetchError.invalidUrl(urlStr)
     }

     url = parameters.NSURLByAppendingQueryParameters(url)
     var request = URLRequest(url: url)
     ```
     */
    func NSURLByAppendingQueryParameters(_ url: URL) -> URL
}
