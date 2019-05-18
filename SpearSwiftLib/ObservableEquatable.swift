//
//  ObservableEquatable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 9/29/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

/**
 Observable that requires Equtable values.
 Does not raise onNext if old and new values are the same
 */
public class ObservableEquatable<T: Equatable>: Observable<T> {
    public private(set) var oldValue: T?

    public override func onNext(_ value: T) {
        defer { oldValue = value }

        guard let oldValue = oldValue else {
            super.onNext(value)
            return
        }

        if oldValue == value { return }

        super.onNext(value)
    }
}
