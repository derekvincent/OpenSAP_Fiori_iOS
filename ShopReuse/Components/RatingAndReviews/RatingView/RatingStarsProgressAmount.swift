//
//  RatingStars.swift
//  Shop Reuse
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit

@IBDesignable
class RatingStarsProgressAmount: NibDesignable {

    @IBOutlet weak var starsControl: RatingStars!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var amountTextLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultValues()
        applyFioriStyle()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultValues()
        applyFioriStyle()
    }

    func applyFioriStyle() {
        amountTextLabel.font = .preferredFioriFont(forTextStyle: .subheadline)

        starsControl.colorOfStars = .preferredFioriColor(forStyle: .primary3)
        amountTextLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        progressView.trackTintColor = .preferredFioriColor(forStyle: .primary4)
        progressView.progressTintColor = .preferredFioriColor(forStyle: .primary1)
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()
        defaultValues()
        super.prepareForInterfaceBuilder()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFioriStyle()
    }

    func defaultValues() {
        progressView.progress = 0.5
        amountTextLabel.text = "50"
        starsControl.fillToStars = 5
        starsControl.numberOfStars = 3
    }

    @IBInspectable
    public var fillToStars: Int = 5 {
        didSet {
            starsControl.fillToStars = fillToStars
        }
    }

    @IBInspectable
    public var numberOfStars: Int = 3 {
        didSet {
            starsControl.numberOfStars = numberOfStars
        }
    }

    @IBInspectable
    public var colorOfStars: UIColor = .preferredFioriColor(forStyle: .primary3) {
        didSet {
            starsControl.colorOfStars = colorOfStars
        }
    }

    @IBInspectable
    public var colorProgressBar: UIColor = .preferredFioriColor(forStyle: .primary1) {
        didSet {
            progressView.progressTintColor = colorProgressBar
        }
    }

    @IBInspectable
    public var colorProgressTrack: UIColor = .preferredFioriColor(forStyle: .primary4) {
        didSet {
            progressView.trackTintColor = colorProgressTrack
        }
    }

    @IBInspectable
    public var colorAmount: UIColor = .preferredFioriColor(forStyle: .primary3) {
        didSet {
            amountTextLabel.textColor = colorAmount
        }
    }

    @IBInspectable
    public var progress: Float = 0.5 {
        didSet {
            progressView.progress = progress
        }
    }

    @IBInspectable
    public var textAmount: String = "30" {
        didSet {
            amountTextLabel.text = textAmount
        }
    }
}
