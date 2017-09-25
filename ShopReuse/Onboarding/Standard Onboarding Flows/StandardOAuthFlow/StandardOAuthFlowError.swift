//
//  StandardOAuthFlowError.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation

public enum StandardOAuthFlowError: Error {

    case internalError(Error)

    case abortedForDemoMode
}
