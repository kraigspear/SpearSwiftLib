//
//  MKCoordinateRegionExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/26/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import CoreLocation
import MapKit

public extension MKCoordinateRegion {
	/**
	Is this MKCoordinateRegion the same (or really close) to the other one
	
	 - parameter otherRegion: Other region to compare to
	 - returns: True if the Regions are really close to each other
	*/
	func isSameAs(_ otherRegion: MKCoordinateRegion) -> Bool {
		let epsilon = 0.05
		
		guard center.isSameAs(otherRegion.center) else { return false }
		
		let spanLatDiff = fabs(otherRegion.span.latitudeDelta - span.latitudeDelta)
		let spanLngDiff = fabs(otherRegion.span.longitudeDelta - span.longitudeDelta)
		
		return spanLatDiff <= epsilon &&
			spanLngDiff <= epsilon
	}
	
	///Are these coordinates valid coordinates
	/// - discussion: Lat & Lng at 0, 0 would not be coordinates that would be valid.
	var isValid: Bool {
		let lat = fabs(center.latitude)
		let lng = fabs(center.longitude)
		return lat >= 10 && lng >= 10
	}
}

public extension CLLocationCoordinate2D {
	
	/**
	Is this CLLocationCoordinate2D the same (or very close) to otherCoordinate
	- returns: True/False based on being the same as the other coordinate
	*/
	func isSameAs(_ otherCoordinate: CLLocationCoordinate2D) -> Bool {
		let epsilon = 0.05
		
		let latDiff = fabs(latitude - otherCoordinate.latitude)
		let lngDiff = fabs(longitude - otherCoordinate.longitude)
		
		return latDiff <= epsilon &&
		       lngDiff <= epsilon
	}
}
