//
//  DateMathProtocol.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/15/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import Foundation


/// Common date math routines
public protocol DateMathProtocol {
	func numberOfMinutesBetweenNow(_ date: Date) -> Int
}

public final class DateMath: DateMathProtocol {
	
	public init() {}
	
	public func numberOfMinutesBetweenNow(_ date: Date) -> Int {
		date.numberOfMinutesBetweenNow()
	}
}
