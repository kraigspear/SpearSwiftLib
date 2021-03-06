//
//  CurrentLocationFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Errors

/// Errors that can occure when searching for the current location
public enum LocationFindableError: Error {
    /// Permissions have not been given to search for the current location
    case permissions
    /// GPS is not enabled on the device
    case notEnabled
    /// Not authorized to search for the current location
    case notAuthorized
    /// NSError while searching for the current location
    case geocodeError(error: NSError)
    /// The location manager raised an error while searching for the current location.
    case locationManagerError(error: NSError)
    /// A placemark was not found while using reverse GeoCode to look up a placemark for a location
    case placemarkNotFound

    var localizedDescription: String {
        switch self {
        case .permissions, .notAuthorized:
            return NSLocalizedString("Missing the required permissions to find the current location", comment: "")
        case .notEnabled:
            return NSLocalizedString("Location services are not enabled, can't find the current location", comment: "")
        case let .geocodeError(error: error):
            return error.localizedDescription
        case let .locationManagerError(error: error):
            return error.localizedDescription
        case .placemarkNotFound:
            return NSLocalizedString("Placemark wasn't found", comment: "")
        }
    }
}

public enum LocationFinderBuilderError: Error {
    case missingSuccess
    case missingFailure
}

/**
 A location that was found using CoreLocation
 - SeeAlso: `LocationFinder`

 ```swift
 func reverseGeocode(_ location: CLLocation) {
     geocodeFinder.find(location) { [weak self] geocodeResult in

         guard let mySelf = self else { return }

         switch geocodeResult {
         case let .success(result: placemark):
             let foundLocation = FoundLocation(placemark: placemark,
                                               location: location)
             mySelf.result?(ResultHavingType<FoundLocationType>.success(result: foundLocation))
         case let .error(error: error):
             mySelf.result?(ResultHavingType<FoundLocationType>.error(error: error))
         }
     }
 }
 ```
 */
public protocol GPSLocation {
    /// The Placemark of the found location
    var placemark: CLPlacemark { get }
    /// The Coordinates of the found location
    var location: CLLocation { get }
}

// MARK: - LocationFindable

/**
 Finds the current location
 */
public protocol LocationFindable {
    /**
     Finds the current location

     - parameter accuracy: How accurate does the location search need to be? The larger the number the quicker the response time
     - parameter result: The result of the call
     */
    func find(accuracy: CLLocationAccuracy) -> AnyPublisher<GPSLocation, Error>
}

// MARK: - FoundLocation

public struct FoundLocation: GPSLocation, CustomStringConvertible {
    public let placemark: CLPlacemark
    public let location: CLLocation

    public init(placemark: CLPlacemark,
                location: CLLocation) {
        self.placemark = placemark
        self.location = location
    }

    public var description: String {
        return "location: \(location) placemark: \(placemark)"
    }
}

public final class LocationFinder: NSObject {
    private let locationManager: LocationManageable
    private let geocodeFinder: GeocodeFindable

    private var result: ((ResultHavingType<GPSLocation>) -> Void)?

    init(locationManager: LocationManageable,
         geocodeFinder: GeocodeFindable) {
        self.locationManager = locationManager
        self.geocodeFinder = geocodeFinder
        super.init()
        locationManager.delegate = self
    }

    public convenience override init() {
        self.init(locationManager: LocationManager(),
                  geocodeFinder: GeocodeFinder())
    }
}

extension LocationFinder: LocationManagerDelegate {
    func onLocationsFound(_ locations: [CLLocation]) {
        if let firstLocation = locations.first {
            reverseGeocode(firstLocation)
        }
    }

    func onAuthorizationStatusChanged(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .restricted, .notDetermined:
            result?(ResultHavingType<GPSLocation>.error(error: LocationFindableError.notAuthorized))
        case .authorizedAlways:
            preconditionFailure("When did we start requesting this?")
        @unknown default:
            assertionFailure("Unknown status: \(status)")
        }
    }

    func onLocationManagerError(_ error: Error) {
        result?(ResultHavingType<GPSLocation>.error(error: error))
    }
}

extension LocationFinder: LocationFindable {
    public func find(accuracy: CLLocationAccuracy) -> AnyPublisher<GPSLocation, Error> {
        locationManager.desiredAccuracy = accuracy

        return locationManager.foundLocations
            .compactMap { $0.first }
            .flatMap { self.reverseGeocode($0) }
            .eraseToAnyPublisher()
    }

    /**
     Finds the current location

     - parameter accuracy: How accurate does the location search need to be? The larger the number the quicker the response time
     - parameter result: The result of the call
     */
    public func find(accuracy: CLLocationAccuracy,
                     result: @escaping (ResultHavingType<GPSLocation>) -> Void) {
        self.result = result

        if locationManager.isLocationServicesEnabled == false {
            result(ResultHavingType<GPSLocation>.error(error: LocationFindableError.notEnabled))
            return
        }

        let status = locationManager.authorizationStatus.value

        switch status {
        case .authorizedWhenInUse:
            locationManager.desiredAccuracy = accuracy
            locationManager.requestLocation()
        case .authorizedAlways:
            preconditionFailure("When did we start requesting this?")
        case .denied, .restricted:
            result(ResultHavingType<GPSLocation>.error(error: LocationFindableError.notAuthorized))
        case .notDetermined:

            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            assertionFailure("Unknown status: \(status)")
        }
    }
}

// MARK: - Reverse Geocode

private extension LocationFinder {
    func reverseGeocode(_ location: CLLocation) -> AnyPublisher<GPSLocation, Error> {
        let geocodeFinder = self.geocodeFinder

        return Future<GPSLocation, Error> { promise in
            geocodeFinder.find(location) { geocodeResult in
                switch geocodeResult {
                case let .success(result: placemark):
                    let foundLocation = FoundLocation(placemark: placemark,
                                                      location: location)
                    promise(.success(foundLocation))
                case let .error(error: error):
                    promise(.failure(error))
                }
            }

        }.eraseToAnyPublisher()
    }
}
