//
//  Json.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/30/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

/// Errors that can occur when converting JSON
public enum ConvertError: Error {
    /// The node could not be converted into the expected type.
    case invalidConversion
    /// The node to convert the value from was missing.
    case missingNode
}

private final class JsonDateFormatters {
    static let instance = JsonDateFormatters()
    static let timeZone = TimeZone(secondsFromGMT: 0)

    private init() {}

    private lazy var format1: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = JsonDateFormatters.timeZone
        return dateFormatter
    }()

    private lazy var format2: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S"
        dateFormatter.timeZone = JsonDateFormatters.timeZone
        return dateFormatter
    }()

    private lazy var format3: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        dateFormatter.timeZone = JsonDateFormatters.timeZone
        return dateFormatter
    }()

    private lazy var format4: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = JsonDateFormatters.timeZone
        return dateFormatter
    }()

    lazy var formatters: [DateFormatter] = {
        [format1, format2, format3, format4]
    }()
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    /**
     Convert the value found at key to an Int

     - parameter key: Key where value is to be retrived from.
     - returns: An Int at the given key

     - throws: `ConvertError.missingNode` If the node does not exist
     - throws: `ConvertError.invalidConversion` If the value at the given node isn't a valid Int

     */
	func toInt(_ key: Key) throws -> Int {
        if let intVal = self[key] as? Int {
            return intVal
        }

        guard let strVal = try? self.toString(key) else {
            throw ConvertError.missingNode
        }

        if let intVal = Int(strVal) {
            return intVal
        }

        if let dblValue = Double(strVal) {
            return Int(dblValue)
        }

        throw ConvertError.invalidConversion
    }

    /**
     Convert the value found at key to a Float

     - parameter key: Key where value is to be retrived from.
     - returns: A Float at the given key

     - throws: `ConvertError.missingNode` If the node does not exist
     - throws: `ConvertError.invalidConversion` If the value at the given node isn't a valid Int

     */
	func toFloat(_ key: Key) throws -> Float {
        if let floatVal = self[key] as? Float {
            return floatVal
        }

        guard let strVal = try? self.toString(key) else {
            throw ConvertError.missingNode
        }

        if let floatVal = Float(strVal) {
            return floatVal
        }

        throw ConvertError.invalidConversion
    }

    /**
     Convert the value found at key to a Double

     - parameter key: Key where value is to be retrived from.
     - returns: A Double at the given key

     - throws: `ConvertError.missingNode` If the node does not exist
     - throws: `ConvertError.invalidConversion` If the value at the given node isn't a valid Int

     */

    func toDouble(_ key: Key) throws -> Double {
        if let dblValue = self[key] as? Double {
            return dblValue
        }

        guard let strVal = try? self.toString(key) else {
            throw ConvertError.missingNode
        }

        if let dblValue = Double(strVal) {
            return dblValue
        }

        throw ConvertError.invalidConversion
    }

    /**
     Convert the value with this key to a bool

     - parameter key: Key where value is to be retrived from.
     - returns: The bool value at the given key.

     - throws ConvertError.invalidConversion: If the value doesn't exist as a NSNumber
     */
    func toBool(_ key: Key) throws -> Bool {
        guard let val = self[key] as? NSNumber else {
            throw ConvertError.invalidConversion
        }
        return val.boolValue
    }

    /**
     Convert the value with this key to be a String

     - parameter key: Key where value is to be retrived from.
     - returns: The string value at the given key.

     - throws: `ConvertError.missingNode` If the node does not exist
     */
	func toString(_ key: Key) throws -> String {
        guard let strVal = self[key] as? String else {
            throw ConvertError.missingNode
        }
        return strVal
    }

	func toJson(_ key: Key) throws -> JsonKeyValue {
        guard let jsonValue = self[key] as? JsonKeyValue else {
            throw ConvertError.missingNode
        }
        return jsonValue
    }

    /**
     Convert the value with this key to be a Date.

     Various date formatters are used to attempt a conversion.
     If one is not found a invalidConversion is thrown

     - parameter key: Key where value is to be retrived from.
     - returns: The Date value at the given key.

     - throws: `ConvertError.missingNode` If the node does not exist
     - throws: `ConvertError.invalidConversion` If was not able to convert node to a Date
     */
	func toDate(_ key: Key) throws -> Date {
        let strVal = try toString(key)

        for formatter in JsonDateFormatters.instance.formatters {
            if let date = formatter.date(from: strVal) {
                return date
            }
        }

        assertionFailure("Unsuppported date format \(strVal)")
        throw ConvertError.invalidConversion
    }

    /**
     Convert the value found at key to a URL

     - parameter key: Key where value is to be retrived from.
     - returns: A URL at the given key

     - throws: `ConvertError.missingNode` If the node does not exist
     - throws: `ConvertError.invalidConversion` If the value at the given node isn't a valid URL

     ```swift

     let url: URL

     do {
     url = try json.toURL("url")
     }
     catch ConvertError.invalidConversion {

     }
     catch ConvertError.missingNode {

     }
     ```
     */
	func toURL(_ key: Key) throws -> URL {
        guard let strVal = try? toString(key) else {
            throw ConvertError.missingNode
        }

        if let url = URL(string: strVal) {
            return url
        }
        throw ConvertError.invalidConversion
    }
}

// MARK: - Alias

/// The base type of Json a key value pair
public typealias JsonKeyValue = Dictionary<String, Any>

/// Block for receiving a JsonKeyValue
public typealias JsonBlock = ((_ json: JsonKeyValue) -> Void)
