//
//  StandardLoginFlow.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPCommon
import SAPFiori
import SAPFoundation

/// A LoginFlow implementation whose main purpose it is
/// to prompt the user for a login password and unlock
/// a secure store (passed as input) with it.
/// Application should initialize this login flow with
/// an InputParams instance containing the passcode policy
/// and secure store to unlock. Once Login has succeeded,
/// the secure store should be unlocked (opened) and ready
/// for reading and writing.
public class StandardLoginFlow: UINavigationController {

    fileprivate let logger: Logger = Logger.shared(forClass: StandardLoginFlow.self)

    fileprivate var passcodePolicyBlock: PasscodePolicyBlock!

    /// The struct defining the input parameters for this flow.
    public struct InputParams {

        public var sapUrlSession: SAPURLSession
        public var authManager: AuthorizationManagerProtocol
        public var connectionParameters: ConnectionParameters

        public init(sapUrlSession: SAPURLSession, authManager: AuthorizationManagerProtocol, connectionParameters: ConnectionParameters) {
            self.sapUrlSession = sapUrlSession
            self.authManager = authManager
            self.connectionParameters = connectionParameters
        }
    }

    fileprivate typealias CompletionHandlerType = (StandardLoginFlowResult?) -> Void
    fileprivate var completion: CompletionHandlerType?

    fileprivate var inputParams: InputParams?
    fileprivate var policy: FUIPasscodePolicy?

    /// Creates a new LoginFlow instance with the given input parameters.
    ///
    /// - Parameter inputParams: the input parameters this flow needs to function.
    public init(inputParams: InputParams) {
        let loginScreen = StandardLoginFlow.createLoginScreen()
        super.init(rootViewController: loginScreen)
        initialize(inputParams: inputParams)
        loginScreen.delegate = self
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// Creates a new LoginFlow instance from the given coder.
    /// This initializer is used when the flow is created from Storyboard or Nib.
    /// Applications using this initializer (and Storyboards) need to make sure that
    /// after instantiation, initialize(inputParams:) before the flow is shown.
    ///
    /// - Parameters coder: the decoder used to inflate the instance.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let loginScreen = StandardLoginFlow.createLoginScreen()
        viewControllers[0] = loginScreen
        loginScreen.delegate = self
        logger.warn("Warning! DefaultLoginFlow initialized from Storyboard or Nib. You need to call initialize(inputParams:) still to make sure the login flow can function properly.")
    }

    /// Allows for the initialization of the Default Login Flow
    /// even after it was created using a coder (i.e. when it is
    /// created from a storyboard. This method can e.g. be used
    /// in a prepareForSegue implementation to set the input parameters
    /// on the DefaultLoginFlow.
    ///
    /// - Parameter inputParams: the input parameters for this LoginFlow
    ///  to function properly.
    public func initialize(inputParams: InputParams) {

        self.inputParams = inputParams

    }
}

// MARK: - Login Flow Protocol Implementation
extension StandardLoginFlow: LoginFlow {

    public typealias ResultType = StandardLoginFlowResult

    public var initialViewController: UIViewController {
        return self
    }

    public func startLogin(_ completion: @escaping (StandardLoginFlowResult?) -> Void) {
        self.completion = completion
        guard inputParams != nil else {
            fatalError("Error! InputParameters are not set. Make sure to set them before starting login flow.")
        }
    }
}

// MARK: - View Creation
extension StandardLoginFlow {

    fileprivate static func createLoginScreen() -> FUIPasscodeInputController {
        return FUIPasscodeInputController.createInstanceFromStoryboard()
    }
}

// MARK: - FUIPasscodeControllerDelegate
extension StandardLoginFlow: FUIPasscodeControllerDelegate {

    public func shouldTryPasscode(_ passcode: String, forInputMode inputMode: FUIPasscodeInputMode, fromController passcodeController: FUIPasscodeController) throws {

        if inputMode != .match {
            fatalError("Error! FUIPasscodeInputController unexpectedly asked for passcode validation for input mode other than \".match\". Input mode was: \(inputMode)")
        }

        guard let inputParams = inputParams else {
            fatalError("Error! InputParameters are not set. Make sure to set them before starting login flow.")
        }

        if let serverUrl = inputParams.connectionParameters.serverURL {
            inputParams.authManager.validatePasscode(passcode, inputMode: inputMode, serverURL: serverUrl, completionHandler: { success in
                if success {
                    let loginResult = StandardLoginFlowResult(password: passcode)
                    completion?(loginResult)
                    completion = nil
                }
                // else {
                //    throw FUIPasscodeControllerError.invalidPasscode(3, FUIPasscodePolicy.passcodePolicyNoLimit)
                // }
                return
            })
        }
    }

    public func didCancelPasscodeEntry(fromController _: FUIPasscodeController) {
        logger.debug("FUIPasscodeControllerDelegate.didCancelPasscodeEntry(fromController:) called.")
    }

    public func didSkipPasscodeSetup(fromController _: FUIPasscodeController) {
        logger.debug("FUIPasscodeControllerDelegate.didSkipPasscodeSetup(fromController:) called.")
        fatalError("Error! FUIPasscodeInputController unexpectedly called didSkipPasscodeEntry().")
    }

    public func shouldResetPasscode(fromController _: FUIPasscodeController) {
        logger.debug("FUIPasscodeControllerDelegate.shouldResetPasscode(fromController:) called.")
        fatalError("Error! FUIPasscodeInputController unexpectedly called shouldResetPasscode().")
    }

    public func passcodePolicy() -> FUIPasscodePolicy {
        return FUIPasscodePolicy()
    }
}
