//
//  ReviewViewController.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori
import SAPOData

class ReviewViewController: UIViewController {

    @IBOutlet weak var reviewPropertiesCollectionView: UICollectionView!

    var review: Review?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        reviewPropertiesCollectionView.reloadData()
    }

    func setup() {
        // let layout = FUIKeyValueFlowLayout()
        let layout = FUICollectionViewLayout.autosizingColumnFlow
        layout.numberOfColumns = 1
        layout.minimumLineSpacing = 24
        reviewPropertiesCollectionView.collectionViewLayout = layout

        reviewPropertiesCollectionView.register(FUIKeyValueCollectionViewCell.self, forCellWithReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier)
        reviewPropertiesCollectionView.dataSource = self
        reviewPropertiesCollectionView.delegate = self
        reviewPropertiesCollectionView.contentInset = .zero
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension ReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier, for: indexPath) as! FUIKeyValueCollectionViewCell

        if let review = review {
            switch indexPath.row {
            case 0:
                cell.keyName = "Rating"
                cell.value = RatingStarFormatter().string(fromRating: review.rating.intValue())
            case 1:
                cell.keyName = "Date"
                cell.value = ODataDateFormatter.format(string: review.changedAt.toString())
            case 2:
                cell.keyName = "Reviewer"
                cell.value = review.userDisplayName
            case 3:
                cell.keyName = "Review was marked as helpful"
                cell.value = review.helpfulCount == 1 ? "\(review.helpfulCount) time" : "\(review.helpfulCount) times"
            case 4:
                cell.keyName = "Details"
                cell.value = review.comment
            default:
                break
            }
        }
        return cell
    }
}
