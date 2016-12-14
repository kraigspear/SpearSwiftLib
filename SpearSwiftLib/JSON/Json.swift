//
//  Json.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/30/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import SwiftyBeaver

public enum ConvertError: Error {
	case invalidConversion
}

fileprivate final class DateFormatters {
	static let instance = DateFormatters()
	private init() {}
	lazy var format1: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return dateFormatter
	}()
	
	lazy var format2: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S"
		return dateFormatter
	}()
	
	lazy var format3: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
		return dateFormatter
	}()
}


public extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
	func toInt(_ key: Key) throws -> Int {
		
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
		
		throw ConvertError.invalidConversion
	}
	
	func toFloat(_ key: Key) throws -> Float {
		if let floatVal = self[key] as? Float {
			return floatVal
		}
		
		let strVal = try! self.toString(key)
		
		if let floatVal = Float(strVal) {
			return floatVal
		}
		
		throw ConvertError.invalidConversion
	}
	
	func toDouble(_ key: Key) throws -> Double {
		if let dblValue = self[key] as? Double {
			return dblValue
		}
		
		let strVal = try! self.toString(key)
		
		if let dblValue = Double(strVal) {
			return dblValue
		}
		
		throw ConvertError.invalidConversion
	}
	
	func toString(_ key: Key) throws -> String {
		guard let strVal = self[key] as? String else {
			throw ConvertError.invalidConversion
		}
		return strVal
	}
	
	func toDate(_ key: Key) throws -> Date {
		let strVal = try! toString(key)
		var date = DateFormatters.instance.format1.date(from: strVal)
		if date != nil {return date!}
		date = DateFormatters.instance.format2.date(from: strVal)
		if date != nil {return date!}
		date = DateFormatters.instance.format3.date(from: strVal)
		if date == nil {
			assertionFailure("Unsuppported date format \(strVal)")
		}
		return date!
	}
	
}


// MARK: - Alias

///The base type of Json a key value pair
public typealias JsonKeyValue = Dictionary<String, AnyObject>
///Block for receiving a JsonKeyValue
public typealias JsonBlock = ((_ json:JsonKeyValue) -> Void)

