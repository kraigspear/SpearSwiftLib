//
//  SyncType.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/26/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

/// Value in local database that indicates what needs to be synched on each record
public enum SyncType: Int16 {
    case notNeeded = 0
    case insert = 1
    case update = 2
    case delete = 3
}
