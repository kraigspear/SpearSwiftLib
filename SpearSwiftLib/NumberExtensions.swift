//
//  NumberExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/25/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

let halfDegrees = 180.0

extension Double {
    
    public func toDegrees() -> Double {
        return halfDegrees * self / Double.pi
    }
    
    public func toRadians() -> Double {
        return Double.pi * self / halfDegrees
    }
}
