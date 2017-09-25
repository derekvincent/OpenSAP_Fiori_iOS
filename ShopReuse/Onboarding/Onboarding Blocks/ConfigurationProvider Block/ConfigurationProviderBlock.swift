//
//  ConfigurationProviderBlock.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon
import SAPFoundation
import SAPFiori

public class ConfigurationProviderBlock: UIViewController, UIBlock {

    fileprivate let logger = Logger.shared(forClass: ConfigurationProviderBlock.self)

    fileprivate typealias CompletionHandlerType = (ConfigurationProviderBlock.Output?, ConfigurationProviderBlock.ConfigurationProviderError?) -> Void
    fileprivate var completion: CompletionHandlerType?

    public typealias InputConfigType = Input
    public typealias OutputConfigType = Output
    public typealias ErrorType = ConfigurationProviderError

    public struct Input {

        var headlineText: String?
        var detailText: String?
        var primaryButtonText: String?
        var secondaryButtonText: String?
        var providers: ConfigurationProvider = [.managed, .file]

        init(providers: ConfigurationProvider?) {
            if providers != nil {
                self.providers = providers!
            }
        }

        init(headlineText: String, detailText: String, primaryButtonText: String, secondaryButtonText: String, providers: ConfigurationProvider?) {
            self.init(providers: providers)

            self.headlineText = headlineText
            self.detailText = detailText
            self.primaryButtonText = primaryButtonText
            self.secondaryButtonText = secondaryButtonText
        }
    }

    public struct Output {

        public var provider: ConfigurationProvider
        public var configuration: ConnectionParameters?

        public init(provider: ConfigurationProvider, configuration: ConnectionParameters?) {

            self.provider = provider
            self.configuration = configuration
        }
    }

    public enum ConfigurationProviderError: Error {

    }

    private var _initialViewController: UIViewController?

    public var initialViewController: UIViewController {
        return _initialViewController!
    }

    fileprivate var welcomeScreenBlock: WelcomeScreenBlock!
    fileprivate var configurationLoader: ConfigurationLoader?
    private var configurationProviders: [ConfigurationProviding] = [ManagedConfigurationProvider(), FileConfigurationProvider()]
    fileprivate var input: ConfigurationProviderBlock.Input?
    fileprivate var currentProvider: ConfigurationProviding?

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _initialViewController = UIViewController()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func process(input: ConfigurationProviderBlock.Input, completion: @escaping (ConfigurationProviderBlock.Output?, ConfigurationProviderBlock.ConfigurationProviderError?) -> Void) {

        self.completion = completion
        self.input = input
        includeProviders(input.providers)

        configurationLoader = ConfigurationLoader(delegate: self, customQueueOfConfigurationProviders: configurationProviders)
        configurationLoader?.loadConfiguration()
    }

    private func includeProviders(_ providers: ConfigurationProvider) {

        if providers.contains(.managed) {
            configurationProviders.append(ManagedConfigurationProvider())
        }
        if providers.contains(.file) {
            configurationProviders.append(FileConfigurationProvider())
        }
        if providers.contains(.discoveryService) {
            configurationProviders.append(DiscoveryServiceConfigurationProvider())
        }
        if providers.contains(.qrCode) {
            configurationProviders.append(QRCodeConfigurationProvider())
        }
    }
}

public struct ConfigurationProvider: OptionSet {

    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let managed = ConfigurationProvider(rawValue: 1)
    public static let file = ConfigurationProvider(rawValue: 2)
    public static let discoveryService = ConfigurationProvider(rawValue: 4)
    public static let qrCode = ConfigurationProvider(rawValue: 8)
}

// MARK: - ConfigurationLoaderDelegate
extension ConfigurationProviderBlock: ConfigurationLoaderDelegate {

