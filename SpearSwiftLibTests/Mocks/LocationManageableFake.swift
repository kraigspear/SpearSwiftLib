//
//  LocationManagableFake.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 12/2/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation
@testable import SpearSwiftLib

final class LocationManageableFake {
    private var isLocationServicesEnabledValue: Bool!
    private var authorizationStatusValue: CLAuthorizationStatus!
    private var requestLocationCalled = 0
    private var requestWhenInUseAuthorizationCalled = 0

    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyThreeKilometers

    var delegate: LocationManagerDelegate?
}

extension LocationManageableFake: LocationManageable {
    var isLocationServicesEnabled: Bool {
        return isLocationServicesEnabledValue
    }

    var authorizationStatus: CLAuthorizationStatus {
        return authorizationStatusValue
    }

    func requestLocation() {
        requestLocationCalled += 1
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled += 1
    }
}

// MARK: - Setups

extension LocationManageableFake {
    func setupIsLocationServicesEnabledValue(_ value: Bool) {
        isLocationServicesEnabledValue = value
    }

    func setupAuthorizationStatusValue(_ value: CLAuthorizationStatus) {
        authorizationStatusValue = value
    }

    func setupLocationsAreReturned(_ value: [CLLocation], afterSeconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + afterSeconds) { [unowned self] in
            self.delegate?.onLocationsFound(value)
        }
    }

    func setupForStatusChanged(_ value: CLAuthorizationStatus, afterSeconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + afterSeconds) { [unowned self] in
            self.delegate?.onAuthorizationStatusChanged(value)
        }
    }

    func setupForErrorRaised(_ value: Error, afterSeconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + afterSeconds) { [unowned self] in
            self.delegate?.onLocationManagerError(value)
        }
    }
}

// MARK: - Expects

extension LocationManageableFake {
    func expectRequestLocationCalled(times: Int) -> Bool {
        return requestLocationCalled == times
    }

    func expectRequestWhenInUseAuthorizationCalled(times: Int) -> Bool {
        return requestWhenInUseAuthorizationCalled == times
    }
}
