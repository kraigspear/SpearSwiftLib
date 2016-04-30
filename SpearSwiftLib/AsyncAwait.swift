//
//  AsyncAwait.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/13/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation



public class AsyncAwait
{
	public static func Await<T>(asyncOn:() -> T, awaitOn:(T) -> Void)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let obj = asyncOn()
			dispatch_async(dispatch_get_main_queue()) {
				awaitOn(obj)
			}
		}
	}
	
	public static func Await<T>(que: dispatch_queue_t!, asyncOn:() -> T, awaitOn:(T) -> Void)
	{
		dispatch_async(que) {
			let obj = asyncOn()
			dispatch_async(dispatch_get_main_queue()) {
				awaitOn(obj)
			}
		}
	}

}

