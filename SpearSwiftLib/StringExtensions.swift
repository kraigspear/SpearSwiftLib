//
//  StringExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/17/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

extension String {
    public var isInt: Bool {
        return Int(self) != nil
    }

    public mutating func left(_: Int) {
        remove(at: index(before: endIndex))
    }

    public var lastPathComponent: String {
        return NSString(string: self).lastPathComponent
    }

    /// Converts this string to date if it is a valid zulu date (2017-12-14T13:05:56.796Z)
    public func toDateFromZulu() -> Date? {
        for formatter in DateFormatters.instance.zulu {
            if let date = formatter.date(from: self) {
                return date
            }
        }

        return nil
    }
	
	/// True if this string contains a decimal seperator
	public var containsDecimalSeperator: Bool {
		let decimal = Locale.current.decimalSeparator ?? "."
		return self.contains(decimal)
	}
	
	public mutating func appendPath(_ value: String) {
		
		let pathSeperator = "/"
		
		guard let last = self.last else { return }
		let s = String(last)
		
		if s != pathSeperator {
		   self += pathSeperator
		}
		
		self += value
	}
	
}
