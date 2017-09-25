//
//  StandardOAuthFlowResult.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon
import SAPFoundation

public final class StandardOAuthFlowResult: OnboardingResult {

    private let logger = Logger.shared(forClass: StandardOAuthFlowResult.self)

    private static let connectionKey = "com.sap.mobile.apps.toolkit.onboarding.Connection"

    /// the dictionary backing this result structure
    private var backingDictionary: [String: Any] = [:]

    private var _sapUrlSession: SAPURLSession?
    public var sapUrlSession: SAPURLSession? {
        get {
            return _sapUrlSession
        }
        set {
            _sapUrlSession = newValue
        }
    }

    private var _authManager: AuthorizationManagerProtocol?
    public var authManager: AuthorizationManagerProtocol {
        get {
            if _authManager == nil {
                _authManager = AuthorizationManager()
            }
            return _authManager!
        }
        set {
            _authManager = newValue
        }
    }

    private var _connectionParameters: ConnectionParameters?
    public var connectionParameters: ConnectionParameters? {
        get {
            return _connectionParameters
        }
        set {
            _connectionParameters = newValue
            backingDictionary[StandardOAuthFlowResult.connectionKey] = newValue?.jsonString
        }
    }

    init(connectionParameters: ConnectionParameters) {

        backingDictionary[StandardOAuthFlowResult.connectionKey] = connectionParameters
    }

    public init() {}

    private init(json: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json, options: [])

            guard jsonObject is [String: Any] else {
                fatalError("Error! Json Data could not be cast to dictionary.")
            }

            backingDictionary = jsonObject as! [String: Any]
            if let jsonString = backingDictionary[StandardOAuthFlowResult.connectionKey] as? String {
                // swiftlint:disable:next force_try
                _connectionParameters = try! ConnectionParametersParser.parseString(value: jsonString)
            }
        } catch {
            fatalError("Error! Json Data coult not be deserialed into JSONObject. Error: \(error).")
        }
    }

    public func serialize() -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: backingDictionary)
        } catch {
            fatalError("Error while creating JSON Data from dictionary: \(error)")
        }
    }

    public static func deserialize(_ data: Data) -> StandardOAuthFlowResult {
        return StandardOAuthFlowResult(json: data)
    }
}
