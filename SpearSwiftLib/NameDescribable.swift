//
//  NameDescribable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/2/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import Foundation

/// Provides the type name of the type implementing
public protocol NameDescribable {
	var typeName: String { get }
	static var typeName: String { get }
}

public extension NameDescribable {
	var typeName: String {
		return String(describing: type(of: self))
	}
	
	static var typeName: String {
		return String(describing: self)
	}
}
