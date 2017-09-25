//
//  PasscodePolicyBlock.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon
import SAPFiori
import SAPFoundation

public class PasscodePolicyBlock: Block {

    fileprivate let logger = Logger.shared(forClass: PasscodePolicyBlock.self)

    fileprivate typealias CompletionHandlerType = (PasscodePolicyBlock.Output?, PasscodePolicyBlock.PasscodePolicyError?) -> Void

    public typealias InputConfigType = Input
    public typealias OutputConfigType = Output
    public typealias ErrorType = PasscodePolicyError

    public struct Input {

        var appId = ""
        var serverUrl: URL
        var sapUrlSession: SAPURLSession

        public init(appId: String, serverUrl: URL, sapUrlSession: SAPURLSession) {

            self.appId = appId
            self.serverUrl = serverUrl
            self.sapUrlSession = sapUrlSession
        }
    }

    public struct Output {

        public var passcodePolicy: FUIPasscodePolicy

        public init(passcodePolicy: FUIPasscodePolicy) {

            self.passcodePolicy = passcodePolicy
        }
    }

    public enum PasscodePolicyError: Error {
        case loadingFailed
    }

    public func process(input: PasscodePolicyBlock.Input, completion: @escaping (PasscodePolicyBlock.Output?, PasscodePolicyBlock.PasscodePolicyError?) -> Void) {

        var hostUrlComponents = URLComponents()
        hostUrlComponents.scheme = input.serverUrl.scheme
        hostUrlComponents.host = input.serverUrl.host

        let settingsParameters = SAPcpmsSettingsParameters(backendURL: hostUrlComponents.url!, applicationID: input.appId)
        let settings = SAPcpmsSettings(sapURLSession: input.sapUrlSession, settingsParameters: settingsParameters)

        settings.load { policy, error in
            if error != nil {
                completion(nil, .loadingFailed)
            } else {
                if let policy = policy {
                    let passcodePolicy = FUIPasscodePolicy(hcpmsConfiguration: policy)
                    OperationQueue.main.addOperation {
                        completion(Output(passcodePolicy: passcodePolicy!), nil)
                    }
                }
            }
        }
    }
}
