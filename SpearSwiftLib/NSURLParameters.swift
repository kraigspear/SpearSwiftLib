//
//  NSURLParameters.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

public struct NetworkParameters: NetworkParameterType {
    private var keys: [String] = []
    private var values: [String] = []

    public init() {}

    @discardableResult
    public mutating func addParam(_ key: String, value: String) -> NetworkParameterType {
        assert(keys.count == values.count)
        keys.append(key)
        values.append(value)
        assert(keys.count == values.count)
        return self
    }

    public func stringFromQueryParameters() -> String {
        var parts: [String] = []

        assert(keys.count == values.count)

        for i in 0 ..< keys.count {
            let key = keys[i]
            let value = values[i]

            let nameStr = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let valueStr = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

            let part = NSString(format: "%@=%@",
                                nameStr,
                                valueStr)
            parts.append(part as String)
        }

        return parts.joined(separator: "&")
    }

    public func NSURLByAppendingQueryParameters(_ url: URL) -> URL {
        let URLString: NSString = NSString(format: "%@?%@", url.absoluteString, stringFromQueryParameters())
        return URL(string: URLString as String)!
    }
}
