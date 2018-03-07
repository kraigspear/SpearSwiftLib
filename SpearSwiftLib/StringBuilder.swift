//
//  StringBuilder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/27/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

/// Builds a string with a deliminter. Useful for CSV, TSV ext...
///
/// Instead of concating strings with str1 + delimiter + str2
/// sb.append(str1).append(str2).build() can be used
///
/// ```swift
///    func testExample() {
///         let first = "Kraig"
///         let last = "Spear"
///         let address = "7556 Hometown CT SE"
///         let deliminter = "\t"
///         let expected = first + deliminter + last + deliminter + address
///
///         let sb = StringBuilder(delimiter:deliminter)
///         let combined = sb.append(first).append(last).append(address).build()
///
///         XCTAssertEqual(expected, combined)
///    }
///
public class StringBuilder {
    let delimiter: String

    private var strings: [String] = []

    /// Initilize the StringBuilder with the delimiter that will be used to seperate the strings
    ///
    /// - Parameter delimiter: The string to place between the added strings
    ///
    public init(delimiter: String) {
        self.delimiter = delimiter
    }

    /// Append a string to this StringBuilder
    ///
    /// - Parameter otherString: The string to add to this StringBuilder
    ///
    public func append(_ otherStr: String) -> StringBuilder {
        strings.append(otherStr)
        return self
    }

    /// The number of strings that have been added to this StringBuilder
    public var numberOfStrings: Int {
        return strings.count
    }

    /// Combine all of the strings into one string seperated with the delimiter
    ///
    /// - Returns: The string combined seperated with the delimiter
    ///
    public func build() -> String {
        var buildStr: String = ""

        for i in 0 ..< strings.count {
            buildStr += strings[i]
            if i < strings.count - 1 {
                buildStr += delimiter
            }
        }

        return buildStr
    }
}
