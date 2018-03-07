//
//  LocationManageable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/2/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate: class {
    func onLocationsFound(_ location: [CLLocation])
    func onAuthorizationStatusChanged(_ status: CLAuthorizationStatus)
    func onLocationManagerError(_ error: Error)
}

protocol LocationManageable: class {
    var isLocationServicesEnabled: Bool { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var delegate: LocationManagerDelegate? { get set }
    func requestLocation()
    func requestWhenInUseAuthorization()
}

final class LocationManager: NSObject {
    private let coreLocationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?

    public override init() {
        super.init()
        coreLocationManager.delegate = self
    }
}

extension LocationManager: LocationManageable {
    var isLocationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    func requestLocation() {
        coreLocationManager.requestLocation()
    }

    func requestWhenInUseAuthorization() {
        coreLocationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        assert(delegate != nil, "delegate is nil?")
        delegate?.onLocationsFound(locations)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        assert(delegate != nil, "delegate is nil?")
        delegate?.onLocationManagerError(error)
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        assert(delegate != nil, "delegate is nil?")
        delegate?.onAuthorizationStatusChanged(status)
    }
}
