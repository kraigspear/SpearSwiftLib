//
//  OrderedDictionary.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/1/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation


public struct OrderedDictionary<KeyType: Hashable, ValueType> {
	typealias ArrayType = [KeyType]
	typealias DictionaryType = [KeyType: ValueType]
	
	private var array = ArrayType()
	private var dictionary = DictionaryType()
	
	public init() {}
	
	public mutating func insert(value: ValueType, key: KeyType)  {
		let existingValue = dictionary[key]
		
		if existingValue == nil {
			array.append(key)
		}
		
		dictionary[key] = value
	}
	
	public var count: Int {
		return array.count
	}
	
	public subscript(key: KeyType) -> ValueType? {
		get {
			return dictionary[key]
		}
		set {
			insert(newValue!, key: key)
		}
	}
	
	public subscript(index: Int) -> (key: KeyType, value: ValueType) {
		get {
			precondition(index < array.count, "Index out of bounds")
			let key = array[index]
			let value = dictionary[key]!
			return (key, value)
		}
	}
}