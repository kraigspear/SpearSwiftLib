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
	static let general = OSLog(subsystem: "com.spearware.spearswiftlib", category: "📜General")
	static let network = OSLog(subsystem: "com.spearware.spearswiftlib", category: "🧚‍♀️Network")
	static let sync = OSLog(subsystem: "com.spearware.spearswiftlib", category: "🐸Sync")
	static let location = OSLog(subsystem: "com.spearware.spearswiftlib", category: "🗺Location")
	static let remoteData = OSLog(subsystem: "com.spearware.spearswiftlib", category: "🏓RemoteData")
}
