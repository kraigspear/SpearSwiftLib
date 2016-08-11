//
//  DictionaryExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/15/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public enum DictionaryConvertError : Error {
    case missingKey
    case conversionError
}

public extension Dictionary   {
    
    public func toFloat(_ key:Key) -> Float? {
        
        if let valStr = self[key] as? String {
            return Float(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.floatValue
        } else {
            return nil
        }
    }
    
    
    public func toDouble(_ key:Key) -> Double? {
        
        if let valStr = self[key] as? String {
            return Double(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.doubleValue
        } else {
            return nil
        }
    }
    
    public func toDate(_ key:Key) -> Date? {
        
        if let dblValue:Double = self.toDouble(key) {
            return Date(timeIntervalSince1970: dblValue)
        } else {
            return nil
        }
    }

    public func unwrappedValue(_ key:Key) throws -> Value {

        guard let value = self[key] else {
            throw DictionaryConvertError.missingKey
        }

        return value
    }

    /**
     Converts a value from the dictionary to an Int
     - Parameter key: The key from the dictionary to get the Int from
     - Returns: Converted Int
     - Throws: DictionaryConvertError.ConversionError if the value can't be converted to a Int
     */
    public func toInt(_ key:Key) throws -> Int {

        let value = try self.unwrappedValue(key)

        if let valStr = value as? String {
            
            if let intVal = Int(valStr) {
                return intVal
            } else {
                throw DictionaryConvertError.conversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.intValue
        } else {
            return 0
        }

    }
    
    public func toDate(_ key:Key) throws -> Date {
        let value = try self.unwrappedValue(key)
        
        if let dateVal = value as? Date {
            return dateVal
        }
        
        let dblValue:Double = try self.toDouble(key)
        
        return Date(timeIntervalSince1970: dblValue)
    }
    
    public func toString(_ key:Key) throws -> String {
        let value = try self.unwrappedValue(key)
        if let strValue = value as? String {
            return strValue
        }
        throw DictionaryConvertError.conversionError
    }
    
    /**
     Converts a value from the dictionary to a bool
     - Parameter key: The key from the dictionary to get the bool from
     - Returns: Converted Bool
     - Throws: DictionaryConvertError.ConversionError if the value can't be converted to a bool
     */
    public func toBool(_ key:Key) throws -> Bool {
        
        guard let value = try self.unwrappedValue(key) as? NSNumber else {
            throw DictionaryConvertError.conversionError
        }
        
        return value.boolValue
    }
    
    /**
     Converts a value from the dictionary to a float
     - Parameter key: The key from the dictionary to get the float from
     - Returns: Converted float
     - Throws: DictionaryConvertError.ConversionError if the value can't be converted to a float
    */
    public func toFloat(_ key:Key) throws -> Float {
        
        let value = try self.unwrappedValue(key)
       
        if let valStr = value as? String {
            
            if let floatVal = Float(valStr) {
                return floatVal
            } else {
                throw DictionaryConvertError.conversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.floatValue
        } else {
            return 0.0
        }
        
    }
    
    public func toDouble(_ key:Key) throws -> Double {
        
        let value = try self.unwrappedValue(key)
        
        if let valStr = value as? String {
            
            if let dblValue = Double(valStr) {
                return dblValue
            } else {
                throw DictionaryConvertError.conversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.doubleValue
        } else {
            return 0.0
        }
        
    }

    public func toInt(_ key:Key) -> Int? {

        if let valStr = self[key] as? String {
            return Int(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.intValue
        } else {
            return nil
        }
    }
}
