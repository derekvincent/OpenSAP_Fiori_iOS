//
//  ConnectionParameters.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon

fileprivate let connectionParameterAppIdKey = "appId"
fileprivate let connectionParameterClientIdKey = "clientId"
fileprivate let connectionParameterServerUrlKey = "serverUrl"
fileprivate let connectionParameterAuthUrlKey = "authUrl"
fileprivate let connectionParameterRedirectUrlKey = "redirectUrl"
fileprivate let connectionParameterTokenUrlKey = "tokenUrl"

public struct ConnectionParameters {

    let logger = Logger.shared(named: "ConnectionParameters")

    public var jsonString: String = ""
    public var appId: String = ""
    public var clientId: String = ""
    public var serverUrlString: String = ""
    public var authorizationUrlString: String = ""
    public var redirectUrlString: String = ""
    public var tokenUrlString: String = ""

    public var serverURL: URL? {
        if let url = URL(string: serverUrlString) {
            return url
        }
        logger.error("Server URL could not be parsed correctly, please check url in provided configuration data.")
        return nil
    }

    public var authorizationURL: URL? {
        if let url = URL(string: authorizationUrlString) {
            return url
        }
        logger.error("Authorization URL could not be parsed correctly, please check url in provided configuration data.")
        return nil
    }

    public var redirectURL: URL? {
        if let url = URL(string: redirectUrlString) {
            return url
        }
        logger.error("Redirect URL could not be parsed correctly, please check url in provided configuration data.")
        return nil
    }

    public var tokenURL: URL? {
        if let url = URL(string: tokenUrlString) {
            return url
        }
        logger.error("Token URL could not be parsed correctly, please check url in provided configuration data.")
        return nil
    }

    public init() {}

    public init(appId: String, clientId: String, serverUrl: String, authorizationUrl: String, redirectUrl: String, tokenUrl: String) {
        self.appId = appId
        self.clientId = clientId
        serverUrlString = serverUrl
        authorizationUrlString = authorizationUrl
        redirectUrlString = redirectUrl
        tokenUrlString = tokenUrl
    }

    public init?(json: Data) {

        guard let jsonObj = try? JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.allowFragments) else {
            return nil
        }
        guard let json = jsonObj as? [String: Any] else {
            return nil
        }
        guard let appId = json[connectionParameterAppIdKey] as? String, let clientId = json[connectionParameterClientIdKey] as? String else {
            return nil
        }

        let serverUrlString = json[connectionParameterServerUrlKey] as? String ?? ""
        let authUrlString = json[connectionParameterAuthUrlKey] as? String ?? ""
        let redirectUrlString = json[connectionParameterRedirectUrlKey] as? String ?? ""
        let tokenUrlString = json[connectionParameterTokenUrlKey] as? String ?? ""

        self.init(appId: appId, clientId: clientId, serverUrl: serverUrlString, authorizationUrl: authUrlString, redirectUrl: redirectUrlString, tokenUrl: tokenUrlString)
    }

    /// Creates JSON Data from the `OAuth2Token`.
    ///
    /// - Returns: The `Data` containing the JSON representation of the `OAuth2Token`. The result can be `nil` if there is an error with the `JSONSerialization`.
    public func json() -> Data? {
        var dictionary: [String: Any] = Dictionary()

        dictionary[connectionParameterAppIdKey] = appId
        dictionary[connectionParameterClientIdKey] = clientId
        dictionary[connectionParameterServerUrlKey] = serverUrlString
        dictionary[connectionParameterAuthUrlKey] = authorizationUrlString
        dictionary[connectionParameterRedirectUrlKey] = redirectUrlString
        dictionary[connectionParameterTokenUrlKey] = tokenUrlString

        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions()) else {
            return nil
        }

        return jsonData
    }

}
