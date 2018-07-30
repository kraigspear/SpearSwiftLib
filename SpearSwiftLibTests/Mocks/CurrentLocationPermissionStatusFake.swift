//
//  CurrentLocationPermissionStatusFake.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 4/17/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import CoreLocation
import Foundation
@testable import SpearSwiftLib

public final class CurrentLocationPermissionStatusFake: CurrentLocationPermissionStatusProtocol {
    public var authorizationStatusValue: CLAuthorizationStatus!

    public var authorizationStatus: CLAuthorizationStatus {
        return authorizationStatusValue
    }
}
