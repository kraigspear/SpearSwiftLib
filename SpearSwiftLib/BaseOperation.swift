//
//  BaseOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/11/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

/**
Provides a better implementation of NSOperation

Allows finishing the operation by calling done.

This class is meant to be inherited

```

final class AddLocationOperation: BaseOperation {
   let location: WeatherLocationType

   init(location: WeatherLocationType) {
      self.location = location
   }

   override func main() {
      //Do our work here. This will execute on another thread, (See NSOperation)
      let dbLocation = addToLocalDatabase()
      fetchWeatherForLocation(dbLocation)

	  //Done executing code we call done.
	  done()
    }

}


```

*/
open class BaseOperation : Operation {

    ///Indicates if there was an error executing the operation. Nil if the operation was a
    ///Success or an error otherwise.
    public var error: Error?
	
	/**
	Override of NSOperation start.
	Not intended to be overridden in BaseOperation child classes
	*/
    final override public func start() {
        if self.isCancelled
        {
            self.isFinished = true
        }
        else
        {
            self.isExecuting = true
            self.main()
        }
    }
    
    final var anyDependencyHasErrors:Bool
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
	
	/**
	Always true.
	Not intended to be overriden
	*/
    final override public var isAsynchronous: Bool {
        return true
    }
    
    private var _executing:Bool = false
    
    private let executingKey = "isExecuting"
    final override public var isExecuting:Bool {
        get {
            return _executing
        }
        set {
            self.willChangeValue(forKey: executingKey)
            _executing = newValue
            self.didChangeValue(forKey: executingKey)
        }
    }
    
    private var _finished:Bool = false
    private let finishedKey = "isFinished"
	
	/**
	True if the operation is finished
	*/
    final override public var isFinished: Bool {
        get {
            return _finished
        }
        set {
            self.willChangeValue(forKey: finishedKey)
            _finished = newValue
            self.didChangeValue(forKey: finishedKey)
        }
    }
    
    ///Set this operation as being completed. Needs to always be called no matter if the operation
    ///is successful or not
    public final func done() {
        self.isExecuting = false
        self.isFinished = true
    }
    
}
