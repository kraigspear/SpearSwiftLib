//
//  ClosureTypes.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public typealias VoidBlock = () -> Void
public typealias NSErrorBlock = (error:NSError?) -> Void
public typealias DateBlock = (date:NSDate?) -> Void
public typealias DateErrorBlock = (date:NSDate?, error:NSError?) -> Void

