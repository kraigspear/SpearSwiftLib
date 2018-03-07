//
// Created by Kraig Spear on 3/20/17.
//

import Foundation

/**
 A node containing a value with a previous and next node
 */
final class Node<T> {
    /// Value that this node contains
    let value: T

    /**
     Initialize a new node with a value

     - parameter value: Value that is contained in this node.
     */
    init(value: T) {
        self.value = value
    }

    /// The next node in the list
    var next: Node<T>?
    /// Previous node in the list
    weak var previous: Node<T>?
}

/// Classic implementation of a LinkList
struct LinkList<T> {
    /// The first item in the list
    private(set) var head: Node<T>?
    /// The last item in the list
    private(set) var tail: Node<T>?

    /// True if this list is empty
    var isEmpty: Bool {
        return head == nil
    }

    /// The fist item in the list
    var first: Node<T>? {
        return head
    }

    /// The last item in the list
    var last: Node<T>? {
        return tail
    }

    /**
     Add a new item to the link list

     -parameter value: The value that is contained in the node.
     */
    mutating func append(_ value: T) {
        let newNode = Node(value: value)

        if let tail = tail {
            newNode.previous = tail
            tail.next = newNode
        } else {
            head = newNode
        }

        tail = newNode
    }

    /**
     Remove a node from the list

     -parameter node: The node to remove from this list
     */
    mutating func remove(_ node: Node<T>) {
        let previous = node.previous
        let next = node.next

        if let previous = previous {
            previous.next = next // Update the next pointer if it's not being removed
        } else {
            head = next // Update head if the first node is being removed
        }

        next?.previous = previous // Make the next previous, the previous of the item being removed

        if next == nil {
            tail = previous // New tail, since we are removing the last item (tail)
        }

        // Remove references to the node being removed
        node.previous = nil
        node.next = nil
    }
}
