//
//  Logger+Extensions.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon

extension Logger {
    private static let prefix = "com.sap.mobile.apps.toolkit.onboarding"

    static func shared(forClass classType: Any) -> Logger {
        let name = String(describing: classType)
        return Logger.shared(named: prefix.appending(".\(name)"))
    }
}
