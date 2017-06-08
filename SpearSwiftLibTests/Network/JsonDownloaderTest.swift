//
//  JsonDownloaderTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import XCTest
@testable import SpearSwiftLib

fileprivate enum TestError: Error {
	case someError
}

final class JsonDownloaderTest: XCTestCase {
	
	private var networkDownloaderMock: NetworkDownloadableMock!
	private var jsonDownoader: JsonDownloader!
	
    override func setUp() {
        super.setUp()
        networkDownloaderMock = NetworkDownloadableMock()
		jsonDownoader = JsonDownloader(networkDownloader: networkDownloaderMock)
    }
    
    func testWhenJSONDataIsReceivedJSONDataIsInTheResult() {
		
		let key = "key1"
		let val = "value1"
		let testDictionary = [key : val]
		
		let data = try! JSONSerialization.data(withJSONObject: testDictionary, options: [])
		networkDownloaderMock.downloadResult = NetworkResult<Data>.success(result: data)
		
		let expectData = expectation(description: "dataLoaded")
		
		let request = RequestBuildableMock()
		
		request.requestForRequest = URLRequest(url: URL(string: "https://www.test.com")!)
		
		jsonDownoader.download(from: request) {(result) in
			
			switch result {
			case .success(result: let json):
				XCTAssertEqual(val,  try! json.toString(key))
			default:
				XCTFail("Success was expected")
			}
			
			expectData.fulfill()
		}
		
		waitForExpectations(timeout: 2) { (error) -> Void in
			XCTAssertNil(error, "Error")
		}
    }
	
	func testWhenResultIsInvalidStatusInvalidStatusIsReturned() {
		
		let expectedCode = 404
		
		let request = RequestBuildableMock()
		request.requestForRequest = URLRequest(url: URL(string: "https://www.test.com")!)
		networkDownloaderMock.downloadResult = NetworkResult<Data>.response(code: expectedCode)
		
		let downloadFinished = expectation(description: "finished")
		
		jsonDownoader.download(from: request) {(result) in
			
			switch result {
			case .response(code: let code):
				XCTAssertEqual(expectedCode, code)
			default:
				XCTFail("Unexpected result")
			}
			
			downloadFinished.fulfill()
		}
		
		waitForExpectations(timeout: 2) { (error) -> Void in
			XCTAssertNil(error, "Error")
		}
	}
	
	func testWhenResultIsErrorErrorIsReturned() {
		let expectedError = TestError.someError
		
		let request = RequestBuildableMock()
		request.requestForRequest = URLRequest(url: URL(string: "https://www.test.com")!)
		networkDownloaderMock.downloadResult = NetworkResult<Data>.error(error: expectedError)
		
		let downloadFinished = expectation(description: "finished")
		
		jsonDownoader.download(from: request) {(result) in
			
			switch result {
			case .error(error: let error):
				XCTAssertEqual(expectedError, error as! TestError)
			default:
				XCTFail("Unexpected result")
			}
			
			downloadFinished.fulfill()
		}
		
		waitForExpectations(timeout: 2) { (error) -> Void in
			XCTAssertNil(error, "Error")
		}
	}
}
