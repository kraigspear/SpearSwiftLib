//
//  BaseOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/11/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public class BaseOperation : NSOperation {

    ///Indicates if there was an error executing the operation. Nil if the operation was a
    ///Success or an error otherwise.
    public var error:NSError?
    
    override public func start() {
        if self.cancelled
        {
            self.finished = true
        }
        else
        {
            self.executing = true
            self.main()
        }
    }
    
    var anyDependencyHasErrors:Bool
    {
        for dependency in self.dependencies
        {
            if let baseOperation = dependency as? BaseOperation
            {
                if baseOperation.error != nil
                {
                    return true
                }
            }
        }
        return false
    }
    
    override public var asynchronous:Bool {
        return true
    }
    
    private var _executing:Bool = false
    
    private let executingKey = "isExecuting"
    override public var executing:Bool {
        get {
            return _executing
        }
        set {
            self.willChangeValueForKey(executingKey)
            _executing = newValue
            self.didChangeValueForKey(executingKey)
        }
    }
    
    private var _finished:Bool = false
    
    private let finishedKey = "isFinished"
    override public var finished:Bool {
        get {
            return _finished
        }
        set {
            self.willChangeValueForKey(finishedKey)
            _finished = newValue
            self.didChangeValueForKey(finishedKey)
        }
    }
    
    ///Set this operation as being completed. Needs to always be called no matter if the operation
    ///is successful or not
    public func done() {
        self.executing = false
        self.finished = true
    }
    
}