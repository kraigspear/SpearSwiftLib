//
//  OperationWithType.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/23/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public enum ServiceResponse<Model> {
    case success(result: Model)
    case error(error: Error)
}

open class OperationWithType<T>: BaseOperation {
    var result: ServiceResponse<T>?
}
