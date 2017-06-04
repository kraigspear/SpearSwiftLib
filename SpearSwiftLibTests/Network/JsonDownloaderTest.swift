//
//  JsonDownloaderTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import XCTest

final class JsonDownloaderTest: XCTestCase {
	
	var networkDownloaderMock: NetworkDownloadableMock!
	
    override func setUp() {
        super.setUp()
        networkDownloaderMock = NetworkDownloadableMock()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
