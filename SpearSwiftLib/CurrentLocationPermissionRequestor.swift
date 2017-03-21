//
//  CurrentLocationPermissionRequestor.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/20/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
import CoreLocation

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

///Allows checking for current location permissions
public protocol CurrentLocationPermissionRequestable {
	func request(permission: RequestPermission, completed: @escaping LocationPermissionResultClosure)
}

public final class CurrentLocationPermissionRequestor: NSObject {
	
	fileprivate var locationManager: CLLocationManager?
	fileprivate var onCompleted: LocationPermissionResultClosure?
	fileprivate var permission: RequestPermission!
	fileprivate var lastStatus: CLAuthorizationStatus?
	
	public override init() {
		super.init()
	}
	
	fileprivate func initManager() {
		precondition(Thread.isMainThread)
		if self.locationManager != nil {
			return
		}
		self.locationManager = CLLocationManager()
		self.locationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		self.locationManager!.delegate = self
	}
	
	fileprivate func deinitManager() {
		precondition(Thread.isMainThread)
		onCompleted = nil
		guard let locationManager = self.locationManager else {
			return
		}
		locationManager.delegate = nil
		self.locationManager = nil
	}
	
	///No need to ask for permission because we already have it.
	fileprivate var isPermissionAlreadyGiven: Bool {
		guard let lastStatus = self.lastStatus else {return false}
		guard let permission = self.permission else {return false}
		
		switch permission {
		case .always:
			return lastStatus == .authorizedAlways
		case .whenInUse:
			return lastStatus == .authorizedWhenInUse
		}
	}

}

extension CurrentLocationPermissionRequestor: CurrentLocationPermissionRequestable {
	public func request(permission: RequestPermission, completed: @escaping LocationPermissionResultClosure) {
		
		initManager()
		
		self.onCompleted = completed
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
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		if lastStatus == nil {
			lastStatus = status
			return
		}
		
		guard let onCompleted = self.onCompleted else {return}
		
		switch status {
		case .authorizedAlways:
			onCompleted(.always)
		case .authorizedWhenInUse:
			onCompleted(.whenInUse)
		default:
			onCompleted(.notGiven)
		}
		
		deinitManager()
	}
}
