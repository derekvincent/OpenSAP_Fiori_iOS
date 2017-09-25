//
//  ConnectionManager.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFoundation
import SAPCommon

public class ConnectionManager {

    public static let shared = ConnectionManager()

    private init() {}

    private var _authManager: AuthorizationManagerProtocol?
    private var oAuthUrlSessionController: OAuthUrlSessionController?

    public var onboardingResult: StandardOAuthFlowResult? {
        didSet {
            if let authManager = onboardingResult?.authManager {
                _authManager = authManager
            }
        }
    }

    public var connectionParameters: ConnectionParameters? {
        return onboardingResult?.connectionParameters
    }

    public var sapUrlSession: SAPURLSession? {
        return getUrlSession()
    }

    public var authManager: AuthorizationManagerProtocol? {
        return _authManager
    }

    private func getUrlSession() -> SAPURLSession? {
        if let onboardingResult = onboardingResult {
            if onboardingResult.sapUrlSession == nil {
                oAuthUrlSessionController = OAuthUrlSessionController(connectionParameter: onboardingResult.connectionParameters!, tokenStore: onboardingResult.authManager)
                onboardingResult.sapUrlSession = oAuthUrlSessionController?.sapUrlSession
            }
            return onboardingResult.sapUrlSession
        }
        return nil
    }
}
