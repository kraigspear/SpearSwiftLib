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
	public func contains(otherString: String) -> Bool
	{
		return self.rangeOfString(otherString) != nil
	}
	
	public func any(equalTo:String...) -> Bool
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
	
	mutating public func left(numberOfChars:Int)
	{
		self.removeAtIndex(self.endIndex.predecessor())
	}
}