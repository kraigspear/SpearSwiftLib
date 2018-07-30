//
//  OperationWithClosure.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/19/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

/// Closure that takes another closure
public typealias OperationWithClosureClosure = (((@escaping () -> Void)) -> Void)

public final class OperationWithClosure: BaseOperation {
    private let closure: OperationWithClosureClosure

    public init(closure: @escaping OperationWithClosureClosure) {
        self.closure = closure
    }

    public override func main() {
        closure { [weak self] in
            self?.done()
        }
    }
}
