//
//  CLLocationCoordinate2DExtensionsTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/18/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
import XCTest

final class CLLocationCoordinate2DExtensionsTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCenterCoordinate() {
        let minCoordinate = CLLocationCoordinate2D(latitude: 33.9662972682419, longitude: -97.96276262713)
        let maxCoordinate = CLLocationCoordinate2D(latitude: 51.9605063206253, longitude: -73.373434272284)

        let center = minCoordinate.centerPoint(maxCoordinate)

        XCTAssertEqual(42.96, center.latitude, accuracy: 0.1)
        XCTAssertEqual(-85.66, center.longitude, accuracy: 0.1)
    }
}
