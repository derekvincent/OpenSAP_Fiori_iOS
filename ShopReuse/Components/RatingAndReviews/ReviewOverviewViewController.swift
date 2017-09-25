//
//  ReviewOverviewTableViewController.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit

import SAPCommon
import SAPFoundation
import SAPFiori
import SAPOData

class ReviewOverviewViewController: UITableViewController {

    private var reviews: [Review]?
    var productID: String?

    let logger = Logger.shared(named: "ReviewOverviewViewController")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 182
        tableView.rowHeight = UITableViewAutomaticDimension

        // hide extra separator lines at end of table
        tableView.tableFooterView = UIView()

        loadAllReviews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tableView.separatorStyle = .none
    }

    /// Load a bare product header plus all related reviews.
    func loadAllReviews() {

        // load all reviews for product and sort it by creation date (newest first)
        if let productID = productID {

            // create a query for products matching the given id
            // (which will return only this one product and its reviews relation)
            let query = DataQuery().filter(Review.productID.equal(productID)).orderBy(Review.changedAt, .descending)

            let loadingIndicator = FUIModalLoadingIndicator.show(inView: view)
            Shop.shared.oDataService?.review(query: query) { reviews, error in

                loadingIndicator.dismiss()

                guard error == nil else {
                    self.logger.warn("Error while loading all reviews for product \(productID)", error: error)
                    self.reviews = nil
                    return
                }

                self.reviews = reviews
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        }
    }

    /// Load the product details including reviews.
    func reloadReview(_ review: Review, atRow indexPath: IndexPath) {

        // create a query for reviews matching the given id
        // (which will return only one review)
        let query = DataQuery().withKey(Review.key(id: review.id))

        let loadingIndicator = FUIModalLoadingIndicator.show(inView: view)

        Shop.shared.oDataService?.review(query: query) { reviews, error in

            loadingIndicator.dismiss()

            guard error == nil else {
                self.logger.warn("Error while reloading review \(review.id)", error: error)
                return
            }

            // update the review in the array and reload the table cell
            if let review = reviews?.first {
                self.reviews?[indexPath.row] = review
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: RatingOverviewCell.reuseCellIdentifier, for: indexPath) as! RatingOverviewCell

        if let review = reviews?[indexPath.row] {

            let reviewDate = ODataDateFormatter.format(string: review.changedAt.toString())
            let byUser = "by \(review.userDisplayName)"
            cell.infoText = "\(reviewDate) \(byUser)"

            cell.ratingText = review.comment
            cell.rating = review.rating.intValue()

            var buttonText = review.helpfulForCurrentUser ? "Rated as Helpful" : "Rate as Helpful"
            buttonText += " (\(review.helpfulCount))"
            cell.buttonText = buttonText

            cell.buttonTapAction = { cell in
                self.changeHelpful(review: review, atRow: indexPath)
            }
        }

        return cell
    }

    /// Toggle the current review as helpful for the current user.
    ///
    /// - Parameter review
    func changeHelpful(review: Review, atRow indexPath: IndexPath) {

        // toggle helpful
        review.helpfulForCurrentUser = !review.helpfulForCurrentUser

        let loadingIndicator = FUIModalLoadingIndicator.show(inView: view)

        Shop.shared.oDataService?.updateEntity(review) { error in

            loadingIndicator.dismiss()

            guard error == nil else {

                self.logger.error("Error updating review property: HelpfulForCurrentUser")

                let optionMenu = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel)

                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true)

                return
            }

            // reload the specific review from the server (helpfulCount and helpfulForCurrentUser were updated)
            self.reloadReview(review, atRow: indexPath)
        }
    }
}
