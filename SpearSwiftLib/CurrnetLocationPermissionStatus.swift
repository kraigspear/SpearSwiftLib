//
//  CurrnetLocationPermissionStatus.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/17/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import CoreLocation
import Foundation

/// Provides the value of CLAuthorizationStatus
/// Wrapper to faciliate unit testing
public protocol CurrentLocationPermissionStatusProtocol {
	/// The current authorization status
	var authorizationStatus: CLAuthorizationStatus { get }
}

/// Implementation of `CurrentLocationPermissionStatusProtocol`
public struct CurrentLocationPermissionStatus: CurrentLocationPermissionStatusProtocol {
	public init() {}

	/// The current authorization status
	public var authorizationStatus: CLAuthorizationStatus {
		return CLLocationManager.authorizationStatus()
	}
}
