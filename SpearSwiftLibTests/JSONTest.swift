//
//  JSONTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/8/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import XCTest
@testable import SpearSwiftLib

//MARK: - StructWithType
private struct StructWithType<T> {
	let typeVal: T
}

private enum SomeIntField: JsonFieldable {
	
	case IntField
	
	var fieldName: String {
		switch self {
		case IntField:
			return "intField"
		}
	}
	var fieldType: FieldType {
		switch self {
		case .IntField:
			return FieldType.Int
		}
	}
	
	var path: [String] {
		let path: [String] = []
		return path
	}
}

private enum SomeFloatField: JsonFieldable {
	
	case FloatField
	
	var fieldName: String {
		switch self {
		case FloatField:
			return "floatField"
		}
	}
	var fieldType: FieldType {
		switch self {
		case .FloatField:
			return FieldType.Float
		}
	}
	
	var path: [String] {
		let path: [String] = []
		return path
	}
}

private enum SomeBoolField: JsonFieldable {
	case BoolField
	
	var fieldName: String {
		switch self {
		case .BoolField:
			return "boolField"
		}
	}
	
	var fieldType: FieldType {
		switch self {
		case .BoolField:
			return FieldType.Bool
		}
	}
	
	var path: [String] {
		let path: [String] = []
		return path
	}
}


//MARK: - StructWithFloat



private final class IntFieldExtractor: JsonExtractiable {
	
	let jsonData: JsonKeyValue
	typealias ExtractedType = StructWithType<Int>
	
	init(jsonData: JsonKeyValue) {
		self.jsonData = jsonData
	}
	
	private func someValue() throws -> Int {
		return try extract(SomeIntField.IntField)
	}
	
	func extract() throws -> ExtractedType {
		let v = try someValue()
		return StructWithType(typeVal: v)
	}
}

private final class FloatFieldExtractor: JsonExtractiable {
	
	let jsonData: JsonKeyValue
	typealias ExtractedType = StructWithType<Float>
	
	init(jsonData: JsonKeyValue) {
		self.jsonData = jsonData
	}
	
	private func someValue() throws -> Float {
		return try extract(SomeFloatField.FloatField)
	}
	
	func extract() throws -> ExtractedType {
		let v = try someValue()
		return StructWithType(typeVal: v)
	}
}

private final class BoolFieldExtractor: JsonExtractiable {
	let jsonData: JsonKeyValue
	typealias ExtractedType = StructWithType<Bool>
	init(jsonData: JsonKeyValue) {
		self.jsonData = jsonData
	}
	
	private func someValue() throws -> Bool {
		return try extract(SomeBoolField.BoolField)
	}
	
	func extract() throws -> ExtractedType {
		let v = try someValue()
		return StructWithType(typeVal: v)
	}

}

class JSONTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIntFromInt() {
		let dict = ["intField" : 23]
		let extractor = IntFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Int> = try extractor.extract()
			XCTAssertEqual(23, myStruct.typeVal)
		} catch {
			XCTFail("Unexpected failure")
		}
    }
	
	func testIntFromString() {
		let dict = ["intField" : "23"]
		let extractor = IntFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Int> = try extractor.extract()
			XCTAssertEqual(23, myStruct.typeVal)
		} catch {
			XCTFail("Unexpected failure")
		}

	}
	
	func testFloatFromString() {
		let dict = ["floatField" : "23.11"]
		let extractor = FloatFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Float> = try extractor.extract()
			XCTAssertEqual(23.11, myStruct.typeVal)
		} catch {
			XCTFail("Unexpected failure")
		}
	}
	
	func testFloatFromFloat() {
		let dict = ["floatField" : 23.11]
		let extractor = FloatFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Float> = try extractor.extract()
			XCTAssertEqual(23.11, myStruct.typeVal)
		} catch {
			XCTFail("Unexpected failure")
		}
	}
	
	func testBoolTrue() {
		let dict = ["boolField" : true]
		let extractor = BoolFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Bool> = try extractor.extract()
			XCTAssertTrue(myStruct.typeVal)
		} catch {
			XCTFail("Unexpected Failure")
		}
	}
	
	func testBoolFalse() {
		let dict = ["boolField" : false]
		let extractor = BoolFieldExtractor(jsonData: dict)
		
		do {
			let myStruct: StructWithType<Bool> = try extractor.extract()
			XCTAssertFalse(myStruct.typeVal)
		} catch {
			XCTFail("Unexpected Failure")
		}
	}
	
	func testBoolWrongType() {
		let dict = ["boolField" : "abcd"]
		let extractor = BoolFieldExtractor(jsonData: dict)
		
		do {
			try extractor.extract()
			XCTFail("Exception Expected")
		} catch {
			
		}
	}
}
