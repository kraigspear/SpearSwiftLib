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
    public func Async(asyncOn:VoidBlock, awaitOn:VoidBlock)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            asyncOn()
            dispatch_async(dispatch_get_main_queue()) {
               awaitOn()
            }
        }
    }
}

