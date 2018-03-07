//
//  GeocodeFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/30/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import Foundation

/// Error that can occure when searching for a placemark
public enum ReverseGeocodeError: Error {
    case placemarkNotFound
}

protocol GeocodeFindable {
    func find(_ location: CLLocation,
              result: @escaping ((ResultHavingType<CLPlacemark>) -> Void))
}

final class GeocodeFinder {
    private let geoCoder = CLGeocoder()
}

extension GeocodeFinder: GeocodeFindable {
    func find(_ location: CLLocation,
              result: @escaping ((ResultHavingType<CLPlacemark>) -> Void)) {
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in

            if let error = error {
                result(ResultHavingType<CLPlacemark>.error(error: error))
                return
            }

            if let firstPlacemark = placemarks?.first {
                result(ResultHavingType<CLPlacemark>.success(result: firstPlacemark))
            } else {
                result(ResultHavingType<CLPlacemark>.error(error: ReverseGeocodeError.placemarkNotFound))
            }
        }
    }
}
