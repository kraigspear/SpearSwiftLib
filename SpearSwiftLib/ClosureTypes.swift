//
//  ClosureTypes.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public enum ResultHavingType<T> {
	case success(result: T)
	case error(error: Error)
}

public enum NetworkResult<T> {
	case success(result: T)
	case error(error: Error)
	case response(code: Int)
}

public enum Result {
	case success
	case error(error: Error)
}

public typealias ResultBlock = (Result) -> Void
public typealias ResultHavingTypeBlock = (ResultHavingType<Any>) -> Void
public typealias VoidBlock = () -> Void
public typealias NSErrorBlock = (_ error:NSError?) -> Void
public typealias DateBlock = (_ date:Date?) -> Void
public typealias DateErrorBlock = (_ date:Date?, _ error:NSError?) -> Void

