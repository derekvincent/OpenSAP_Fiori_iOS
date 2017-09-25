//
//  StandardOAuthFlow.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPFoundation
import SAPCommon
import SAPFiori

public class StandardOAuthFlow: UINavigationController, OnboardingFlow {

    fileprivate let logger = Logger.shared(forClass: StandardOAuthFlow.self)

    public typealias ResultType = StandardOAuthFlowResult
    public typealias ErrorType = StandardOAuthFlowError

    typealias CompletionHandlerType = (ResultType?, ErrorType?) -> Void
    fileprivate var completion: CompletionHandlerType?

    fileprivate var finalResult = ResultType()

    public var initialViewController: UIViewController {
        view.backgroundColor = .white
        return self
    }

    private var welcomeScreenBlock: WelcomeScreenBlock!
    private var configurationProviderBlock: ConfigurationProviderBlock!
    private var oAuthBlock: OAuthBlock!
    private var passcodePolicyBlock: PasscodePolicyBlock!
    private var passcodeBlock: PasscodeBlock!

    public init() {
        let welcomeScreenBlock = WelcomeScreenBlock()
        super.init(navigationBarClass: FUINavigationBar.self, toolbarClass: nil)
        self.welcomeScreenBlock = welcomeScreenBlock
        self.welcomeScreenBlock.delegate = self
        pushViewController(self.welcomeScreenBlock.initialViewController, animated: true)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// Starts the onboarding flow.
    /// In case the user taps "Start Demo Mode", the onboarding flow will
    /// return with `StandardOAuthFlowError.abortedForDemoMode`
    ///
    /// - Parameter completion: the completion block called with the onboarding result or the error.
    public func startOnboarding(_ completion: @escaping (ResultType?, ErrorType?) -> Void) {

        self.completion = completion

        let welcomeScreenInput = WelcomeScreenBlock.Input(headlineText: "Thank you for downloading.", detailText: "Please start the activation process.", actionButtonText: "Start")
        welcomeScreenBlock.process(input: welcomeScreenInput) { _, error in
            if error != nil {
                self.completion?(nil, StandardOAuthFlowError.internalError(error!))
            }
        }
    }

    fileprivate func runConfigurationProvider() {
        configurationProviderBlock = ConfigurationProviderBlock()
        pushViewController(configurationProviderBlock.initialViewController, animated: true)

        configurationProviderBlock.process(input: ConfigurationProviderBlock.Input(providers: [.file, .qrCode])) { output, error in
            if error != nil {
                self.logger.error("Error during processing configuration provider")
                self.completion?(nil, StandardOAuthFlowError.internalError(error!))
            } else {
                if let parameters = output?.configuration {
                    if parameters.appId.isEmpty || parameters.clientId.isEmpty {
                        fatalError("Configuration loading failed. Please make sure the provided configuration provides data in the correct format.")
                    }
                    self.finalResult.connectionParameters = parameters
                    self.runAuthorizationBlock(connectionParameters: parameters)
                }
            }
        }
    }

    fileprivate func runAuthorizationBlock(connectionParameters: ConnectionParameters) {
        oAuthBlock = OAuthBlock()
        oAuthBlock.process(input: OAuthBlock.Input(connectionParameters: connectionParameters)) { output, error in
            if error != nil {
                self.logger.error("Error during processing configuration provider")
                self.completion?(nil, StandardOAuthFlowError.internalError(error!))
            } else {
                if let sapUrlSession = output?.sapUrlSession, let token = output?.oAuthToken {
                    self.finalResult.sapUrlSession = sapUrlSession
                    self.runPasscodePolicyBlock(connectionParameters: connectionParameters, sapURLSession: sapUrlSession, token: token)
                }
            }
        }
    }

    fileprivate func runPasscodePolicyBlock(connectionParameters: ConnectionParameters, sapURLSession: SAPURLSession, token: OAuth2Token) {
        passcodePolicyBlock = PasscodePolicyBlock()
        if let serverUrl = connectionParameters.serverURL {
            passcodePolicyBlock.process(input: PasscodePolicyBlock.Input(appId: connectionParameters.appId, serverUrl: serverUrl, sapUrlSession: sapURLSession), completion: { output, error in
                if error != nil {
                    self.logger.error("Error while retrieving passcode policy")
                    self.completion?(nil, StandardOAuthFlowError.internalError(error!))
                } else {
                    if let policy = output?.passcodePolicy {
                        self.runPasscodeBlock(passcodePolicy: policy, token: token, serverUrl: serverUrl)
                    }
                }
            })
        }
    }

    fileprivate func runPasscodeBlock(passcodePolicy: FUIPasscodePolicy, token: OAuth2Token, serverUrl: URL) {
        passcodeBlock = PasscodeBlock()
        pushViewController(passcodeBlock.initialViewController, animated: true)

        passcodeBlock.process(input: PasscodeBlock.Input(passcodePolicy: passcodePolicy, token: token, serverUrl: serverUrl)) { output, error in
            if error != nil {
                self.completion?(nil, StandardOAuthFlowError.internalError(error!))
            } else {
                if output?.passcodeInputMode == .create {
                    self.finalResult.authManager = (output?.authManager)!
                    self.completion?(self.finalResult, nil)
                }
            }
        }
    }
}

extension StandardOAuthFlow: WelcomeScreenBlockDelegate {

    public func welcomeScreenBlock(_ welcomeScreenBlock: WelcomeScreenBlock, nextButtonTapped button: UIButton) {
        setNavigationBarHidden(false, animated: false)
        runConfigurationProvider()
    }

    public func welcomeScreenBlock(_ welcomeScreenBlock: WelcomeScreenBlock, startDemoModeButtonTapped button: UIButton) {

        completion?(nil, StandardOAuthFlowError.abortedForDemoMode)
        completion = nil // free resources and release block!
    }
}
