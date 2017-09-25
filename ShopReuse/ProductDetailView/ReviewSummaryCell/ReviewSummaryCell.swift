//
//  ReviewSummaryCell.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

protocol ReviewSummaryDelegate: class {
    func writeSummary(_ button: FUIButton)
}

@IBDesignable
class ReviewSummaryCell: NibDesignableTableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var averageRatingStars: RatingStars!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    @IBOutlet weak var writeReviewButton: FUIButton!

    @IBOutlet weak var fiveStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var fourStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var threeStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var twoStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var oneStarDetail: RatingStarsProgressAmount!

    weak var delegate: ReviewSummaryDelegate?

    open static var reuseIdentifier: String {
        return "\(String(describing: self))"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyFioriStyle()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        applyFioriStyle()
    }

    func applyFioriStyle() {
        averageRatingLabel.font = .preferredFioriFont(forTextStyle: .title2)
        numberOfRatingsLabel.font = .preferredFioriFont(forTextStyle: .subheadline)
        writeReviewButton.tintColor = .preferredFioriColor(forStyle: .tintColorDark)

        headerLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        averageRatingLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        numberOfRatingsLabel.textColor = .preferredFioriColor(forStyle: .primary3)
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()
        super.prepareForInterfaceBuilder()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFioriStyle()
    }

    public var numberOfRatings = RatingValues(five: 0, four: 0, three: 0, two: 0, one: 0) {
        didSet {

            let ratings = numberOfRatings.ratings

            var sumWeightedRatings = 0
            let countRatings = ratings.count
            let sumRatings = ratings.reduce(0) { sum, rating in sum + rating }
            let averageRating: Float

            for (index, rating) in ratings.enumerated() {
                // index 0 is 5 stars, index 1 is 4 stars ...
                let star = countRatings - index
                sumWeightedRatings += rating * star
            }

            let ratingPercentages = ratings.map {
                (Float($0)) / Float(sumRatings)
            }

            averageRating = sumRatings == 0 ? 0 : Float(sumWeightedRatings) / Float(sumRatings)

            averageRatingLabel.text = String(format: "%.1f", averageRating)

            averageRatingStars.numberOfStars = Int(averageRating.rounded())
            averageRatingStars.fillToStars = 5

            numberOfRatingsLabel.text = "(\(sumRatings))"

            fiveStarDetail.textAmount = String(describing: ratings[0])
            fiveStarDetail.progress = ratingPercentages[0]

            fourStarDetail.textAmount = String(describing: ratings[1])
            fourStarDetail.progress = ratingPercentages[1]

            threeStarDetail.textAmount = String(describing: ratings[2])
            threeStarDetail.progress = ratingPercentages[2]

            twoStarDetail.textAmount = String(describing: ratings[3])
            twoStarDetail.progress = ratingPercentages[3]

            oneStarDetail.textAmount = String(describing: ratings[4])
            oneStarDetail.progress = ratingPercentages[4]
        }
    }

    @IBAction func didTapOnWriteSummary(_ sender: FUIButton) {
        delegate?.writeSummary(sender)
    }
}
