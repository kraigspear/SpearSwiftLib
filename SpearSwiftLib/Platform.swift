//
//  Platform.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/17/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation

/// Information about the platform that is being run on
public struct Platfrom {
    /// True if the platform is a simulator and not a real device
    public static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
