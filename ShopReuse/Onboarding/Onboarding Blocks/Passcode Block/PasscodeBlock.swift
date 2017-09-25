//
//  PasscodeBlock.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPFiori
import SAPCommon
import SAPFoundation

public class PasscodeBlock: UIBlock {

    fileprivate let logger = Logger.shared(forClass: PasscodeBlock.self)

    fileprivate typealias CompletionHandlerType = (PasscodeBlock.Output?, PasscodeBlock.PasscodeError?) -> Void
    fileprivate var completion: CompletionHandlerType?

    public typealias InputConfigType = Input
    public typealias OutputConfigType = Output
    public typealias ErrorType = PasscodeError

    public struct Input {

        public var passcodePolicy: FUIPasscodePolicy
        public var token: OAuth2Token
        public var serverUrl: URL

        public init(passcodePolicy: FUIPasscodePolicy, token: OAuth2Token, serverUrl: URL) {
            self.passcodePolicy = passcodePolicy
            self.token = token
            self.serverUrl = serverUrl
        }
    }

    public struct Output {
        var passcodeInputMode: FUIPasscodeInputMode
        var passcode: String
        var authManager: AuthorizationManagerProtocol

        init(passcode: String, passcodeInputMode: FUIPasscodeInputMode, authManager: AuthorizationManagerProtocol) {
            self.passcode = passcode
            self.passcodeInputMode = passcodeInputMode
            self.authManager = authManager
        }
    }

    public enum PasscodeError: Error {

    }

    public var initialViewController: UIViewController {
        passcodeCreateViewController.delegate = self
        return passcodeCreateViewController
    }

    fileprivate var passcodeCreateViewController: FUIPasscodeCreateController
    fileprivate var input: PasscodeBlock.Input?

    public init() {
        passcodeCreateViewController = FUIPasscodeCreateController.createInstanceFromStoryboard()
    }

    public func process(input: PasscodeBlock.Input, completion: @escaping (PasscodeBlock.Output?, PasscodeBlock.PasscodeError?) -> Void) {
        self.completion = completion
        self.input = input
    }
}

extension PasscodeBlock: FUIPasscodeControllerDelegate {

    public func shouldResetPasscode(fromController passcodeController: FUIPasscodeController) {

    }

    public func didSkipPasscodeSetup(fromController passcodeController: FUIPasscodeController) {

    }

    public func didCancelPasscodeEntry(fromController passcodeController: FUIPasscodeController) {

    }

    public func shouldTryPasscode(_ passcode: String, forInputMode inputMode: FUIPasscodeInputMode, fromController passcodeController: FUIPasscodeController) throws {

        let authorizationManager = AuthorizationManager(token: input?.token)
        authorizationManager.validatePasscode(passcode, inputMode: inputMode, serverURL: input!.serverUrl, completionHandler: { _ in

            let output = PasscodeBlock.Output(passcode: passcode, passcodeInputMode: inputMode, authManager: authorizationManager)
            self.completion?(output, nil)
        })
    }

    public func passcodePolicy() -> FUIPasscodePolicy {
        if let input = input {
            return input.passcodePolicy
        } else {
            var passcodePolicy = FUIPasscodePolicy()
            passcodePolicy.isDigitsOnly = true
            passcodePolicy.minLength = 4
            passcodePolicy.hasLower = false
            passcodePolicy.hasUpper = false
            passcodePolicy.hasSpecial = false
            return passcodePolicy
        }
    }
}
