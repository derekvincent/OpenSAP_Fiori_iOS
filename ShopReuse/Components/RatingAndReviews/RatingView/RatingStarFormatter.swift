//
//  RatingStarFormatter.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

struct RatingStarFormatter {

    static let starBlack = "\u{2605}"
    static let starWhite = "\u{2606}"
    var minimumStarCount = 5

    func string(fromRating rating: Double) -> String {
        return string(fromRating: Int(rating.rounded()))
    }

    func string(fromRating rating: Int) -> String {

        var stars = ""
        if rating >= 1 {
            for _ in 1 ... rating {
                stars += RatingStarFormatter.starBlack
            }
        }

        let remaining = minimumStarCount - rating
        if remaining >= 1 {
            for _ in 1 ... remaining {
                stars += RatingStarFormatter.starWhite
            }
        }
        return stars
    }
}
