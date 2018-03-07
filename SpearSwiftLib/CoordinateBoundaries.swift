//
//  CoordinateBoundaries.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/7/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import CoreLocation
import Foundation

/// The boundaries of a center
public struct CoordinateBoundaries {
    public let center: CLLocationCoordinate2D
    private let boundingBox: BoundingBox

    /**
     Initialize a CoordinateBoundaries with a center and distance

     - parameter latitude: The lattitude of the center coordinate
     - parameter longitude: The longitude of the center coordinate
     - parameter distance: Half length of the bounding box you want in kilometers
     */
    public init(latitude: Double,
                longitude: Double,
                distance: Double) {
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        boundingBox = center.calcBoundingBox(halfSideInKm: distance)
    }

    public var min: CLLocationCoordinate2D {
        return boundingBox.minPoint
    }

    public var max: CLLocationCoordinate2D {
        return boundingBox.maxPoint
    }
}
