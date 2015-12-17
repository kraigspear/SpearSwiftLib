//
//  Json.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public enum JsonError : ErrorType {
    case PathNotFound(path:JsonPath)
    ///The path with an index (array) was not found. The JSON is not in the format that we expect
    case PathIndexNotFound(path:PathElement)
    case InvalidPath(pathName:String)
    case KeyNotFound(key:String)
    case ConversionError(key:String, value:AnyObject)
}

public struct PathElement {
    
    let noIndex = -1
    public let name:String
    public let index:Int
    
    public init(name:String, index:Int = -1) {
        self.name = name
        self.index = index
    }
    
    public var isArrayElement:Bool {
        return self.index != noIndex
    }
    
}

public struct JsonPath {
    
    public let name:String
    public let pathsElements:[PathElement]
    
    public init(name:String, pathsElements:[PathElement]) {
        self.name = name
        self.pathsElements = pathsElements
    }
    
}

public final class Json {
    
    private let jsonData:JSON
    private let paths:[JsonPath]
    private var foundJson:[String : JSON] = [:]
    
    public init(jsonData:JSON, paths:JsonPath...) throws {
        self.jsonData = jsonData
        self.paths = paths
        try! setupPaths()
    }
    
    private func setupPaths() throws {
        
        for path in paths {
           try setupPath(path)
        }
        
    }
    
    private func setupPath(path:JsonPath) throws {
        
        var jsonElement:JSON = jsonData
        
        for pathElement in path.pathsElements {
            
            if pathElement.isArrayElement {
                if let elementArray = jsonElement[pathElement.name] as? [JSON] {
                    if !elementArray.isValidIndex(pathElement.index) {
                        throw JsonError.PathIndexNotFound(path: pathElement)
                    } else {
                        jsonElement = elementArray[pathElement.index]
                    }
                }
                
            } else {
               if let element = jsonElement[pathElement.name] as? JSON {
                  jsonElement = element
               } else {
                  throw JsonError.PathNotFound(path: path)
               }
            }
            
        }
        self.foundJson[path.name] = jsonElement
    }
    
    
    /**
     Gets the value at the path with this key as a Float
     - Parameter pathName:The name of the path to get the value from
     - Parameter key:The key of the element to get the value from
     - Throws JsonError.KeyNotFound: When the key was not found
     - Throws JsonError.ConversionError: When the key was not found
     ~~~
     
     let temperature:Float = try json.floatValue(observation, key: tempKey)
     
     ~~~
     */
    public func floatValue(pathName:String, key:String) throws -> Float {
        guard let foundJson = self.foundJson[pathName] else {
            throw JsonError.KeyNotFound(key: pathName)
        }
        
        do {
          return try foundJson.toFloat(key)
        } catch DictionaryConvertError.MissingKey {
           throw JsonError.KeyNotFound(key: key)
        } catch DictionaryConvertError.ConversionError {
           throw JsonError.ConversionError(key: key, value: foundJson[key]!)
        }
        
    }
    
    public func dateValue(pathName:String, key:String) throws -> NSDate {
        guard let foundJson = self.foundJson[pathName] else {
            throw JsonError.KeyNotFound(key: pathName)
        }
        
        return try foundJson.toDate(key)
    }
    
    /**
     Gets the value at the path with this key as a Int
     - Parameter pathName:The name of the path to get the value from
     - Parameter key:The key of the element to get the value from
     - Throws JsonError.KeyNotFound: When the key was not found
     - Throws JsonError.ConversionError: When the key was not found
     ~~~
     
     let temperature:Int = try json.intValue(observation, key: tempKey)
     
     ~~~
    */
    public func intValue(pathName:String, key:String) throws -> Int {
        
        guard let foundJson = self.foundJson[pathName] else {
            throw JsonError.InvalidPath(pathName: pathName)
        }
        
        do {
            return try foundJson.toInt(key)
        } catch DictionaryConvertError.MissingKey {
            throw JsonError.KeyNotFound(key: key)
        } catch DictionaryConvertError.ConversionError {
            throw JsonError.ConversionError(key: key, value: foundJson[key]!)
        }
        
    }
    
    public func stringValue(pathName:String, key:String) throws -> String {
        guard let foundJson = self.foundJson[pathName] else {
            throw JsonError.InvalidPath(pathName: pathName)
        }
        
        guard let strValue = foundJson[key] as? String else {
            throw JsonError.ConversionError(key: key, value: foundJson[key]!)
        }
        
        return strValue
    }

    
    
}