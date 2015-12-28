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
        return halfDegrees * self / M_PI
    }
    
    public func toRadians() -> Double {
        return M_PI * self / halfDegrees
    }
}