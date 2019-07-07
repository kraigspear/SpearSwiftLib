//
//  ElaspedTime.swift
//  SpearSwiftLib
//
//  Created by Spear, Kraig on 5/10/19.
//  Copyright © 2019 Meijer. All rights reserved.
//

import Foundation

/// Tracks elasped time between a start and end time
public struct ElaspedTime: CustomStringConvertible {
    private var startTime = CFAbsoluteTimeGetCurrent()
    private var endTime = CFAbsoluteTimeGetCurrent()

    private(set) var timeElasped: CFAbsoluteTime = 0.0

    public init() {}

    public mutating func start() {
        timeElasped = 0.0
        startTime = CFAbsoluteTimeGetCurrent()
    }

    @discardableResult
    public mutating func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        timeElasped = endTime - startTime
        return timeElasped
    }

    public var description: String {
        return "Started: \(startTime) Ended: \(endTime) Elapsed: \(timeElasped)"
    }
}
