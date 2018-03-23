//
//  Observable.swift
//  MeijerGo
//
//  Created by kraig spear on 3/16/18.
//  Copyright © 2018 Spearware. All rights reserved.
//

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
public final class Observable<T> {
	/// Reference to observers as pointers
	private var observables = NSPointerArray.weakObjects()
	
	private let uuid = UUID.init().uuidString
	
	/**
	Initialize with the inital value
	
	- parameter value: The initial value of this observable
	*/
	public init(value: T) {
		self.value = value
	}
	
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
		let index = observables.allObjects.flatMap { $0 as? Disposeable<T> }
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
		assert(Thread.isMainThread)
		print("onNext count: \(observables.count) \(uuid)")
		observables.allObjects.flatMap { $0 as? Disposeable<T> }
			.flatMap { $0.handler }
			.forEach { $0(value) }
	}
}

