//
//  StringBuilder.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/27/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation


///Builds a string with a deliminter. Useful for CSV, TSV ext...
public class StringBuilder {
    let delimiter:String
    
    private var strings:[String] = []
    
    public init(delimiter:String) {
        self.delimiter = delimiter
    }
    
    public func append(otherStr:String) -> StringBuilder {
        strings.append(otherStr)
        return self
    }
    
    public var numberOfStrings:Int {
        return strings.count
    }
    
    public func build() -> String {
        var buildStr:String = ""
        
        for i in 0..<strings.count {
            buildStr += strings[i]
            if i < strings.count - 1 {
               buildStr += delimiter
            }
        }
        
        return buildStr
    }
    
}

