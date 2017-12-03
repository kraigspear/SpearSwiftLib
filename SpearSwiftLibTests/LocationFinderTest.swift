//
//  LocationFinderTest.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 11/29/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SpearSwiftLib

private enum TestError: Error {
	case someError
}

final class LocationFinderTest: XCTestCase {
	
	var locationFinder: LocationFinder!
	var geoCodeFinderFake: GeocodeFinderFake!
	var locationManageableFake: LocationManageableFake!
	
    override func setUp() {
        super.setUp()
		
		locationManageableFake = LocationManageableFake()
		geoCodeFinderFake = GeocodeFinderFake()
		locationFinder = LocationFinder(locationManager: locationManageableFake,
										geocodeFinder: geoCodeFinderFake)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_When_Location_Services_Are_Disabled_Then_Not_Enabled_Is_Returned() {
		locationManageableFake.setupIsLocationServicesEnabledValue(false)
		
		let findExpectation = expectation(description: "find")
		
		locationFinder.find(accuracy: 1.0) {[unowned self] result in
		
			switch result {
			case .error(error: let error):
				
				switch error {
				case LocationFindableError.notEnabled:
					break
				default:
					XCTFail("Unepected error")
				}
			default:
				XCTFail("Unexpected result")
			}
			
			XCTAssertTrue(self.locationManageableFake.expectRequestLocationCalled(times: 0))
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		
		XCTAssertEqual(.completed, expectResult)
    }
	
	func test_When_Status_Is_AuthorizedInUse_Then_Location_Is_Requested() {
		
		let findExpectation = expectation(description: "find")
		
		//setups
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.authorizedWhenInUse)
		
		let placemark = LocationFinderTest.createPlacemark()
		geoCodeFinderFake.setupForHavingResult(ResultHavingType<CLPlacemark>.success(result: placemark))

		let grandRapids = LocationFinderTest.createGrandRapids()
		locationManageableFake.setupLocationsAreReturned([grandRapids], afterSeconds: 0.25)
		
		locationFinder.find(accuracy: 1.0) {result in
			
			switch result {
			case .success(result: let foundLocation):
				XCTAssertEqual(placemark, foundLocation.placemark)
				XCTAssertEqual(grandRapids, foundLocation.location)
				break
			case .error(error: _):
				XCTFail("Error not expected")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		
		XCTAssertEqual(.completed, expectResult)
	}
	
	func test_When_Geocode_Returns_Error_Then_Error_Is_Returned() {
		let findExpectation = expectation(description: "find")
		
		//setups
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.authorizedWhenInUse)
		let grandRapids = LocationFinderTest.createGrandRapids()
		locationManageableFake.setupLocationsAreReturned([grandRapids], afterSeconds: 0.25)
		geoCodeFinderFake.setupForHavingResult(ResultHavingType<CLPlacemark>.error(error: TestError.someError))
		
		locationFinder.find(accuracy: 1.0) {result in
			
			switch result {
			case .error(error: _):
				break
			default:
				XCTFail("Unexpected result")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
	}
	
	func test_When_Status_Is_Denied_Then_Not_Authorized_Error_Is_Returned() {
		
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.denied)
		
		locationFinder.find(accuracy: 1.0) {result in
			switch result {
			case .error(error: let error):
				switch error {
				case LocationFindableError.notAuthorized:
					break
				default:
					XCTFail("Unexpected error")
				}
			default:
				XCTFail("Unexpected result")
			}
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
	}
    
	
	
    
}

//MARK: - Authorization Status Changed
extension LocationFinderTest {
	
	func test_When_Status_Is_Restricted_Then_Not_Authorized_Error_Is_Returned() {
		
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.restricted)
		
		locationFinder.find(accuracy: 1.0) {result in
			switch result {
			case .error(error: let error):
				switch error {
				case LocationFindableError.notAuthorized:
					break
				default:
					XCTFail("Unexpected error")
				}
			default:
				XCTFail("Unexpected result")
			}
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
		
	}

	
	func test_When_Status_Is_Not_Determined_Then_Permisions_Are_Requested() {
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.notDetermined)
		
		let grandRapids = LocationFinderTest.createGrandRapids()
		locationManageableFake.setupLocationsAreReturned([grandRapids], afterSeconds: 0.50)
		locationManageableFake.setupForStatusChanged(.authorizedWhenInUse, afterSeconds: 0.25)
		
		let placemark = LocationFinderTest.createPlacemark()
		geoCodeFinderFake.setupForHavingResult(ResultHavingType<CLPlacemark>.success(result: placemark))
		
		locationFinder.find(accuracy: 1.0) {[unowned self] result in
			XCTAssertTrue(self.locationManageableFake.expectRequestWhenInUseAuthorizationCalled(times: 1))
			XCTAssertTrue(self.locationManageableFake.expectRequestLocationCalled(times: 1))
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
		
	}

	
	func test_When_AuthorizationStatusChanged_To_Denied_Then_Not_Authorized_Error_Is_Returned() {
		
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.notDetermined)
		
		locationManageableFake.setupForStatusChanged(.denied, afterSeconds: 0.25)
		
		locationFinder.find(accuracy: 1.0) {[unowned self] result in
			
			XCTAssertTrue(self.locationManageableFake.expectRequestWhenInUseAuthorizationCalled(times: 1))
			XCTAssertTrue(self.locationManageableFake.expectRequestLocationCalled(times: 0))
			
			switch result {
			case .error(error: let error):
				switch error {
				case LocationFindableError.notAuthorized:
					break
				default:
					XCTFail("Expected error")
				}
			default:
				XCTFail("Expected result")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
		
	}
	
	func test_When_AuthorizationStatusChanged_To_Denied_Then_Restricted_Error_Is_Returned() {
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.notDetermined)
		
		locationManageableFake.setupForStatusChanged(.restricted, afterSeconds: 0.25)
		
		locationFinder.find(accuracy: 1.0) {[unowned self] result in
			
			XCTAssertTrue(self.locationManageableFake.expectRequestWhenInUseAuthorizationCalled(times: 1))
			XCTAssertTrue(self.locationManageableFake.expectRequestLocationCalled(times: 0))
			
			switch result {
			case .error(error: let error):
				switch error {
				case LocationFindableError.notAuthorized:
					break
				default:
					XCTFail("Expected error")
				}
			default:
				XCTFail("Expected result")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
		
	}
	
	func test_When_AuthorizationStatusChanged_To_Denied_Then_NotDetermined_Error_Is_Returned() {
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.notDetermined)
		
		locationManageableFake.setupForStatusChanged(.notDetermined, afterSeconds: 0.25)
		
		locationFinder.find(accuracy: 1.0) {[unowned self] result in
			
			XCTAssertTrue(self.locationManageableFake.expectRequestWhenInUseAuthorizationCalled(times: 1))
			XCTAssertTrue(self.locationManageableFake.expectRequestLocationCalled(times: 0))
			
			switch result {
			case .error(error: let error):
				switch error {
				case LocationFindableError.notAuthorized:
					break
				default:
					XCTFail("Expected error")
				}
			default:
				XCTFail("Expected result")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
		
	}
	
	func test_When_Location_Manager_Returns_Error_Then_Result_Is_Error() {
		let findExpectation = expectation(description: "find")
		
		locationManageableFake.setupIsLocationServicesEnabledValue(true)
		locationManageableFake.setupAuthorizationStatusValue(.notDetermined)
		locationManageableFake.setupForErrorRaised(TestError.someError, afterSeconds: 0.25)
		
		locationFinder.find(accuracy: 1.0) {result in
			
			switch result {
			case .error(error: _):
				break
			default:
			    XCTFail("Unexpected result")
			}
			
			findExpectation.fulfill()
		}
		
		let expectResult = XCTWaiter().wait(for: [findExpectation], timeout: 1)
		XCTAssertEqual(.completed, expectResult)
	}
}

//MARK: - Test Data
extension LocationFinderTest {
	static func createGrandRapids() -> CLLocation {
		return CLLocation(latitude: 42.9634, longitude: -85.6681)
	}
	
	static func createGrandRapidsResult() -> ResultHavingType<CLLocation> {
		return ResultHavingType<CLLocation>.success(result: createGrandRapids())
	}
	
	static func createPlacemark() -> CLPlacemark {
		return CLPlacemark()
	}
}
