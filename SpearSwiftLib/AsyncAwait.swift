//
//  AsyncAwait.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/13/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation


/**
Provides an easier way to run code on a separate thread, and return the results 
to the main thread

```
//This will execute on another thread
let async = {() -> TypeToReturnFromWorkerThread in
	//Fetch the object from the network ext...
    let myObj = DoSomeStuff()
	return myObj
}

AsyncAwait.Await(async) { (someObj: someObj) in
    //Back on the main thread, after async above ran code on another thread.
}

```

*/
public final class AsyncAwait
{
	/**
	Execute this code block on another thread, calling back on await after the 
	 code in this blocks executes
	
	 - parameter asyncOn: Code to execute on a separate thread
	 - parameter awaitOn: Code to execute back on the main thread
	
	*/
	public static func Await<T>(asyncOn:() -> T, awaitOn:(T) -> Void)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let obj = asyncOn()
			dispatch_async(dispatch_get_main_queue()) {
				awaitOn(obj)
			}
		}
	}
}

