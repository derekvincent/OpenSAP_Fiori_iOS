//
//  StandardLoginFlowResult.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon

/// A result structure for the login flow.
/// This struct mainly carries the user's login password,
/// which can be used by an application to encrypt / decrypt
/// secure storages for confidential data.
public struct StandardLoginFlowResult: LoginResult {

    private let logger = Logger.shared(forClass: StandardLoginFlowResult.self)

    private static let passwordKey = "com.sap.mobile.apps.toolkit.login.Password"

    /// The user's password as gathered by the login flow.
    /// The application can use this as a means to generate an
    /// encryption / decryption key if necessary.
    public var password: String {
        // swiftlint:disable force_cast
        return backingDictionary[StandardLoginFlowResult.passwordKey] as! String
        // swiftlint:enable force_cast
    }

    /// the dictionary backing this result structure
    private var backingDictionary: [String: Any] = [:]

    /// Initializes a new result instance with the password
    /// entered by the user.
    ///
    /// - Parameter password: the user's password as entered during the login.
    init(password: String) {
        backingDictionary[StandardLoginFlowResult.passwordKey] = password
    }

    /// Initializes a new result instance from JSON data.
    ///
    /// - Parameter json: the JSON data to initialize the instance from.
    private init(json: Data) {

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json, options: [])

            guard jsonObject is [String: Any] else {
                fatalError("Error! Json Data could not be cast to dictionary.")
            }

            // swiftlint:disable force_cast
            backingDictionary = jsonObject as! [String: Any]
            // swiftlint:enable force_cast
        } catch {
            fatalError("Error! Json Data coult not be deserialed into JSONObject. Error: \(error).")
        }
    }

    /// Serializes this instance to JSON data.
    ///
    /// - Returns: the JSON data this instance was serialized to.
    public func serialize() -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: backingDictionary)
        } catch {
            fatalError("Error while creating JSON Data from dictionary: \(error)")
        }
    }

    /// De-Serializes an instance from JSON.
    ///
    /// - Parameter data: the JSON data to de-serialize from.
    /// - Returns: the instance de-serialized from JSON.
    public static func deserialize(_ data: Data) -> StandardLoginFlowResult {
        return StandardLoginFlowResult(json: data)
    }
}
