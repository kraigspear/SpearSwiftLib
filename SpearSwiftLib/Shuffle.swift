//
//  Shuffle.swift
//  SpearLib
//
//  Created by Kraig Spear on 2/26/15.
//  Copyright (c) 2015 spearware. All rights reserved.
//

import Foundation


/// Shuffle the elements of `list`.
func shuffle<C: MutableCollectionType where C.Index == Int>(inout list: C)
{
    let count = list.count
    for i in 0..<(count - 1) {
        let j = Int(arc4random_uniform(UInt32(count - i))) + i
        swap(&list[i], &list[j])
    }
}

/// Return a collection containing the shuffled elements of `list`.
func shuffled<C: MutableCollectionType where C.Index == Int>(inout list: C) -> C {
    shuffle(&list)
    return list
}

extension Array {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    
    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Element] {
        var list = self
        list.shuffle()
        return list
    }
}

