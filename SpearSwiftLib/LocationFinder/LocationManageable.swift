//
//  LocationManageable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/2/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Combine
import CoreLocation
import os.log

/// Error when finding the current location
public enum LocationFindError: Error {
    /// Location services are not enabled
    case locationServiceNotEnabled
    /// Permissions have not been given to get the current location
    case notAuthorized
    /// CLLocationManagerDelegate return an error
    case locationManagerError(error: Error)
}

protocol LocationManagerDelegate: AnyObject {
    func onLocationsFound(_ location: [CLLocation])
    func onAuthorizationStatusChanged(_ status: CLAuthorizationStatus)
    func onLocationManagerError(_ error: Error)
}

public typealias LocationAuthorizationStatus = CurrentValueSubject<CLAuthorizationStatus, Error>

/// Wrapper around CLLocationManager for testing
protocol LocationManageable: AnyObject {
    /// Current locations found
    var foundLocations: AnyPublisher<[CLLocation], Error> { get }
    var isLocationServicesEnabled: Bool { get }
    var authorizationStatus: LocationAuthorizationStatus { get }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var delegate: LocationManagerDelegate? { get set }
    func requestLocation()
    func requestWhenInUseAuthorization()
}

final class LocationManager: NSObject, LocationManageable {
    // MARK: - Log

    private let log = Log.location

    // MARK: - Wrapping

    private let coreLocationManager = CLLocationManager()

    // MARK: - AnyCancellable

    /// Cancellable for checking auth status
    private var cancelAuthStatus: AnyCancellable?

    // MARK: - Delegate

    weak var delegate: LocationManagerDelegate?

    /// Called from `CLLocationManagerDelegate` with success or error of the call
    private var didUpdateLocationsSubject = PassthroughSubject<[CLLocation], Error>()
    let authorizationStatus: LocationAuthorizationStatus

    private var didUpdateLocationsCancel: AnyCancellable?

    // MARK: - Init

    public override init() {
        authorizationStatus = LocationAuthorizationStatus(CLLocationManager.authorizationStatus())
        super.init()
        coreLocationManager.allowsBackgroundLocationUpdates = true
        coreLocationManager.delegate = self
    }

    // MARK: - Members

    var desiredAccuracy: CLLocationAccuracy {
        get {
            return coreLocationManager.desiredAccuracy
        }
        set {
            coreLocationManager.desiredAccuracy = newValue
        }
    }

    var isLocationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    // MARK: - Publishers

    public var foundLocations: AnyPublisher<[CLLocation], Error> {
        let log = Log.network

        return Future<[CLLocation], Error> { [weak self] promise in

            guard let self = self else { return }

            guard self.isLocationServicesEnabled else {
                promise(.failure(LocationFindError.locationServiceNotEnabled))
                return
            }

            guard self.authorizationStatus.value.isAuthorized else {
                promise(.failure(LocationFindError.notAuthorized))
                return
            }

            self.didUpdateLocationsCancel = self.didUpdateLocationsSubject.sink(receiveCompletion: { completed in

                switch completed {
                case let .failure(error):
                    os_log("didUpdateLocations completed with error: %{public}s",
                           log: log,
                           type: .info,
                           error.localizedDescription)
                    promise(.failure(error))
                case .finished:
                    os_log("didUpdateLocations completed",
                           log: log,
                           type: .info)
                }

            }) { locations in
                os_log("Locations found: %d",
                       log: log,
                       type: .debug,
                       locations.count)
                promise(.success(locations))
            }

            os_log("Requesting location",
                   log: log,
                   type: .debug)

            self.requestLocation()

        }.eraseToAnyPublisher()
    }

    // MARK: - Methods

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
        os_log("locationManager.didUpdateLocations.count: %d",
               log: log,
               type: .info,
               locations.count)
        didUpdateLocationsSubject.send(locations)
        delegate?.onLocationsFound(locations)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        assert(delegate != nil, "delegate is nil?")
        os_log("locationManager.didFailWithError: with error: %{public}s",
               log: log,
               type: .error,
               error.localizedDescription)
        let locationFindError = LocationFindError.locationManagerError(error: error)
        didUpdateLocationsSubject.send(completion: Subscribers.Completion.failure(locationFindError))
        delegate?.onLocationManagerError(error)
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        assert(delegate != nil, "delegate is nil?")
        os_log("locationManager.didChangeAuthorization: %{public}s",
               log: log,
               type: .info,
               String(describing: status))
        authorizationStatus.send(status)
        delegate?.onAuthorizationStatusChanged(status)
    }
}

extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .restricted, .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}
