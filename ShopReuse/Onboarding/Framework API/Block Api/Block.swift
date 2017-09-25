//
//  Block.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation

public protocol Block {

    associatedtype InputConfigType
    associatedtype OutputConfigType
    associatedtype ErrorType: Error

    func process(input: InputConfigType, completion: @escaping (OutputConfigType?, ErrorType?) -> Void)
}
