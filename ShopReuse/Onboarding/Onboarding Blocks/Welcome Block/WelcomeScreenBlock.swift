//
//  WelcomeScreenBlock.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFiori
import SAPCommon
import SAPFoundation

public protocol WelcomeScreenBlockDelegate: class {

    func welcomeScreenBlock(_ welcomeScreenBlock: WelcomeScreenBlock, nextButtonTapped button: UIButton)
    func welcomeScreenBlock(_ welcomeScreenBlock: WelcomeScreenBlock, startDemoModeButtonTapped button: UIButton)
}

public class WelcomeScreenBlock: UIBlock {

    fileprivate let logger = Logger.shared(forClass: WelcomeScreenBlock.self)

    fileprivate typealias CompletionHandlerType = (WelcomeScreenBlock.Output?, WelcomeScreenBlock.WelcomeScreenBlockError?) -> Void
    fileprivate var completion: CompletionHandlerType?

    public typealias InputConfigType = Input
    public typealias OutputConfigType = Output
    public typealias ErrorType = WelcomeScreenBlockError

    public struct Input {

        var headlineText = ""
        var detailText = ""
        var actionButtonText = ""
        var isDemoAvailable = false

        init(headlineText: String, detailText: String, actionButtonText: String, isDemoAvailable: Bool = false) {
            self.headlineText = headlineText
            self.detailText = detailText
            self.actionButtonText = actionButtonText
            self.isDemoAvailable = isDemoAvailable
        }
    }

    public struct Output {

    }

    public enum WelcomeScreenBlockError: Error {

    }

    private var _initialViewController: UIViewController?

    public var initialViewController: UIViewController {
        return _initialViewController!
    }

    fileprivate var welcomeScreen: FUIWelcomeScreen
    public weak var delegate: WelcomeScreenBlockDelegate?

    public init() {

        welcomeScreen = FUIWelcomeScreen.createInstanceFromStoryboard()
        welcomeScreen.delegate = self
        welcomeScreen.state = .isConfigured
        _initialViewController = welcomeScreen
    }

    public func process(input: WelcomeScreenBlock.Input, completion: @escaping (WelcomeScreenBlock.Output?, WelcomeScreenBlock.WelcomeScreenBlockError?) -> Void) {

        self.completion = completion

        welcomeScreen.headlineLabel.text = input.headlineText
        welcomeScreen.detailLabel.text = input.detailText
        welcomeScreen.primaryActionButton.setTitle(input.actionButtonText, for: .normal)
        welcomeScreen.isDemoAvailable = input.isDemoAvailable

        completion(nil, nil)
    }
}

// MARK: - FUIWelcomeControllerDelegate
extension WelcomeScreenBlock: FUIWelcomeControllerDelegate {

    public func didSelectDemoMode(_ welcomeController: FUIWelcomeController) {

        delegate?.welcomeScreenBlock(self, startDemoModeButtonTapped: welcomeScreen.footnoteActionButton)
    }

    public func shouldContinueUserOnboarding(_ welcomeController: SAPFiori.FUIWelcomeController) {

        delegate?.welcomeScreenBlock(self, nextButtonTapped: welcomeScreen.primaryActionButton)
    }
}
