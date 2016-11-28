//
//  CoordinateBoundaries.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/7/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import CoreLocation

public struct CoordinateBoundaries {
	
	let lattitude: Double
	let longitude: Double
	let distance: Double
	
	public init(latitude: Double, longitude: Double, distance: Double) {
		self.lattitude = latitude
		self.longitude = longitude
		self.distance = distance
	}
	
	private var latitudeConversionFactor: Double {
		return distance / 69
	}
	
	private var longitudeconversionFactor: Double {
		return distance / 69 / abs(cos(lattitude.toRadian()))
	}
	
	var minLatitude: Double {
		let v = lattitude - latitudeConversionFactor
		return v.boundaryMin(by: -90)
	}
	
	var maxLatitude: Double {
		let v = lattitude + latitudeConversionFactor
		return v.boundaryMax(by: 90)
	}
	
	var minLongitude: Double {
		let v = longitude + longitudeconversionFactor
		return v.boundaryMin(by: -180)
	}
	
	var maxLongitude: Double {
		let v = longitude - longitudeconversionFactor
		return v.boundaryMax(by: 180)
	}
	
	public var min: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude)
	}
	
	public var max: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: maxLatitude, longitude: maxLongitude)
	}
	
	public var center: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
	}
}

private extension Double {
	func toRadian() -> Double {
		return self * (M_PI / 180)
	}
	
	func boundaryMax(by: Double) -> Double {
		let negative = -by
		if self > by {
			return negative + (self - by)
		}
		else {
			return self
		}
	}
	
	func boundaryMin(by: Double) -> Double {
		if self < by {
			return abs(by) - (by - self)
		}
		else {
			return self
		}
	}
}
