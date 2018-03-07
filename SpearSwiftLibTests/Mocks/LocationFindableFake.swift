//
//  LocationFindableFake.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 12/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation
@testable import SpearSwiftLib

public final class LocationFindableFake {
    private var findCalled = 0
    private var resultValue: ResultHavingType<FoundLocationType>!
}

// MARK: - Setups

extension LocationFindableFake {
    public func setupResult(_ value: ResultHavingType<FoundLocationType>) {
        resultValue = value
    }
}

// MARK: - Expects

extension LocationFindableFake {
    func expectFindCalled(_ value: Int) -> Bool {
        return value == findCalled
    }
}

// MARK: - LocationFindable

extension LocationFindableFake: LocationFindable {
    public func find(accuracy _: CLLocationAccuracy,
                     result: @escaping (ResultHavingType<FoundLocationType>) -> Void) {
        findCalled += 1
        result(resultValue)
    }
}
