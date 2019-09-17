//
//  LocationManageable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/2/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Combine
import CoreLocation
import SwiftyBeaver

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

    private let log = SwiftyBeaver.self
    private let logContext = "📍LocationManager"

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

    /// <#Description#>
    public var isAuthorized: AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in

            guard let self = self else { return }

            self.cancelAuthStatus = self.authorizationStatus.sink(receiveCompletion: { completed in

                switch completed {
                case let .failure(error):
                    promise(.failure(LocationFindError.locationManagerError(error: error)))
                case .finished:
                    break
                }

            }) { status in

                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    promise(.success(true))
                default:
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }

    public var foundLocations: AnyPublisher<[CLLocation], Error> {
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
                    self.log.debug("didUpdateLocations completed with error: \(error.localizedDescription)", context: self.logContext)
                    promise(.failure(error))
                case .finished:
                    self.log.debug("didUpdateLocations completed", context: self.logContext)
                }

            }) { locations in
                self.log.debug("Locations found: \(locations.count)", context: self.logContext)
                promise(.success(locations))
            }

            self.log.debug("Requesting location", context: self.logContext)
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
        didUpdateLocationsSubject.send(locations)
        delegate?.onLocationsFound(locations)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        assert(delegate != nil, "delegate is nil?")
        let locationFindError = LocationFindError.locationManagerError(error: error)
        didUpdateLocationsSubject.send(completion: Subscribers.Completion.failure(locationFindError))
        delegate?.onLocationManagerError(error)
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        assert(delegate != nil, "delegate is nil?")
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
            SwiftyBeaver.error("Unknownd status: \(self)", context: "📍GPS")
            return false
        }
    }
}
