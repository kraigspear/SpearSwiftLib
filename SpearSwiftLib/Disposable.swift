//
//  Disposable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/16/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public protocol DisposeType: class {
    func unsubscribe()
}

public final class Disposeable<T>: DisposeType {
    let uuid = UUID().uuidString
    let handler: ((T) -> Void)?

    var observable: Observable<T>?

    init(handler: @escaping ((T) -> Void),
         observable: Observable<T>) {
        self.handler = handler
        self.observable = observable
    }

    public func unsubscribe() {
        guard let observable = self.observable else { return }
        observable.unsubscribe(self)
    }
}
