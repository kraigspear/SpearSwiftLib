//
//  Log.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/28/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation
import os.log

struct Log {
    static let general = OSLog(subsystem: "com.spearware.thunderful.fastcast", category: "📜General")
    static let network = OSLog(subsystem: "com.spearware.thunderful.fastcast", category: "🧚‍♀️Network")
}
