//
//  CurrentDateTime.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 2/26/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

public protocol CurrentDateFetchable {
    func currentDateTime() -> Date
}

public struct CurrentDateFetcher: CurrentDateFetchable {
    public init() {
    }

    public func currentDateTime() -> Date {
        return Date()
    }
}
