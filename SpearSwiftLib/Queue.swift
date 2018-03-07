//
// Created by Kraig Spear on 3/20/17.
//

import Foundation

/// A standard first in first out Queue
struct Queue<T> {
    /// Internal list of of items
    private var list = LinkList<T>()

    /**
     Adds an item to the queue

     -parameter item: Item to add.
     */
    mutating func enqueue(_ item: T) {
        list.append(item)
    }

    /// Is this Queue empty?
    var isEmpty: Bool {
        return list.isEmpty
    }

    /// Dequeue an object from the Queue
    mutating func dequeue() -> T? {
        guard let element = list.first else { return nil }
        list.remove(element)
        return element.value
    }
}
