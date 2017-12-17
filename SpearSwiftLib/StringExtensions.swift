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
	
	mutating public func left(_ numberOfChars:Int) {
		self.remove(at: self.index(before: self.endIndex))
	}
	
	public var lastPathComponent: String {
		return NSString(string: self).lastPathComponent
	}
	
	///Converts this string to date if it is a valid zulu date (2017-12-14T13:05:56.796Z)
	public func toDateFromZulu() -> Date? {
		
		for formatter in DateFormatters.instance.zulu {
			if let date = formatter.date(from: self) {
				return date
			}
		}
		
		return nil
	}
}
