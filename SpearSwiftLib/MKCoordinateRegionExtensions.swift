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
		
		let latDiff = fabs(otherRegion.center.latitude - center.latitude)
		let lngDiff = fabs(otherRegion.center.longitude - center.longitude)
		
		let spanLatDiff = fabs(otherRegion.span.latitudeDelta - span.latitudeDelta)
		let spanLngDiff = fabs(otherRegion.span.longitudeDelta - span.longitudeDelta)
		
		return latDiff <= epsilon &&
			lngDiff <= epsilon &&
			spanLatDiff <= epsilon &&
			spanLngDiff <= epsilon
	}
}
