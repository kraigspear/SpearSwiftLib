//
//  DictionaryExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/15/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public extension Dictionary  {
    
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
        
        if let dblValue = self.toDouble(key) {
            return NSDate(timeIntervalSince1970: dblValue)
        } else {
            return nil
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
