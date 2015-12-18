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

public final class PathElement : CustomStringConvertible {
    
    let noIndex = -1
    public let name:String
    public let index:Int
    public var childPath:PathElement?
    
    public init(name:String, childAtIndex:Int = -1) {
        self.name = name
        self.index = childAtIndex
    }
    
    public var isArrayElement:Bool {
        return self.index != noIndex
    }
    
    var elementDescription: String {
        return "name: \(name) index: \(index)"
    }
    
    public func withChild(name:String, childAtIndex:Int = -1) -> PathElement {
        let child = PathElement(name: name, childAtIndex: childAtIndex)
        return self.withChild(child)
    }
    
    public func withChild(child:PathElement) -> PathElement {
        self.childPath = child
        return child
    }
    
    public var description: String {
        var str:String = self.elementDescription
        
        var child:PathElement? = self.childPath
        
        while child != nil {
            str += "\n" + child!.elementDescription
            child = child!.childPath
        }
        
        return str
    }
}

public struct JsonPath {
    
    public let name:String
    public let rootPath:PathElement
    
    public init(name:String, rootPath:PathElement) {
        self.name = name
        self.rootPath = rootPath
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
            try addPathToFoundJson(path)
        }
        
    }
    
    private func addPathToFoundJson(path:JsonPath) throws {
        
        var jsonElement:JSON = jsonData
        
        var pathElement:PathElement! = path.rootPath
        
        //Finding the last item. It's the one we assocaite the name with so that we can reference it later
        repeat {
            
            jsonElement = try pathElementToJsonElement(pathElement, path: path, jsonElement: jsonElement)
            pathElement = pathElement.childPath
            
        } while pathElement != nil
        
        self.foundJson[path.name] = jsonElement
    }
    
    private func pathElementToJsonElement(pathElement:PathElement, path:JsonPath, jsonElement:JSON) throws -> JSON {
        
        var foundJsonElement:JSON = jsonElement
        
        if pathElement.isArrayElement {
            
            if let elementArray = jsonElement[pathElement.name] as? [JSON] {
                if !elementArray.isValidIndex(pathElement.index) {
                    throw JsonError.PathIndexNotFound(path: pathElement)
                } else {
                    foundJsonElement = elementArray[pathElement.index]
                }
            }
            
        } else {
            
            if let element = jsonElement[pathElement.name] as? JSON {
                foundJsonElement = element
            } else {
                throw JsonError.PathNotFound(path: path)
            }
        }
        
        return foundJsonElement
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