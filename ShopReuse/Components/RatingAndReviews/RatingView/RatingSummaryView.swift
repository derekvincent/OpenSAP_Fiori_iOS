//
//  RatingSummaryView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import SAPFiori
import UIKit

@IBDesignable
class RatingSummaryView: NibDesignable {

    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var averageRatingStars: RatingStars!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!

    @IBOutlet weak var fiveStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var fourStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var threeStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var twoStarDetail: RatingStarsProgressAmount!
    @IBOutlet weak var oneStarDetail: RatingStarsProgressAmount!

    override init(frame: CGRect) {
        numberOfRatings = RatingValues(five: 0, four: 0, three: 0, two: 0, one: 0)
        super.init(frame: frame)
        applyFioriStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        numberOfRatings = RatingValues(five: 0, four: 0, three: 0, two: 0, one: 0)
        super.init(coder: aDecoder)
        applyFioriStyle()
    }

    func applyFioriStyle() {
        averageRatingLabel.font = .preferredFioriFont(forTextStyle: .title2)
        numberOfRatingsLabel.font = .preferredFioriFont(forTextStyle: .headline)

        averageRatingLabel.textColor = .preferredFioriColor(forStyle: .primary3)
        numberOfRatingsLabel.textColor = .preferredFioriColor(forStyle: .primary3)
    }

    override func prepareForInterfaceBuilder() {
        applyFioriStyle()
        numberOfRatings = RatingValues(five: 10, four: 8, three: 6, two: 4, one: 2)
        super.prepareForInterfaceBuilder()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFioriStyle()
    }

    public var numberOfRatings: RatingValues {
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
}
