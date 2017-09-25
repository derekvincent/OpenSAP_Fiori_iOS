//
//  SectionHeaderView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

@IBDesignable
public class SectionHeaderView: NibDesignable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: FUIButton!
    @IBOutlet weak var footerBorderView: UIView!

    var buttonTapAction: ((SectionHeaderView) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        applyFioriStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyFioriStyle()
    }

    func applyFioriStyle() {
        footerBorderView.backgroundColor = .clear
        titleLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        titleLabel.font = .preferredFioriFont(forTextStyle: .body)
        actionButton.tintColor = .preferredFioriColor(forStyle: .tintColorDark)
    }

    public override func prepareForInterfaceBuilder() {
        applyFioriStyle()

        titleText = "Section Header"

        super.prepareForInterfaceBuilder()
    }

    @IBAction func buttonTap(_ sender: FUIButton) {
        buttonTapAction?(self)
    }

    @IBInspectable
    public var titleText = "" {
        didSet {
            titleLabel.text = titleText
        }
    }

    @IBInspectable
    public var showButton = false {
        didSet {
            actionButton.isHidden = !showButton
        }
    }

    @IBInspectable
    public var buttonTitle = "" {
        didSet {
            actionButton.setTitle(buttonTitle, for: .normal)
        }
    }

    @IBInspectable
    public var showBorder = false {
        didSet {
            if showBorder {
                footerBorderView.backgroundColor = UIColor.init(white: 224.0 / 255.0, alpha: 1.0)
            } else {
                footerBorderView.backgroundColor = .clear
            }
        }
    }
}