    public func configurationProvider(_ provider: ConfigurationProviding, didCompleteWith result: Bool) {

        if let config = readConfigFromUserDefaults() {
            if provider is ManagedConfigurationProvider {
                completion?(ConfigurationProviderBlock.Output(provider: .managed, configuration: config), nil)

            } else if provider is FileConfigurationProvider {
                completion?(ConfigurationProviderBlock.Output(provider: .file, configuration: config), nil)

            } else if provider is DiscoveryServiceConfigurationProvider {
                completion?(ConfigurationProviderBlock.Output(provider: .discoveryService, configuration: config), nil)

            } else if provider is QRCodeConfigurationProvider {
                completion?(ConfigurationProviderBlock.Output(provider: .qrCode, configuration: config), nil)

            }
        }
    }

    fileprivate func readConfigFromUserDefaults() -> ConnectionParameters? {

        let dict = UserDefaults.standard.object(forKey: ConfigurationProviderUserDefaultsKey)

        if let configuration = dict as? [AnyHashable: Any] {
            if let jsonData = configuration[QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue] as? String {
                // swiftlint:disable:next force_try
                return try! ConnectionParametersParser.parseString(value: jsonData)
            } else {
                if let jsonString = ConnectionParametersParser.parsePList(configuration: configuration) {
                    // swiftlint:disable:next force_try
                    return try! ConnectionParametersParser.parseString(value: jsonString)
                }
            }
        }
        logger.error("Configuration could not be loaded.")
        return nil
    }

    public func configurationProvider(_ provider: ConfigurationProviding, didEncounter error: Error) {
        logger.error("Configuration provider encountered an error")
    }

    public func configurationProvider(_ provider: ConfigurationProviding, requestedInput: [String: [String: Any]], completionHandler: @escaping ([String: [String: Any]]) -> Void) {

        let result: [String: [String: Any]] = [:]
        currentProvider = provider

        if provider is DiscoveryServiceConfigurationProvider {

            if requestedInput[provider.providerIdentifier]?[ConfigurationProviderInputKeys.emailAddress.rawValue] == nil {
                completionHandler(result)
            }

            let activationScreen = FUIActivationScreen.createInstanceFromStoryboard()
            activationScreen.delegate = self
            if let input = self.input {
                if let headline = input.headlineText, let detail = input.detailText, let primary = input.primaryButtonText, let secondary = input.secondaryButtonText {
                    activationScreen.headlineLabel.text = headline
                    activationScreen.detailLabel.text = detail
                    activationScreen.primaryActionButton.setTitle(primary, for: .normal)
                    activationScreen.secondaryActionButton.setTitle(secondary, for: .normal)
                }
            }
            initialViewController.show(activationScreen, sender: self)

        } else if provider is QRCodeConfigurationProvider {

            if requestedInput[provider.providerIdentifier]?[QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue] == nil {
                completionHandler(result)
            }

            let scanViewController = FUIOnboardingScanViewController.createInstanceFromStoryboard()
            scanViewController.delegate = self
            initialViewController.show(scanViewController, sender: self)
        }
        completionHandler(result)
    }
}

// MARK: - FUIOnboardingScanViewControllerDelegate
extension ConfigurationProviderBlock: FUIOnboardingScanViewControllerDelegate {

    public func scanViewController(_ scanViewController: FUIOnboardingScanViewController, shouldValidateScanResult scanResult: String) -> Bool {

        let resultFromScan: [String: [String: Any]] = [QRCodeConfigurationProvider.ProviderName: [QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue: scanResult]]
        configurationLoader?.loadConfiguration(userInputs: resultFromScan)
        return true
    }
}

// MARK: - FUIWelcomeControllerDelegate
extension ConfigurationProviderBlock: FUIWelcomeControllerDelegate {

    public func welcomeController(_ welcomeController: FUIWelcomeController, shouldTryUserEmail userEmail: String) {

        let resultFromInput: [String: [String: Any]] = [(currentProvider?.providerIdentifier)!: [ConfigurationProviderInputKeys.emailAddress.rawValue: userEmail]]
        configurationLoader?.loadConfiguration(userInputs: resultFromInput)
    }

    public func welcomeController(_ welcomeController: FUIWelcomeController, willNavigateToScannerScreen scanController: FUIOnboardingScanViewController) {

        scanController.delegate = self
    }
}
