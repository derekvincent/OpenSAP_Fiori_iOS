//
//  RatingOverviewCell.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPFiori

@IBDesignable
public class RatingOverviewCell: NibDesignableTableViewCell {

    static let reuseCellIdentifier = "RatingOverviewCell"

    @IBOutlet weak var ratingStars: RatingStars!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var helpfulButton: FUIButton!

    var buttonTapAction: ((RatingOverviewCell) -> Void)?

    @IBAction func buttonTap(_ sender: FUIButton) {
        buttonTapAction?(self)
    }

    // MARK: - Initializer
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    // MARK: - NSCoding
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    func applyFioriStyle() {
        helpfulButton.setTitleColor(.preferredFioriColor(forStyle: .tintColorDark), for: .normal)

        helpfulButton.layer.cornerRadius = 5
        helpfulButton.clipsToBounds = true
        helpfulButton.layer.borderColor = UIColor.preferredFioriColor(forStyle: .tintColorDark).cgColor
        helpfulButton.layer.borderWidth = 1.0
    }

    public override func prepareForInterfaceBuilder() {

        super.prepareForInterfaceBuilder()
    }

    @IBInspectable
    public var infoText = "" {
        didSet {
            infoLabel.text = infoText
        }
    }

    @IBInspectable
    public var ratingText = "" {
        didSet {
            reviewTextView.text = ratingText
        }
    }

    @IBInspectable
    public var rating = 5 {
        didSet {
            ratingStars.numberOfStars = rating
        }
    }

    @IBInspectable
    public var buttonText = "" {
        didSet {
            helpfulButton.setTitle(buttonText, for: .normal)
        }
    }
}
