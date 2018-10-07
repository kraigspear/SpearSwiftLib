//
//  EventTrackable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/7/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public protocol EventTrackable {
    func track(_ event: String, properties: [String: String])
    func track(_ event: String)
}
