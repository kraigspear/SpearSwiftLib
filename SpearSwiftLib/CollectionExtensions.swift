//
//  CollectionExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation


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
}