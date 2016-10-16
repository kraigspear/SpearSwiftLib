//
//  ClosureTypes.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public typealias VoidBlock = () -> Void
public typealias NSErrorBlock = (_ error:NSError?) -> Void
public typealias DateBlock = (_ date:Date?) -> Void
public typealias DateErrorBlock = (_ date:Date?, _ error:NSError?) -> Void

