//
//  ConnectionParameterParser.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation

public enum ConnectionParametersParserError: Error {
    case deserializationFailed
    case propertyParsingFailed
    case urlParsingFailed
}

public class ConnectionParametersParser {

    public class func parsePList(configuration: [AnyHashable: Any]) -> String? {

        var jsonDict = [String: String]()
        for (key, value) in configuration {
            jsonDict[key as! String] = value as? String
        }

        // swiftlint:disable:next force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)

        return String(data: jsonData, encoding: .utf8)
    }

    public class func parseString(value: String) throws -> ConnectionParameters? {
        var connectionParameter = ConnectionParameters()

        let data = value.data(using: .utf8)!
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                connectionParameter = extract(data: json)!
                connectionParameter.jsonString = value
            }
        } catch {
            throw ConnectionParametersParserError.deserializationFailed
        }

        return connectionParameter
    }

    private class func extract(data: [String: AnyObject]) -> ConnectionParameters? {
        var connectionParameter = ConnectionParameters()
        var configurationData = data

        guard let appId = configurationData["appId"] as? String,
            let clientId = configurationData["clientId"] as? String else {
            return nil
        }
        connectionParameter.appId = appId
        connectionParameter.clientId = clientId

        // Server Url + ServiceUrl
        guard let serverUrl = configurationData["serverUrl"] as? String,
            let authUrl = configurationData["authUrl"] as? String,
            let tokenUrl = configurationData["tokenUrl"] as? String,
            let redirectUrl = configurationData["redirectUrl"] as? String else {
            return nil
        }

        // Server Url
        connectionParameter.serverUrlString = serverUrl

        // OAuth Url
        connectionParameter.authorizationUrlString = authUrl

        // Redirect Url
        connectionParameter.redirectUrlString = redirectUrl

        // Token Url
        connectionParameter.tokenUrlString = tokenUrl

        return connectionParameter
    }
}
