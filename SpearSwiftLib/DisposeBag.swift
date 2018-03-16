//
//  DisposeBag.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/16/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public final class DisposeBag {
	private var disposables: [DisposeType] = []
	
	public init() {}
	
	public func add(disposable: DisposeType) {
		disposables.append(disposable)
	}
	
	deinit {
		disposeAll()
	}
	
	private func disposeAll() {
		disposables.forEach { $0.unsubscribe() }
		disposables.removeAll()
	}
}
