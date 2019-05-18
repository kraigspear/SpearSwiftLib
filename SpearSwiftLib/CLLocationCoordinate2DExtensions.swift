//
//  CLLocationCoordinate2DExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/18/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation

public extension CLLocationCoordinate2D {
    func centerPoint(_ otherCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat1 = latitude
        let lat2 = otherCoordinate.latitude
        let latDiff = lat2 - lat1
        let latDifHalf = latDiff / 2
        let latMiddle = lat1 + latDifHalf

        let lng1 = longitude
        let lng2 = otherCoordinate.longitude

        let lngDif = lng2 - lng1
        let lngDifHalf = lngDif / 2
        let lngMiddle = lng1 + lngDifHalf

        return CLLocationCoordinate2D(latitude: latMiddle, longitude: lngMiddle)
    }
}
