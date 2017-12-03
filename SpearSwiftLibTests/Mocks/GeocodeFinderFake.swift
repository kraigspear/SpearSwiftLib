//
//  GeocodeFinderFake.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 11/30/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
import CoreLocation

@testable import SpearSwiftLib

final class GeocodeFinderFake {
	private var findCalled = 0
	private var result: ResultHavingType<CLPlacemark>!
}

extension GeocodeFinderFake: GeocodeFindable {
	
	func find(_ location: CLLocation,
			  result: @escaping ((ResultHavingType<CLPlacemark>) -> Void)) {
		findCalled += 1
		result(self.result)
	}
	
}

//MARK: - Expects
extension GeocodeFinderFake {
	func expectFindCalled(_ value: Int) -> Bool {
		return value == findCalled
	}
}

//MARK: - Setups
extension GeocodeFinderFake {
	func setupForHavingResult(_ result: ResultHavingType<CLPlacemark>) {
		self.result = result
	}
}
