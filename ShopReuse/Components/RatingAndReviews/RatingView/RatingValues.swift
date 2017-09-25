//
//  RatingValues.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation

public struct RatingValues {
    var five = 0
    var four = 0
    var three = 0
    var two = 0
    var one = 0

    public var ratings: [Int]

    init(five: Int, four: Int, three: Int, two: Int, one: Int) {
        self.five = five
        self.four = four
        self.three = three
        self.two = two
        self.one = one

        // store them in an array for map/filter/reduce
        // begin with the biggest rating
        ratings = []
        ratings.append(five)
        ratings.append(four)
        ratings.append(three)
        ratings.append(two)
        ratings.append(one)
    }
}
