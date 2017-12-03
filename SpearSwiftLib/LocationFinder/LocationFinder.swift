//
//  CurrentLocationFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyBeaver

//MARK: - Errors

///Errors that can occure when searching for the current location
public enum LocationFindableError: Error {
	///Permissions have not been given to search for the current location
	case permissions
	///GPS is not enabled on the device
	case notEnabled
	///Not authorized to search for the current location
	case notAuthorized
	///NSError while searching for the current location
	case geocodeError(error: NSError)
	///The location manager raised an error while searching for the current location.
	case locationManagerError(error: NSError)
	///A placemark was not found while using reverse GeoCode to look up a placemark for a location
	case placemarkNotFound
}

public enum LocationFinderBuilderError: Error {
	case missingSuccess
	case missingFailure
}

public protocol FoundLocationType {
	var placemark: CLPlacemark {get}
	var location: CLLocation {get}
}

//MARK: - LocationFindable
public protocol LocationFindable {
	func find(accuracy: CLLocationAccuracy,
			  result: @escaping (ResultHavingType<FoundLocationType>) -> Void)
}

//MARK: - FoundLocation
public struct FoundLocation: FoundLocationType, CustomStringConvertible {
	
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
	private let log = SwiftyBeaver.self
	
	private var result: ((ResultHavingType<FoundLocationType>) -> Void)?
	
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
		
		assert(result != nil, "result should have been assigned")
		
		switch status {
		case .authorizedWhenInUse:
			locationManager.requestLocation()
		case .denied, .restricted, .notDetermined:
			result?(ResultHavingType<FoundLocationType>.error(error: LocationFindableError.notAuthorized))
		case .authorizedAlways:
			log.warning("When did we start requesting this?")
			preconditionFailure("When did we start requesting this?")
		}
	}
	
	func onLocationManagerError(_ error: Error) {
		result?(ResultHavingType<FoundLocationType>.error(error: error))
	}
}

extension LocationFinder: LocationFindable {
	
	public func find(accuracy: CLLocationAccuracy,
			    result: @escaping (ResultHavingType<FoundLocationType>) -> Void) {
		
		log.debug("LocationFinder.find")
		
		if locationManager.isLocationServicesEnabled == false {
			result(ResultHavingType<FoundLocationType>.error(error: LocationFindableError.notEnabled))
			return
		}
		
		self.result = result
		let status = locationManager.authorizationStatus
		
		switch status {
		case .authorizedWhenInUse:
			log.debug("status authorizedWhenInUse, requesting location")
			locationManager.requestLocation()
		case .authorizedAlways:
			log.warning("When did we start requesting this?")
			preconditionFailure("When did we start requesting this?")
		case .denied, .restricted:
			log.debug("status denied or restricted, returning error")
			result(ResultHavingType<FoundLocationType>.error(error: LocationFindableError.notAuthorized))
		case .notDetermined:
			log.debug("status notDetermined, requesting whenInUseAuth")
			locationManager.requestWhenInUseAuthorization()
		}
	}
}

//MARK: - Reverse Geocode
private extension LocationFinder {
	
	func reverseGeocode(_ location: CLLocation) {
		
		geocodeFinder.find(location) {[weak self] geocodeResult in
			
			guard let mySelf = self else { return }
			
			switch geocodeResult {
			case .success(result: let placemark):
				let foundLocation = FoundLocation(placemark: placemark,
												  location: location)
				mySelf.result?(ResultHavingType<FoundLocationType>.success(result: foundLocation))
			case .error(error: let error):
				mySelf.result?(ResultHavingType<FoundLocationType>.error(error: error))
			}
		}
	}
}


