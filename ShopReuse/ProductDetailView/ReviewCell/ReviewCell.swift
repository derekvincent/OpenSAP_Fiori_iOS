//
//  ReviewCell.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit

@IBDesignable
public class ReviewCell: NibDesignableTableViewCell {

    @IBOutlet weak var ratingStars: RatingStars!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var reviewDescriptionLabel: UILabel!

    open static var reuseIdentifier: String {
        return "\(String(describing: self))"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        applyFioriStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyFioriStyle()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    func applyFioriStyle() {
        createdOnLabel.font = .preferredFioriFont(forTextStyle: .headline)
        authorLabel.font = .preferredFioriFont(forTextStyle: .callout)
        reviewDescriptionLabel.font = .preferredFont(forTextStyle: .subheadline)

        createdOnLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        authorLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        reviewDescriptionLabel.textColor = .preferredFioriColor(forStyle: .primary3)

        createdOnText = ""
        authorText = ""
        reviewDescriptionText = ""
        ratingStars.numberOfStars = 0
    }

    public override func prepareForInterfaceBuilder() {
        applyFioriStyle()

        createdOnText = "Dec. 1, 2016"
        authorText = "John Doe"
        reviewDescriptionText = "I bought this to use with my laptop. It looks like it was designed with"
        rating = 3

        super.prepareForInterfaceBuilder()
    }

    /// Text of Add to cart button
    @IBInspectable
    public var createdOnText = "" {
        didSet {
            createdOnLabel.text = createdOnText
        }
    }

    /// Text of Add to cart button
    @IBInspectable
    public var authorText = "" {
        didSet {
            authorLabel.text = authorText
        }
    }

    /// Text of Add to cart button
    @IBInspectable
    public var reviewDescriptionText = "" {
        didSet {
            reviewDescriptionLabel.text = reviewDescriptionText
        }
    }

    /// Text of Add to cart button
    @IBInspectable
    public var rating: Int = 0 {
        didSet {
            ratingStars.numberOfStars = rating
        }
    }
}
