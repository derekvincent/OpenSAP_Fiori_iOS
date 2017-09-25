//
//  OnboardingFlow.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit

/// Protocol defining an onboarding flow's characteristics.
/// All future implementations of an onboarding flow
/// have to implement this protocol. Flow implementations
/// also should define a dedicated result object as well as
/// consider creating their own error type. Both result type and
/// error type need to be typealiases for the associated types of
/// this protocol.
public protocol OnboardingFlow {

    /// The result type of this onboarding flow.
    associatedtype ResultType: OnboardingResult

    /// The error type fo the onboarding flow.
    associatedtype ErrorType: Error

    /// Accessor for the intial view controller of the onboarding flow.
    var initialViewController: UIViewController { get }

    /// Function to start the onboarding process.
    /// This function takes a completion handler that needs to
    /// be called back when onboarding succeeded or in case of an error.
    /// Calling back with a nil result and nil error, is interpreted as
    /// successful onboarding without any result.
    ///
    /// - Parameter completion: the completion block to be called after onboarding.
    func startOnboarding(_ completion: @escaping (ResultType?, ErrorType?) -> Void)
}

/// The protocol describing onboarding results. Implementations of onboarding result
/// structures need to implement this protocol.
public protocol OnboardingResult {

    /// Function returning a serialized version of the onboarding result.
    ///
    /// - Returns: the serialized version of the onboarding result.
    func serialize() -> Data

    /// Function returning the deserialized version of the onboarding result.
    ///
    /// - Parameter data: the serialized data of the onboarding result.
    /// - Returns: the deserialized onboarding result instance.
    static func deserialize(_ data: Data) -> Self
}
