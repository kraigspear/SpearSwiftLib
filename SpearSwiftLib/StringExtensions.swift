//
//  StringExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/17/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

extension String
{
	public func any(_ equalTo:String...) -> Bool
	{
		for astr in equalTo
		{
			if self.contains(astr)
			{
				return true
			}
		}
		return false
	}
	
	public var isInt: Bool {
		return Int(self) != nil
	}
	
	mutating public func left(_ numberOfChars:Int)
	{
		self.remove(at: self.index(before: self.endIndex))
	}
}
