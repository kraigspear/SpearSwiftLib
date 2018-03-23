//
//  NSPointerArrayExtensions.swift
//  MeijerGo
//
//  Created by kraig spear on 3/19/18.
//  Copyright © 2018 kraig spear. All rights reserved.
//

import Foundation

extension NSPointerArray {
    func append(_ object: AnyObject?) {
        guard let strongObject = object else { return }

        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
}
