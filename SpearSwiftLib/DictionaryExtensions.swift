//
//  DictionaryExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/15/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public enum DictionaryConvertError : ErrorType {
    case MissingKey
    case ConversionError
}

public extension Dictionary   {
    
    public func toFloat(key:Key) -> Float? {
        
        if let valStr = self[key] as? String {
            return Float(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.floatValue
        } else {
            return nil
        }
    }
    
    
    public func toDouble(key:Key) -> Double? {
        
        if let valStr = self[key] as? String {
            return Double(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.doubleValue
        } else {
            return nil
        }
    }
    
    public func toDate(key:Key) -> NSDate? {
        
        if let dblValue:Double = self.toDouble(key) {
            return NSDate(timeIntervalSince1970: dblValue)
        } else {
            return nil
        }
    }

    public func unwrappedValue(key:Key) throws -> Value {

        guard let value = self[key] else {
            throw DictionaryConvertError.MissingKey
        }

        return value
    }

    /**
     Converts a value from the dictionary to an Int
     - Parameter key: The key from the dictionary to get the Int from
     - Returns: Converted Int
     - Throws: DictionaryConvertError.ConversionError if the value can't be converted to a Int
     */
    public func toInt(key:Key) throws -> Int {

        let value = try self.unwrappedValue(key)

        if let valStr = value as? String {
            
            if let intVal = Int(valStr) {
                return intVal
            } else {
                throw DictionaryConvertError.ConversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.integerValue
        } else {
            throw DictionaryConvertError.ConversionError
        }

    }
    
    public func toDate(key:Key) throws -> NSDate {
        let value = try self.unwrappedValue(key)
        
        if let dateVal = value as? NSDate {
            return dateVal
        }
        
        let dblValue:Double = try self.toDouble(key)
        
        return NSDate(timeIntervalSince1970: dblValue)
    }
    
    /**
     Converts a value from the dictionary to a float
     - Parameter key: The key from the dictionary to get the float from
     - Returns: Converted float
     - Throws: DictionaryConvertError.ConversionError if the value can't be converted to a float
    */
    public func toFloat(key:Key) throws -> Float {
        
        let value = try self.unwrappedValue(key)
        
        if let valStr = value as? String {
            
            if let floatVal = Float(valStr) {
                return floatVal
            } else {
                throw DictionaryConvertError.ConversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.floatValue
        } else {
            throw DictionaryConvertError.ConversionError
        }
        
    }
    
    public func toDouble(key:Key) throws -> Double {
        
        let value = try self.unwrappedValue(key)
        
        if let valStr = value as? String {
            
            if let dblValue = Double(valStr) {
                return dblValue
            } else {
                throw DictionaryConvertError.ConversionError
            }
            
        } else if let valNum = value as? NSNumber {
            return valNum.doubleValue
        } else {
            throw DictionaryConvertError.ConversionError
        }
        
    }



    public func toInt(key:Key) -> Int? {

        if let valStr = self[key] as? String {
            return Int(valStr)
        } else if let valNum = self[key] as? NSNumber {
            return valNum.integerValue
        } else {
            return nil
        }
    }
}
