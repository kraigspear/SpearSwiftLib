//
//  ClosureTypes.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

/**
 Errors from a network call
 */
public enum NetworkError: Error {
    /// The status code is not 200
    case statusCodeError(statusCode: Int)
    case nilData
    case jsonElementNotFoundOrExpectedType
}

public enum ResultHavingType<T> {
    case success(result: T)
    case error(error: Error)
}

public enum NetworkResult<T> {
    case success(result: T)
    case error(error: Error)
    case response(code: Int)
}

public enum Result: CustomStringConvertible {
    case success
    case error(error: Error)
    public var description: String {
        switch self {
        case .success:
            return "Success"
        case let .error(error: error):
            return "Error \(error.localizedDescription)"
        }
    }
}

public typealias ResultBlock = (Result) -> Void
public typealias ResultHavingTypeBlock = (ResultHavingType<Any>) -> Void
public typealias VoidBlock = () -> Void
public typealias BoolBlock = (Bool) -> Void
public typealias NSErrorBlock = (_ error: NSError?) -> Void
public typealias DateBlock = (_ date: Date?) -> Void
public typealias DateErrorBlock = (_ date: Date?, _ error: NSError?) -> Void
