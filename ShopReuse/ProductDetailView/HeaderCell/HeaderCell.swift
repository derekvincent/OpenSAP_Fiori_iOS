//
//  HeaderCell.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

@IBDesignable
class HeaderCell: NibDesignableTableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingStars: RatingStars!
    @IBOutlet weak var ratingAmountLabel: UILabel!
    @IBOutlet weak var addToCartButton: FUIButton!

    open static var reuseIdentifier: String {
        return "\(String(describing: self))"
    }

    public var onButtonTouched: ((FUIButton) -> Void)?

    var product: Product? {
        didSet {
            if let product = product {
                productNameLabel.text = product.name
                productDescriptionLabel.text = product.description
                priceLabel.text = product.formattedPrice
                availabilityLabel.text = product.stockAvailability.itemText
                availabilityLabel.textColor = product.stockAvailability.color
                ratingStars.numberOfStars = Int(product.averageRating.doubleValue().rounded())
                ratingAmountLabel.text = "(\(product.ratingCount))"
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyFioriStyle()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        applyFioriStyle()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    func applyFioriStyle() {
        productNameLabel.font = .preferredFioriFont(forTextStyle: .title1)
        productDescriptionLabel.font = .preferredFioriFont(forTextStyle: .body)
        availabilityLabel.font = .preferredFioriFont(forTextStyle: .subheadline)
        priceLabel.font = UIFont.preferredFioriFont(forTextStyle: .title2).bold

        productNameLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        productDescriptionLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        availabilityLabel.textColor = .preferredFioriColor(forStyle: .primary2)
        priceLabel.textColor = .preferredFioriColor(forStyle: .primary2)

        addToCartButton.titleLabel?.text = "Add to Cart"

        addToCartButton.layer.cornerRadius = 4
        addToCartButton.clipsToBounds = true
        addToCartButton.setTitleColor(.preferredFioriColor(forStyle: .primary6), for: .normal)
        addToCartButton.backgroundColor = .preferredFioriColor(forStyle: .tintColorDark)
        addToCartButton.addTarget(self, action: #selector(addToShoppingCart), for: .touchUpInside)
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()

        productNameLabel.text = "Notebook Basic 17"
        productDescriptionLabel.text = "The notebook with a long lasting battery and a 17 inch LCD display."
        availabilityLabel.text = "In Stock"
        priceLabel.text = "$1249,00"
        ratingStars.numberOfStars = 3
        ratingAmountLabel.text = "(7)"

        super.prepareForInterfaceBuilder()
    }

    func addToShoppingCart() {
        if let onButtonTouched = self.onButtonTouched {
            onButtonTouched(addToCartButton)
        }
    }
}
