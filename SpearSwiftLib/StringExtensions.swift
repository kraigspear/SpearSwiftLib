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
	public var isInt: Bool {
		return Int(self) != nil
	}
	
	mutating public func left(_ numberOfChars:Int)
	{
		self.remove(at: self.index(before: self.endIndex))
	}
	
	public var lastPathComponent: String {
		return NSString(string: self).lastPathComponent
	}
}
