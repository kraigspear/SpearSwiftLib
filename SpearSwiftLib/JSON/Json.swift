//
//  Json.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/30/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

// MARK: - Alias

///The base type of Json a key value pair
public typealias JsonKeyValue = Dictionary<String, AnyObject>
///Block for receving a JsonKeyValue
public typealias JsonBlock = ((json:JsonKeyValue) -> Void)

// MARK: - Errors

public enum EnumFieldError: ErrorType {
	case MissingField(fieldName: String)
	case ConversionError(fieldName: String)
	case DateParseError(fieldName: String)
}

// MARK: - JsonExtractiable


/**
   A protocol that can extract JSON
*/
public protocol JsonExtractiable {
	
	typealias ExtractedType
	
	///The JsonKeyValue to extract data from
	var jsonData: JsonKeyValue {get}
	
	func extract() throws -> ExtractedType
	
}

// MARK: - Fields

/**
The possible Data Types that can be extracted from JSON
*/
public enum FieldType {
	case Int
	case Float
	case String
	case StringArray
    case JsonKeyValueArray
	case JsonKeyValue
}

/**
 A field inside of a JSON
*/
public protocol JsonFieldable {
	///The name of the field in JSON that can be used to extract the value
	var fieldName: String {get}
	///The type of the field that allows extracting in a type safe manor
	var fieldType: FieldType {get}
}

// MARK: - Extracting

/**
  Extension to extract a value from a JsonKeyValue in a type safe mannor
*/
public extension JsonFieldable {
	
	/**
	Extract a value from a JsonKeyValue
	- Parameter keyValue: The source of the data to extract the value from
	- Throws: `EnumFieldError.ConversionError` If the value can't be convered from the field type
	*/
	public func extract<T>(keyValue: JsonKeyValue) throws -> T {
		
		let val: AnyObject
		
		switch fieldType {
			
		case .Int:
			val = try fetchInt(keyValue)
		case .Float:
			val = try fetchFloat(keyValue)
		case .String:
			val = try fetchString(keyValue)
		case .JsonKeyValueArray:
			let jsonArray: [JsonKeyValue] = try fetchArray(keyValue)
			val = jsonArray
		case .JsonKeyValue:
			val = try fetchJsonKeyValue(keyValue)
		case .StringArray:
			let array: [String] = try fetchArray(keyValue)
			val = array
		}
		
		if let valR = val as? T {
			return valR
		} else {
			throw EnumFieldError.ConversionError(fieldName: self.fieldName)
		}
		
	}
	
	private func fetchJsonKeyValue(keyValue: JsonKeyValue) throws -> JsonKeyValue {
		if let value = keyValue[self.fieldName] as? JsonKeyValue {
			return value
		} else {
			throw EnumFieldError.MissingField(fieldName: self.fieldName)
		}
	}
	
	private func fetchArray<T>(keyValue: JsonKeyValue) throws -> [T] {
		if let value = keyValue[self.fieldName] as? [T] {
			return value
		} else {
			throw EnumFieldError.MissingField(fieldName: self.fieldName)
		}
	}
	
	/**
	Extract a string value from a JsonKeyValue
	- Parameter keyValue: The source of the data to extract the value from
	- Throws: `EnumFieldError.ConversionError` If the value can't be convered from the field type
	*/
	private func fetchString(keyValue: JsonKeyValue) throws -> String {
		if let value = keyValue[self.fieldName] as? String {
			return value
		} else {
			throw EnumFieldError.MissingField(fieldName: self.fieldName)
		}
	}
	
	/**
	Extract a float value from a JsonKeyValue
	- Parameter keyValue: The source of the data to extract the value from
	- Throws: `EnumFieldError.ConversionError` If the value can't be convered from the field type
	*/
	private func fetchFloat(keyValue: JsonKeyValue) throws -> Float {
		let strValue = try fetchString(keyValue)
		
		if let floatValue = Float(strValue) {
			return floatValue
		} else {
			throw EnumFieldError.ConversionError(fieldName: self.fieldName)
		}
	}
	
	/**
	Extract a Int value from a JsonKeyValue
	- Parameter keyValue: The source of the data to extract the value from
	- Throws: `EnumFieldError.ConversionError` If the value can't be convered from the field type
	*/
	private func fetchInt(keyValue: JsonKeyValue) throws -> Int {
		
		let strValue = try fetchString(keyValue)
		
		if let intValue = Int(strValue) {
			return intValue
		} else {
			throw EnumFieldError.ConversionError(fieldName: self.fieldName)
		}
		
	}
	
}

/**
  Type safe extraction of a JsonFieldable from the jsonData member
*/
public extension JsonExtractiable {
	
	func extract<T>(field: JsonFieldable) throws -> T {
		return try field.extract(jsonData)
	}
	
	func extract<T>(field: JsonFieldable, defaultValue: T) throws -> T {
		
		do {
			return try field.extract(jsonData)
		} catch {
			return defaultValue
		}
		
	}
	
	func extractString(field: JsonFieldable) throws -> String {
		return try field.fetchString(jsonData)
	}
	
	func extractFloat(field: JsonFieldable) throws -> Float {
		return try field.fetchFloat(jsonData)
	}
	
	func extractInt(field: JsonFieldable) throws -> Int {
		return try field.fetchInt(jsonData)
	}
}
