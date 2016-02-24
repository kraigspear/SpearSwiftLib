//
//  CollectionExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public func AllSameSize(arraysToCheck: Array<AnyObject>...) -> Bool {
	
	guard let firstItem = arraysToCheck.first else {
		return false
	}
	
	let count = firstItem.count
	
	for i in 1..<arraysToCheck.count {
		let array = arraysToCheck[i]
		if array.count != count {
			return false
		}
	}
	
	return true
}

public extension Array
{
    ///Do any of the items in this array match
    ///- Parameter fn: Closure to check
    public func any(fn: (Element) -> Bool ) -> Bool
    {
        for e in self
        {
            if fn(e)
            {
                return true
            }
        }
        return false
    }
    
    public func first(fn: (Element) -> Bool) -> Element? {
        for e in self {
            if fn(e) {
               return e
            }
        }
        return nil
    }
    
    public func isValidIndex(index:Int) -> Bool {
        if index < 0 {
            return false
        }
        return index <= self.count - 1
    }
}