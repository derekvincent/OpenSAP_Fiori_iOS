//
//  RatingStars.swift
//  Shop Reuse
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit

@IBDesignable
class RatingStars: NibDesignable {

    @IBOutlet weak var starsTextLabel: UILabel!

    private var starFormatter = RatingStarFormatter()

    static let starBlack = "\u{2605}"
    static let starWhite = "\u{2606}"

    private var stars = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        starFormatter.minimumStarCount = 5
        applyFioriStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        starFormatter.minimumStarCount = 5
        applyFioriStyle()
    }

    func applyFioriStyle() {
        starsTextLabel.font = .preferredFioriFont(forTextStyle: .headline)

        starsTextLabel.textColor = .preferredFioriColor(forStyle: .primary1)
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()
        starFormatter.minimumStarCount = 5
        super.prepareForInterfaceBuilder()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFioriStyle()
    }

    @IBInspectable
    var fillToStars: Int = 5 {
        didSet {
            starFormatter.minimumStarCount = fillToStars
            stars = starFormatter.string(fromRating: numberOfStars)
            starsTextLabel.text = stars
        }
    }

    @IBInspectable
    public var numberOfStars: Int = 3 {
        didSet {
            stars = starFormatter.string(fromRating: numberOfStars)
            starsTextLabel.text = stars
        }
    }

    @IBInspectable
    public var colorOfStars: UIColor = .preferredFioriColor(forStyle: .primary1) {
        didSet {
            starsTextLabel.textColor = colorOfStars
        }
    }

}
