//
//  CurrentLocationFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import CoreLocation

public enum LocationFindableError: ErrorType {
	case permissions
	case notEnabled
	case notAuthorized(status: CLAuthorizationStatus)
	case geocodeError(error: NSError)
	case locationManagerError(error: NSError)
}

public typealias LocationFindErrorClosure = (error: LocationFindableError) -> Void
public typealias LocationFinderSuccessClosure = (foundLocation: FoundLocationType) -> Void

public protocol LocationFindable {
	func find()
}

public enum LocationFinderBuilderError: ErrorType {
	case missingSuccess
	case missingFailure
}

public final class LocationFinderBuilder {
	
	public var accuracy: CLLocationAccuracy?
	public var success: LocationFinderSuccessClosure?
	public var failure: LocationFindErrorClosure?
	
	public init() {
		
	}
	
	public func build() throws -> LocationFindable {
		let accuracy = self.accuracy ?? kCLLocationAccuracyThreeKilometers
		
		guard let success = self.success else {
			throw LocationFinderBuilderError.missingSuccess
		}
		
		guard let failure = self.failure else {
			throw LocationFinderBuilderError.missingFailure
		}
		
		return LocationFinder(accuracy: accuracy,
			success: success,
			failure: failure)
	}
}

public protocol FoundLocationType {
	var placemark: CLPlacemark {get}
	var location: CLLocation {get}
}

struct FoundLocation: FoundLocationType {
	let placemark: CLPlacemark
	let location: CLLocation
}

final class LocationFinder: NSObject, LocationFindable, CLLocationManagerDelegate {
	
	private var locationManager: CLLocationManager?
	private let geoCoder = CLGeocoder()
	private let accuracy: CLLocationAccuracy
	private let success: LocationFinderSuccessClosure
	private let failure: LocationFindErrorClosure
	
	init(accuracy: CLLocationAccuracy,
	     success: LocationFinderSuccessClosure,
	     failure: LocationFindErrorClosure) {
		self.accuracy = accuracy
		self.success = success
		self.failure = failure
	}
	
	private func initManager() {
		if self.locationManager != nil {
			return
		}
		self.locationManager = CLLocationManager()
		self.locationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		self.locationManager!.delegate = self
	}
	
	private func deinitManager() {
		guard let locationManager = self.locationManager else {
			return
		}
		locationManager.delegate = nil
		self.locationManager = nil
	}
	
	private var requestedLocation: Bool = false
	
	func find() {
		
		if !CLLocationManager.locationServicesEnabled() {
			failure(error: LocationFindableError.notEnabled)
			return
		}
		
		initManager()
		
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
			requestedLocation = true
			locationManager!.requestLocation()
		} else {
			requestedLocation = false
			locationManager!.requestWhenInUseAuthorization()
		}
	}
	
	//MARK: - CLLocationManagerDelegate
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("didUpdateLocations")
		if let location = locations.first {
			reverseGeocode(location)
		} else {
			// ...
		}
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		failure(error: .locationManagerError(error: error))
	}
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		if requestedLocation {
			return
		}
		
		switch status {
		case .Denied:
			failure(error: .notAuthorized(status: status))
		case .AuthorizedAlways, .AuthorizedWhenInUse, .NotDetermined, .Restricted:
			find()
		}
	}
	
	private func reverseGeocode(location: CLLocation) {
		
		let complete: CLGeocodeCompletionHandler = {[weak self] (placemarks: [CLPlacemark]?, error: NSError?) in
			if let error = error {
				self?.failure(error: LocationFindableError.geocodeError(error: error))
				return
			}
			
			if let placemarks = placemarks {
				if let firstPlacemark = placemarks.first {
					let foundLocation = FoundLocation(placemark: firstPlacemark, location: location)
					self?.success(foundLocation: foundLocation)
				}
			}
			
		}
		
		geoCoder.reverseGeocodeLocation(location, completionHandler: complete)
	}
	
}