//
//  BoundingBoxTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 5/25/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import CoreLocation
@testable import SpearSwiftLib
import XCTest

class BoundingBoxTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBoudingBoxCalculation() {
        let coordinate = CLLocationCoordinate2D(latitude: 42.9634, longitude: -85.6681)

        let boundingBox = coordinate.calcBoundingBox(halfSideInKm: 1000)

        print("boudingBox = \(boundingBox)")

        let expectedMax = CLLocationCoordinate2D(latitude: 51.9605063206253, longitude: -73.373434272284)
        let expectedMin = CLLocationCoordinate2D(latitude: 33.9662972682419, longitude: -97.96276262713)

        XCTAssertEqual(expectedMax.latitude, boundingBox.maxPoint.latitude, accuracy: 0.00001)
        XCTAssertEqual(expectedMin.longitude, boundingBox.minPoint.longitude, accuracy: 0.00001)
    }
}
