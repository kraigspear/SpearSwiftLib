//
//  BoundingBox.swift
//  WeatherKit
//
//  Created by Kraig Spear on 1/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
import CoreLocation

// Semi-axes of WGS-84 geoidal reference
fileprivate let WGS84_a = 6378137.0  // Major semiaxis [m]
fileprivate let WGS84_b = 6356752.3 //  Minor semiaxis [m]

public struct BoundingBox {
	let minPoint: CLLocationCoordinate2D
	let maxPoint: CLLocationCoordinate2D
}

extension BoundingBox: CustomStringConvertible {
	public var description: String {
		return "min: \(minPoint) max: \(maxPoint) "
	}
}

extension CLLocationCoordinate2D {
	public func calcBoundingBox(halfSideInKm: Double) -> BoundingBox {
		let lat = Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value
		let lon = Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value
		let halfSide = 1000 * halfSideInKm
		
		//Radius of the earth at a given latitude
		let radius = WGS84EarthRadius(from: lat)
		//Radius of the parallel at given latitude
		let pradius = radius * cos(lat)
		
		let latMin = lat - halfSide / radius
		let latMax = lat + halfSide / radius
		let lonMin = lon - halfSide / pradius
		let lonMax = lon + halfSide / pradius
		
		let minLatInDegrees = Measurement.init(value: latMin, unit: UnitAngle.radians).converted(to: .degrees).value
		let minLngInDegrees = Measurement.init(value: lonMin, unit: UnitAngle.radians).converted(to: .degrees).value

		let maxLatInDegrees = Measurement.init(value: latMax, unit: UnitAngle.radians).converted(to: .degrees).value
		let maxLngInDegrees = Measurement.init(value: lonMax, unit: UnitAngle.radians).converted(to: .degrees).value

		let min = CLLocationCoordinate2D(latitude: minLatInDegrees, longitude: minLngInDegrees)
		let max = CLLocationCoordinate2D(latitude: maxLatInDegrees, longitude: maxLngInDegrees)
		
		return BoundingBox(minPoint: min, maxPoint: max)
	}
}

fileprivate func WGS84EarthRadius(from: Double) -> Double {
	let An = WGS84_a * WGS84_a * cos(from)
	let Bn = WGS84_b * WGS84_b * sin(from)
	let Ad = WGS84_a * cos(from)
	let Bd = WGS84_b * sin(from)
	return sqrt((An*An + Bn*Bn) / (Ad*Ad + Bd*Bd))
}
