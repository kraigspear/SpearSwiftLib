//
//  GeocodeFinder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/30/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyBeaver

///Error that can occure when searching for a placemark
public enum ReverseGeocodeError: Error {
	case placemarkNotFound
}

protocol GeocodeFindable {
	func find(_ location: CLLocation,
			  result: @escaping ((ResultHavingType<CLPlacemark>) -> Void))
}

final class GeocodeFinder {
	private let geoCoder = CLGeocoder()
	private let log = SwiftyBeaver.self
}

extension GeocodeFinder: GeocodeFindable {
	func find(_ location: CLLocation,
			  result: @escaping ((ResultHavingType<CLPlacemark>) -> Void))  {
		
		geoCoder.reverseGeocodeLocation(location) {[weak self] (placemarks, error) in
			guard let mySelf = self else { return }
			mySelf.log.debug("reverseGeocodeLocation complete")
			
			if let error = error {
				mySelf.log.warning("reverseGeocodeLocation had error \(error)")
				result(ResultHavingType<CLPlacemark>.error(error: error))
				return
			}
			
			if let firstPlacemark = placemarks?.first {
				mySelf.log.debug("Found placemark \(firstPlacemark)")
				result(ResultHavingType<CLPlacemark>.success(result: firstPlacemark))
			}
			else {
				mySelf.log.warning("Not able to find a placemark for \(location)")
				result(ResultHavingType<CLPlacemark>.error(error: ReverseGeocodeError.placemarkNotFound))
			}
			
		}
	}
}
