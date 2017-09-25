//
//  LoginFlow.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit

/// Protocol defining a login flow's characteristics.
/// All future implementations of an login flows
/// have to implement this protocol. Flow implementations
/// also should define a dedicated result object. The result
/// type needs to be typealias for the associated type of
/// this protocol.

public protocol LoginFlow {

    /// The result type of this login flow.
    associatedtype ResultType: LoginResult
    /// Accessor for the intial view controller of the onboarding flow.
    var initialViewController: UIViewController { get }
    /// Function to start the login process.
    /// This function takes a completion handler that needs to
    /// be called back when login succeeded.
    ///
    /// - Parameter completion: the completion block to be called after login.
    func startLogin(_ completion: @escaping (ResultType?) -> Void)
}

/// The protocol describing login results. Implementations of onboarding result
/// structures need to implement this protocol.
public protocol LoginResult {

    /// Function returning a serialized version of the login result.
    ///
    /// - Returns: the serialized version of the login result.
    func serialize() -> Data

    /// Function returning the deserialized version of the login result.
    ///
    /// - Parameter data: the serialized data of the login result.
    /// - Returns: the deserialized login result instance.
    static func deserialize(_ data: Data) -> Self
}
