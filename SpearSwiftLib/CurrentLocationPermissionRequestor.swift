//
//  CurrentLocationPermissionRequestor.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/20/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation

public enum PermissionResult {
    case whenInUse
    case always
    case notGiven
}

public enum RequestPermission {
    case always
    case whenInUse
}

public typealias LocationPermissionResultClosure = ((PermissionResult) -> Void)

/// Allows checking for current location permissions
public protocol CurrentLocationPermissionRequestable {
    func request(permission: RequestPermission, completed: @escaping LocationPermissionResultClosure)
}

public final class CurrentLocationPermissionRequestor: NSObject {
    fileprivate var locationManager: CLLocationManager?
    fileprivate var onCompleted: LocationPermissionResultClosure?
    fileprivate var permission: RequestPermission!

    public override init() {
        super.init()
    }

    private func initManager() {
        precondition(Thread.isMainThread)
        if locationManager != nil {
            return
        }
        locationManager = CLLocationManager()
        locationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager!.delegate = self
    }

    private func deinitManager() {
        precondition(Thread.isMainThread)
        onCompleted = nil
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.delegate = nil
        self.locationManager = nil
    }

    /// No need to ask for permission because we already have it.
    private var isPermissionAlreadyGiven: Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
}

extension CurrentLocationPermissionRequestor: CurrentLocationPermissionRequestable {
    public func request(permission: RequestPermission, completed: @escaping LocationPermissionResultClosure) {
        initManager()

        onCompleted = completed
        self.permission = permission

        guard isPermissionAlreadyGiven == false else {
            switch permission {
            case .always:
                completed(.always)
            case .whenInUse:
                completed(.whenInUse)
            }
            deinitManager()
            return
        }

        switch permission {
        case .always:
            locationManager!.requestAlwaysAuthorization()
        case .whenInUse:
            locationManager!.requestWhenInUseAuthorization()
        }
    }
}

extension CurrentLocationPermissionRequestor: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let onCompleted = self.onCompleted else { return }

        switch status {
        case .authorizedAlways:
            onCompleted(.always)
        case .authorizedWhenInUse:
            onCompleted(.whenInUse)
        case .notDetermined:
            break
        default:
            onCompleted(.notGiven)
        }

        if status != .notDetermined {
            // We are asking for permissions, so don't deInit.
            deinitManager()
        }
    }
}
