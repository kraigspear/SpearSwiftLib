//
//  Json.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/30/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

public enum ConvertError: ErrorType {
	case InvalidConversion
}

public extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
	func toInt(key: Key) throws -> Int {
		
		if let intVal = self[key] as? Int {
			return intVal
		}
		
		let strVal = try! self.toString(key)
		if let intVal = Int(strVal) {
			return intVal
		}
		
		if let dblValue = Double(strVal) {
			return Int(dblValue)
		}
		
		throw ConvertError.InvalidConversion
	}
	
	func toFloat(key: Key) throws -> Float {
		if let floatVal = self[key] as? Float {
			return floatVal
		}
		
		let strVal = try! self.toString(key)
		
		if let floatVal = Float(strVal) {
			return floatVal
		}
		
		throw ConvertError.InvalidConversion
	}
	
	func toDouble(key: Key) throws -> Double {
		if let dblValue = self[key] as? Double {
			return dblValue
		}
		
		let strVal = try! self.toString(key)
		
		if let dblValue = Double(strVal) {
			return dblValue
		}
		
		throw ConvertError.InvalidConversion
	}
	
	func toString(key: Key) throws -> String {
		guard let strVal = self[key] as? String else {
			throw ConvertError.InvalidConversion
		}
		return strVal
	}
	
	func toDate(key: Key) throws -> NSDate {
		let dblDate = try! toDouble(key)
		return NSDate(timeIntervalSince1970: dblDate)
	}
	
}


// MARK: - Alias

///The base type of Json a key value pair
public typealias JsonKeyValue = Dictionary<String, AnyObject>
///Block for receving a JsonKeyValue
public typealias JsonBlock = ((json:JsonKeyValue) -> Void)

