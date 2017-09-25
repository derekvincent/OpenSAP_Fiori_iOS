//
//  OAuthBlock.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon
import SAPFoundation
import SAPFiori

public class OAuthBlock: Block {

    fileprivate let logger = Logger.shared(forClass: OAuthBlock.self)

    fileprivate typealias CompletionHandlerType = (OAuthBlock.Output?, OAuthBlock.OAuthError?) -> Void

    public typealias InputConfigType = Input
    public typealias OutputConfigType = Output
    public typealias ErrorType = OAuthError

    public struct Input {

        var connectionParameters: ConnectionParameters

        public init(connectionParameters: ConnectionParameters) {

            self.connectionParameters = connectionParameters
        }
    }

    public struct Output {

        public var oAuthToken: OAuth2Token
        public var sapUrlSession: SAPURLSession

        public init(oAuthToken: OAuth2Token, sapUrlSession: SAPURLSession) {

            self.oAuthToken = oAuthToken
            self.sapUrlSession = sapUrlSession
        }
    }

    public enum OAuthError: Error {
        case authenticationFailed
    }

    private var oAuthUrlSessionController: OAuthUrlSessionController!

    public func process(input: OAuthBlock.Input, completion: @escaping (OAuthBlock.Output?, OAuthBlock.OAuthError?) -> Void) {

        let tokenStore = TransientTokenStore()

        oAuthUrlSessionController = OAuthUrlSessionController(connectionParameter: input.connectionParameters, tokenStore: tokenStore)
        oAuthUrlSessionController.logon { token, error in
            guard error == nil else {
                completion(nil, .authenticationFailed)
                return
            }

            if let token = token {
                tokenStore.store(token: token, for: input.connectionParameters.serverURL!)
                completion(Output(oAuthToken: token, sapUrlSession: self.oAuthUrlSessionController.sapUrlSession), nil)
            }
        }
    }

    class TransientTokenStore: OAuth2TokenStore {

        var transientToken: OAuth2Token?

        public func store(token: OAuth2Token, for url: URL) {
            transientToken = token
        }

        public func token(for url: URL) -> OAuth2Token? {
            if let transientToken = transientToken {
                return transientToken
            }
            return nil
        }

        public func deleteToken(for url: URL) {
            transientToken = nil
        }
    }
}

public class OAuthUrlSessionController {

    static let logger = Logger.shared(named: "OAuthLogonController")
    private var connectionParams = ConnectionParameters()
    private var tokenStore: OAuth2TokenStore?

    public let sapUrlSession = SAPURLSession(configuration: .ephemeral)

    var authenticator: OAuth2Authenticator?

    // setup http client and interceptors for token store and webview presenting
    public init(connectionParameter: ConnectionParameters, tokenStore: OAuth2TokenStore) {

        connectionParams = connectionParameter
        self.tokenStore = tokenStore

        // setup HTTP client
        let parameters = createAuthorizationCodeGrantParams()

        authenticator = OAuth2Authenticator(authenticationParameters: parameters, sapURLSession: sapUrlSession, webViewPresenter: WKWebViewPresenter())
        registerObservers()
    }

    private func createAuthorizationCodeGrantParams() -> OAuth2AuthenticationParameters {
        return OAuth2AuthenticationParameters(
            authorizationEndpointURL: connectionParams.authorizationURL!,
            clientID: connectionParams.clientId,
            redirectURL: connectionParams.redirectURL!,
            tokenEndpointURL: connectionParams.tokenURL!,
            requestingScopes: Set<String>())
    }

    private func registerObservers() {
        if let authenticator = authenticator, let tokenStore = tokenStore {
            let oauthObserver = OAuth2Observer(authenticator: authenticator, tokenStore: tokenStore)

            sapUrlSession.register(SAPcpmsObserver(applicationID: connectionParams.appId))
            sapUrlSession.register(oauthObserver)
        }
    }

    public func logon(completionHandler: @escaping (OAuth2Token?, Error?) -> Void) {
        authenticator?.authenticate { token, error in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            if let token = token {
                completionHandler(token, nil)
            }
        }
    }
}
