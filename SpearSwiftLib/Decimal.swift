//
//  Decimal.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/14/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

extension Decimal {
	/// Convert this Decimal to a Double
	public func toDouble() -> Double {
		return Double(truncating: self as NSNumber)
	}
	
	public func toInt() -> Int {
		return Int(truncating: self as NSNumber)
	}
}
