//
//  QRCodeConfigurationProvider.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFoundation

public class QRCodeConfigurationProvider: ConfigurationProviding {

    public static let ProviderName = "com.sap.mobile.apps.toolkit.onboarding.configuration.provider.qrcode"

    public var providerIdentifier: String {
        return QRCodeConfigurationProvider.ProviderName
    }

    public var expectedInput: [String: Any] {
        var dict = [String: Any]()
        dict[QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue] = Optional()
        return dict
    }

    public func resetStoredData() {}

    public func provideConfiguration(input: [String: Any]) -> (providerSuccess: Bool, configuration: NSDictionary, returnError: Error?) {
        let data: NSMutableDictionary = [:]

        // log.info("\(self.providerIdentifier).provideConfiguration: processing...");
        if let rawJson = input[QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue] as? String {
            data.setValue(rawJson, forKey: QRCodeConfigurationProviderInputKeys.qrcodeJson.rawValue)
            return (true, data, nil)
        } else {
            return (false, data, nil)
        }
    }
}

public struct QRCodeConfigurationProviderInputKeys: RawRepresentable {
    public typealias RawValue = String

    public let rawValue: RawValue
    public init?(rawValue: RawValue) { self.rawValue = rawValue }
    init(_ rawValue: RawValue) { self.rawValue = rawValue }

    public static let qrcodeJson = QRCodeConfigurationProviderInputKeys("rawJson")
}
