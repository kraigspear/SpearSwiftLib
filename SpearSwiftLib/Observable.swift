//
//  Observable.swift
//  MeijerGo
//
//  Created by kraig spear on 3/15/18.
//  Copyright © 2018 Meijer. All rights reserved.
//

import Foundation


public final class Observable<T> {
	private var observables: [Disposeable<T>] = []
	
	public init(value: T) {
		self.value = value
	}
	
	public func subscribe(_ handler: @escaping ((T) -> Void)) -> DisposeType {
		let disposable = Disposeable<T>(handler: handler,
		                                observable: self)
		
		observables.append(disposable)
		
		return disposable
	}
	
	public func unsubscribe(_ handler: Disposeable<T>) {
		let index = observables.index { $0.uuid == handler.uuid }
		
		if let index = index {
			observables.remove(at: index)
		}
	}
	
	public var value: T {
		didSet {
			observables.flatMap { $0.handler }
				.forEach { $0(value) }
		}
	}
}
