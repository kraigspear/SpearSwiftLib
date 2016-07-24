//
//  MKMapViewExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/24/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public extension MKMapView {
	
	public var upperLeftCoordinate: CLLocationCoordinate2D {
		return convertPoint(CGPointMake(0, 0), toCoordinateFromView: self)
	}
	
	public var bottomRightCoordinate: CLLocationCoordinate2D {
		let point = CGPointMake(frame.size.width, frame.size.height)
		return convertPoint(point, toCoordinateFromView: self)
	}
	
	public var upperRightCoordinate: CLLocationCoordinate2D {
		let point = CGPointMake(frame.size.width, 0)
		return convertPoint(point, toCoordinateFromView: self)
	}
	
	public var lowerLeftCoordinate: CLLocationCoordinate2D {
		let point = CGPointMake(0, frame.size.height)
		return convertPoint(point, toCoordinateFromView: self)
	}
}
