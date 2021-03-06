//
//  BoundingBox.swift
//  WeatherKit
//
//  Created by Kraig Spear on 1/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

// Semi-axes of WGS-84 geoidal reference
private let WGS84_a = 6_378_137.0 // Major semiaxis [m]
private let WGS84_b = 6_356_752.3 //  Minor semiaxis [m]

/// A coordinate box with a min and max point.
public struct BoundingBox {
    // MARK: - Instance Properties

    /// The minimum point or bottom left / south west
    public let minPoint: CLLocationCoordinate2D
    /// The maximum point or upper right / north west
    public let maxPoint: CLLocationCoordinate2D

    // MARK: - Initialization

    /**
     Initialize a new instance of bounding box with the coordinates

     - parameters minPoint: Minimum point or bottom left / south west
     - parameters maxPoint: Maximum point or upper right / north west
     */
    public init(minPoint: CLLocationCoordinate2D,
                maxPoint: CLLocationCoordinate2D) {
        self.minPoint = minPoint
        self.maxPoint = maxPoint
    }
}

extension BoundingBox: CustomStringConvertible {
    // MARK: - CustomStringConvertible

    /// A textual representation of this instance.
    public var description: String {
        return "min: \(minPoint) max: \(maxPoint) "
    }
}

// MARK: - MapKit

public extension BoundingBox {
    /// This bounding box converted into a mapRect
    var mapRect: MKMapRect {
        let p1 = MKMapPoint(minPoint)
        let p2 = MKMapPoint(maxPoint)
        return MKMapRect(x: fmin(p1.x, p2.x), y: fmin(p1.y, p2.y), width: fabs(p1.x - p2.x), height: fabs(p1.y - p2.y))
    }
}

extension BoundingBox: Equatable {
    /// :nodoc:
    public static func == (lhs: BoundingBox, rhs: BoundingBox) -> Bool {
        return lhs.minPoint.isSameAs(rhs.minPoint) &&
            lhs.maxPoint.isSameAs(rhs.maxPoint)
    }
}

extension CLLocationCoordinate2D {
    public func calcBoundingBox(halfSideInKm: Double) -> BoundingBox {
        let lat = Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lon = Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let halfSide = 1000 * halfSideInKm

        // Radius of the earth at a given latitude
        let radius = WGS84EarthRadius(from: lat)
        // Radius of the parallel at given latitude
        let pradius = radius * cos(lat)

        let latMin = lat - halfSide / radius
        let latMax = lat + halfSide / radius
        let lonMin = lon - halfSide / pradius
        let lonMax = lon + halfSide / pradius

        let minLatInDegrees = Measurement(value: latMin, unit: UnitAngle.radians).converted(to: .degrees).value
        let minLngInDegrees = Measurement(value: lonMin, unit: UnitAngle.radians).converted(to: .degrees).value

        let maxLatInDegrees = Measurement(value: latMax, unit: UnitAngle.radians).converted(to: .degrees).value
        let maxLngInDegrees = Measurement(value: lonMax, unit: UnitAngle.radians).converted(to: .degrees).value

        let min = CLLocationCoordinate2D(latitude: minLatInDegrees, longitude: minLngInDegrees)
        let max = CLLocationCoordinate2D(latitude: maxLatInDegrees, longitude: maxLngInDegrees)

        return BoundingBox(minPoint: min, maxPoint: max)
    }
}

private func WGS84EarthRadius(from: Double) -> Double {
    let An = WGS84_a * WGS84_a * cos(from)
    let Bn = WGS84_b * WGS84_b * sin(from)
    let Ad = WGS84_a * cos(from)
    let Bd = WGS84_b * sin(from)
    return sqrt((An * An + Bn * Bn) / (Ad * Ad + Bd * Bd))
}
