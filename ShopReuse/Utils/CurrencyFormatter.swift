//
//  CurrencyFormatter.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPOData

public class CurrencyFormatter {

    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()

    public static func string(forPrice price: Double, currencyCode: String) -> String {
        numberFormatter.currencyCode = currencyCode
        return numberFormatter.string(from: price as NSNumber) ?? String(price)
    }

    /// Simplified version of a formatter for currency
    ///
    /// - Parameters:
    ///   - price: price value
    ///   - currencyCode: three letter currency code
    /// - Returns: The formatted price including the currency symbol
    public static func string(forPrice price: BigDecimal, currencyCode: String) -> String {
        return string(forPrice: price.doubleValue(), currencyCode: currencyCode)
    }
}
