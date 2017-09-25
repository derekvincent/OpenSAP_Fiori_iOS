//
//  AuthorizationManager.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon
import SAPFoundation
import SAPFiori
import LocalAuthentication
import WebKit

public protocol AuthorizationManagerProtocol: OAuth2TokenStore {

    func openSecureStore(password: String) -> Bool
    func changePasscode(to newPasscode: String)
    func writeDBoAuthStore(token: OAuth2Token?)
    func readDBoAuthStore() -> OAuth2Token?
    func validatePasscode(_ passcode: String, inputMode: FUIPasscodeInputMode, serverURL: URL, completionHandler: (_ success: Bool) -> Void)
    func closeStore()
    func resetStore()
}

public class AuthorizationManager: AuthorizationManagerProtocol {

    private static let logger = Logger.shared(named: "com.sap.mobile.apps.traing-shop")

    private let appVersionAtSecureStoreInitKey = "appVersionAtSecureStoreInit"
    private let oDataDateFormat = "yyyy-MM-dd'T'HH:mm:ss"

    var keyValueStore: SecureKeyValueStore?
    private let oAuthTokenStoreKey = "com.sap.mobile.apps.oauth.token"
    fileprivate var transientToken: SAPFoundation.OAuth2Token?

    var dateFormatter: DateFormatter

    var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    public var isAuthenticatedSuccessful: Bool {
        if let keyValueStore = keyValueStore {
            return keyValueStore.isOpen()
        }
        return false
    }

    var appVersionAtSecureStoreInit: String? {
        return UserDefaults.standard.string(forKey: appVersionAtSecureStoreInitKey)
    }

    public init(token: SAPFoundation.OAuth2Token? = nil) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oDataDateFormat
        transientToken = token
    }

    func initializeSecureStore() {
        if keyValueStore == nil {
            keyValueStore = SecureKeyValueStore()
        }
    }

    // check if the db can be opened with the provided encription key
    public func openSecureStore(password: String) -> Bool {
        do {
            try keyValueStore?.open(with: password)
        } catch let SecureStorageError.authenticationFailed(message) {
            AuthorizationManager.logger.error("Authentication failed while opening the secure store. \(message)")
            return false
        } catch let SecureStorageError.openFailed(_, message) {
            AuthorizationManager.logger.error("Failed to open the secure store. \(message)")
            return false
        } catch let error {
            AuthorizationManager.logger.error("An unknown error occured while opening the secure store.", error: error)
            return false
        }

        if (appVersionAtSecureStoreInit == nil) || (appVersionAtSecureStoreInit != appVersion) {
            // Secure store might need to be upgraded/reinitialized
        }

        return true
    }

    public func changePasscode(to newPasscode: String) {
        do {
            if let keyValueStore = keyValueStore {
                if keyValueStore.isOpen() {
                    try keyValueStore.changeEncryptionKey(with: newPasscode)
                }
            }
        } catch SecureStorageError.closed {
            AuthorizationManager.logger.error("Failed to change the encryption key because the secure store is closed.")
        } catch let SecureStorageError.encryptionKeyChangeFailed(code, message) {
            AuthorizationManager.logger.error("An error occured while changing the encryption key: \(message) Code: \(code)")
        } catch let error {
            AuthorizationManager.logger.error("An unknown error occured while changing the encryption key.", error: error)
        }
    }

    public func writeDBoAuthStore(token: OAuth2Token?) {
        do {
            if let keyValueStore = keyValueStore {
                if keyValueStore.isOpen() {
                    let jsonToken = token?.json()
                    try keyValueStore.put(jsonToken, forKey: oAuthTokenStoreKey)
                }
            }
        } catch let error {
            if case let SecureStorageError.backingStoreError(code, message) = error {
                if code != 0 && code != 100 {
                    AuthorizationManager.logger.error("An error occured while opening the database.", error: error)
                }
            }
        }
    }

    public func readDBoAuthStore() -> OAuth2Token? {
        do {
            if let keyValueStore = keyValueStore {
                if keyValueStore.isOpen() {
                    if let oAuthJSONData = try keyValueStore.getData(oAuthTokenStoreKey) {
                        return OAuth2Token(json: oAuthJSONData)
                    }
                }
            }
        } catch let error {
            if case let SecureStorageError.backingStoreError(code, message) = error {
                if code != 0 && code != 100 {
                    AuthorizationManager.logger.error("An error occured while opening the database.", error: error)
                }
            }
        }
        return nil
    }

    public func validatePasscode(_ passcode: String, inputMode: FUIPasscodeInputMode, serverURL: URL, completionHandler: (_ success: Bool) -> Void) {
        initializeSecureStore()

        if inputMode == .change {
            changePasscode(to: passcode)
            completionHandler(true)
            return
        } else if openSecureStore(password: passcode) {
            if let transientToken = transientToken {
                store(token: transientToken, for: serverURL)
            }

            switch inputMode {
            case .create:
                changePasscode(to: passcode)
                completionHandler(true)
                return
            case .match:
                completionHandler(true)
                return
            case .matchForChange:
                // Do not leave current screenflow, action not finished
                completionHandler(false)
                return
            default:
                completionHandler(false)
                return
            }
        }
        completionHandler(false)
        // Delegate for matching/non-matching passcode to notify user about wrong input??
    }

    // Logout only locks the device with the passcode again
    // Connection info, token and user are still connected with the app
    public func closeStore() {
        keyValueStore?.close()
    }

    // Disconnect removes all user and connection information
    // User has to start onboarding from scratch
    public func resetStore() {
        deleteToken(for: URL(string: "about:blank")!)
        keyValueStore?.close()
        clearCache()
    }

    func clearCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler: {})
    }
}

// MARK: - OAuth2TokenStore
extension AuthorizationManager: OAuth2TokenStore {

    public func store(token: SAPFoundation.OAuth2Token, for url: URL) {
        writeDBoAuthStore(token: token)
        transientToken = token
    }

    public func token(for url: URL) -> SAPFoundation.OAuth2Token? {
        if let transientToken = transientToken {
            return transientToken
        } else {
            return readDBoAuthStore()
        }
    }

    public func deleteToken(for url: URL) {
        transientToken = nil
        writeDBoAuthStore(token: nil)
    }
}
