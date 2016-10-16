//
//  CurrentLocationFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import CoreLocation

public enum LocationFindableError: Error {
	case permissions
	case notEnabled
	case notAuthorized(status: CLAuthorizationStatus)
	case geocodeError(error: NSError)
	case locationManagerError(error: NSError)
}

public typealias LocationFindErrorClosure = (_ error: LocationFindableError) -> Void
public typealias LocationFinderSuccessClosure = (_ foundLocation: FoundLocationType) -> Void

public protocol LocationFindable {
	func find()
}

public enum LocationFinderBuilderError: Error {
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

struct FoundLocation: FoundLocationType, CustomStringConvertible {
	let placemark: CLPlacemark
	let location: CLLocation
	
	var description: String {
		return "location: \(location) placemark: \(placemark)"
	}
}

final class LocationFinder: NSObject, LocationFindable, CLLocationManagerDelegate {
	
	private var locationManager: CLLocationManager?
	private let geoCoder = CLGeocoder()
	private let accuracy: CLLocationAccuracy
	private let success: LocationFinderSuccessClosure
	private let failure: LocationFindErrorClosure
	
	init(accuracy: CLLocationAccuracy,
	     success: @escaping LocationFinderSuccessClosure,
	     failure: @escaping LocationFindErrorClosure) {
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
			failure(LocationFindableError.notEnabled)
			return
		}
		
		initManager()
		
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			requestedLocation = true
			locationManager!.requestLocation()
		} else {
			requestedLocation = false
			locationManager!.requestWhenInUseAuthorization()
		}
	}
	
	//MARK: - CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("didUpdateLocations")
		if let location = locations.first {
			reverseGeocode(location)
		} else {
			// ...
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		failure(.locationManagerError(error: error as NSError))
	}
	
	
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		if requestedLocation {
			return
		}
		
		switch status {
		case .denied:
			failure(.notAuthorized(status: status))
		case .authorizedAlways, .authorizedWhenInUse, .notDetermined, .restricted:
			find()
		}
	}
	
	private func reverseGeocode(_ location: CLLocation) {
		let complete: CLGeocodeCompletionHandler = {[weak self] (placemarks: [CLPlacemark]?, error: Error?) in
			if let error = error {
				self?.failure(LocationFindableError.geocodeError(error: error as NSError))
				return
			}
			
			if let placemarks = placemarks {
				if let firstPlacemark = placemarks.first {
					let foundLocation = FoundLocation(placemark: firstPlacemark, location: location)
					self?.success(foundLocation)
				}
			}
			
		}
		
		geoCoder.reverseGeocodeLocation(location, completionHandler: complete)
	}
	
}
