//
//  CollectionExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public func AllSameSize(_ arraysToCheck: Array<AnyObject>...) -> Bool {
    guard let firstItem = arraysToCheck.first else {
        return false
    }

    let count = firstItem.count

    for i in 1 ..< arraysToCheck.count {
        let array = arraysToCheck[i]
        if array.count != count {
            return false
        }
    }

    return true
}

public extension Array {
    /// Do any of the items in this array match
    /// - Parameter fn: Closure to check
	func any(_ fn: (Element) -> Bool) -> Bool {
        for e in self {
            if fn(e) {
                return true
            }
        }
        return false
    }

	func first(_ fn: (Element) -> Bool) -> Element? {
        for e in self {
            if fn(e) {
                return e
            }
        }
        return nil
    }

    /**
     Return the item at a specific index, or nil if the index is not valid

     - Parameter index: The index to check / retrieve

     - Returns: The item at the index, or nil if the index is not valid
     */
	func at(_ index: Int) -> Element? {
        guard isValidIndex(index) else {
            return nil
        }

        return self[index]
    }

	func isValidIndex(_ index: Int) -> Bool {
        if index < 0 {
            return false
        }
        return index <= count - 1
    }
}
