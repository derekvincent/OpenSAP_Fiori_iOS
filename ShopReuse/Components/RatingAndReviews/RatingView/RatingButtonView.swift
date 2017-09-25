//
//  RatingButtonView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

@IBDesignable
class RatingButtonView: NibDesignable {

    // swiftlint:disable identifier_name
    @IBOutlet weak var starButton_1: UIButton!
    @IBOutlet weak var starButton_2: UIButton!
    @IBOutlet weak var starButton_3: UIButton!
    @IBOutlet weak var starButton_4: UIButton!
    @IBOutlet weak var starButton_5: UIButton!
    // swiftlint:enable identifier_name

    var rating: Int = 1 {
        didSet {
            switch rating {
            case 1:
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)
            case 2:
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)
            case 3:
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)
            case 4:
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)
            case 5:
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starBlack, for: .normal)
            default:
                rating = 1
                starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
                starButton_2.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_3.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_4.setTitle(RatingStarFormatter.starWhite, for: .normal)
                starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()
        super.prepareForInterfaceBuilder()
    }

    func applyFioriStyle() {
        starButton_1.setTitle(RatingStarFormatter.starBlack, for: .normal)
        starButton_2.setTitle(RatingStarFormatter.starWhite, for: .normal)
        starButton_3.setTitle(RatingStarFormatter.starWhite, for: .normal)
        starButton_4.setTitle(RatingStarFormatter.starWhite, for: .normal)
        starButton_5.setTitle(RatingStarFormatter.starWhite, for: .normal)

        starButton_1.tintColor = .preferredFioriColor(forStyle: .tintColorDark)
        starButton_2.tintColor = .preferredFioriColor(forStyle: .tintColorDark)
        starButton_3.tintColor = .preferredFioriColor(forStyle: .tintColorDark)
        starButton_4.tintColor = .preferredFioriColor(forStyle: .tintColorDark)
        starButton_5.tintColor = .preferredFioriColor(forStyle: .tintColorDark)

        starButton_1.addTarget(self, action: #selector(RatingButtonView.didChangeRating), for: .touchUpInside)
        starButton_2.addTarget(self, action: #selector(RatingButtonView.didChangeRating), for: .touchUpInside)
        starButton_3.addTarget(self, action: #selector(RatingButtonView.didChangeRating), for: .touchUpInside)
        starButton_4.addTarget(self, action: #selector(RatingButtonView.didChangeRating), for: .touchUpInside)
        starButton_5.addTarget(self, action: #selector(RatingButtonView.didChangeRating), for: .touchUpInside)
    }

    func didChangeRating(_ sender: UIButton) {
        rating = sender.tag
    }
}
