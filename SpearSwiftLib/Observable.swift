//
//  Observable.swift
//  MeijerGo
//
//  Created by kraig spear on 3/16/18.
//  Copyright © 2018 Spearware. All rights reserved.
//

import Foundation

public protocol Subscribeable: class {
    associatedtype T

    func subscribe(_ handler: @escaping ((T) -> Void))
    func subscribeWithDispose(_ handler: @escaping ((T) -> Void)) -> Disposeable<T>
    func unsubscribe(_ handler: Disposeable<T>)
    var value: T { get }
}

public final class AnySubscribeable<T>: Subscribeable {
    private weak var observer: Observable<T>!

    public init(observer: Observable<T>) {
        self.observer = observer
    }

    public func subscribe(_ handler: @escaping ((T) -> Void)) {
        observer.subscribe(handler)
    }

    public func subscribeWithDispose(_ handler: @escaping ((T) -> Void)) -> Disposeable<T> {
        return observer.subscribeWithDispose(handler)
    }

    public func unsubscribe(_ handler: Disposeable<T>) {
        return observer.unsubscribe(handler)
    }

    public var value: T {
        return observer.value
    }
}

/**
 Observe a change to a value.

 ```swift
 //Defines the shoppingCartItems observable
 private(set) var shoppingCartItems = Observable<[ShoppingCartItem]>(value: [])

 //Subscribe to the cart changing
 disposeBag.add(disposable: viewModel.shoppingCartItems.subscribe(onCartUpdated))

 // Now when the cart changes we can update the datasource with the latest value
 func onCartUpdated(_ shoppingCartItems: [ShoppingCartItem]) {
 cartDataSource.items = shoppingCartItems
 }
 ```
 */
public final class Observable<T>: Subscribeable {
    /// Reference to observers as pointers
    private var observables = NSPointerArray.strongObjects()

    private let uuid = UUID().uuidString

	/**
	 Initialize with the inital value

	 - parameter value: The initial value of this observable
	 */
    public init(value: T) {
        self.value = value
    }

    public lazy var asSubscribeable: AnySubscribeable<T> = {
        AnySubscribeable(observer: self)
    }()

	/**
	 Subscribe to changes of this observable

	 - parameter handler: Code to call when this observer changes
	 - returns: DisposeType that can be sent to a `DisposeBag` to clean up
	 - SeeAlso: `DisposeBag`
	 */
    public func subscribe(_ handler: @escaping ((T) -> Void)) {
        _ = subscribeWithDispose(handler)
    }

    public func subscribeWithDispose(_ handler: @escaping ((T) -> Void)) -> Disposeable<T> {
        let disposable = Disposeable<T>(handler: handler,
                                        observable: self)

        observables.append(disposable)

        return disposable
    }

	/**
	 Unsubscribe from a previous subscription

	 - parameter handler: Handler to unsubscribe
	 */
    public func unsubscribe(_ handler: Disposeable<T>) {
        let index = observables.allObjects.compactMap { $0 as? Disposeable<T> }
            .index { $0.uuid == handler.uuid }

        if let index = index {
            observables.removePointer(at: index)
        }
    }

    /// Assign value causing subscribers to be notified.
    public var value: T {
        didSet {
            onNext(value)
        }
    }

    public func onNext(_ value: T) {
        observables.allObjects.compactMap { $0 as? Disposeable<T> }
            .compactMap { $0.handler }
            .forEach { $0(value) }
    }
}
