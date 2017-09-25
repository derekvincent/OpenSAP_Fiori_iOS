//
//  WorklistFooterView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit

public class WorklistFooterView: NibDesignable {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var subTotalValueLabel: UILabel!
    @IBOutlet weak var subTotal2Label: UILabel!
    @IBOutlet weak var subTotal2ValueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    func applyFioriStyle() {
        subTotalLabel.font = .preferredFioriFont(forTextStyle: .caption2)
        subTotalValueLabel.font = .preferredFioriFont(forTextStyle: .caption2)
        subTotal2Label.font = .preferredFioriFont(forTextStyle: .caption2)
        subTotal2ValueLabel.font = .preferredFont(forTextStyle: .caption2)
        totalLabel.font = UIFont.preferredFioriFont(forTextStyle: .headline).bold
        totalValueLabel.font = UIFont.preferredFioriFont(forTextStyle: .headline).bold

        subTotalLabel.textColor = .preferredFioriColor(forStyle: .primary2)
        subTotalValueLabel.textColor = .preferredFioriColor(forStyle: .primary2)
        subTotal2Label.textColor = .preferredFioriColor(forStyle: .primary2)
        subTotal2ValueLabel.textColor = .preferredFioriColor(forStyle: .primary2)
        totalLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        totalValueLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        rootView.backgroundColor = .preferredFioriColor(forStyle: .backgroundBase)

        subTotalLabelText = ""
        subTotalValueText = ""
        subTotal2LabelText = ""
        subTotal2ValueText = ""
        totalLabelText = ""
        totalValueText = ""
    }

    public override func prepareForInterfaceBuilder() {
        subTotalLabelText = "Sub-total"
        subTotalValueText = "$1,318.99"
        subTotal2LabelText = "Tax"
        subTotal2ValueText = "$86.77"
        totalLabelText = "Total"
        totalValueText = "$1,405.76"

        super.prepareForInterfaceBuilder()
    }

    @IBInspectable
    public var subTotalLabelText = "" {
        didSet {
            subTotalLabel.text = subTotalLabelText
        }
    }

    @IBInspectable
    public var subTotalValueText = "" {
        didSet {
            subTotalValueLabel.text = subTotalValueText
        }
    }

    @IBInspectable
    public var subTotal2LabelText = "" {
        didSet {
            subTotal2Label.text = subTotal2LabelText
        }
    }

    @IBInspectable
    public var subTotal2ValueText = "" {
        didSet {
            subTotal2ValueLabel.text = subTotal2ValueText
        }
    }

    @IBInspectable
    public var totalLabelText = "" {
        didSet {
            totalLabel.text = totalLabelText
        }
    }

    @IBInspectable
    public var totalValueText = "" {
        didSet {
            totalValueLabel.text = totalValueText
        }
    }
}
