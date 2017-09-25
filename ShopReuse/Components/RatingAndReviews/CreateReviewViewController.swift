//
//  CreateReviewViewController.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPCommon
import SAPFiori
import SAPOData

protocol CreateReviewViewControllerDelegate: class {
    func createReviewViewController(_ viewController: CreateReviewViewController, review: Review, update: Bool)
}

public class CreateReviewViewController: UIViewController {

    weak var delegate: CreateReviewViewControllerDelegate?

    let logger = Logger.shared(named: "CreateReviewViewController")

    @IBOutlet weak var ratingButtonView: RatingButtonView!
    @IBOutlet weak var ratingComment: UITextView!

    var product: Product?
    var review: Review? {
        didSet {
            if let review = review {
                ratingButtonView.rating = review.rating.intValue()
                ratingComment.text = review.comment
                ratingComment.textColor = .black
            }
        }
    }

    let placeholderText = "Write your review here"

    /// Default rating is 5 when opening the review popup.
    /// Setup the text view properties.
    public override func viewDidLoad() {

        super.viewDidLoad()

        ratingButtonView.rating = 5

        ratingComment.delegate = self

        ratingComment.layer.borderWidth = 1
        ratingComment.layer.cornerRadius = 5
        ratingComment.layer.borderColor = UIColor.preferredFioriColor(forStyle: .line).cgColor
    }

    /// If there is an existing review for the user,
    /// initalize the rating stars and the rating comment.
    ///
    /// - Parameter animated
    public override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        if let review = review {
            ratingButtonView.rating = review.rating.intValue()
            ratingComment.text = review.comment
        } else {
            ratingComment.textColor = .preferredFioriColor(forStyle: .line)

            // manually set a placeholder text to the view
            // the UITextView does not support a placeholder text
            ratingComment.text = placeholderText
        }
    }

    /// Close the review popup.
    ///
    /// - Parameter sender
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    /// Create a popup showing the error localized description.
    ///
    /// - Parameter error
    func showPopup(error: Error) {

        let optionMenu = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)

        optionMenu.addAction(cancelAction)
        present(optionMenu, animated: true)
    }

    /// Change an existing review or create a new review.
    ///
    /// - Parameter sender
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {

        // when we have an existing review we update it's values
        if let review = review {

            review.rating = BigInteger(ratingButtonView.rating)

            if let comment = ratingComment.text {

                // don't save the placeholder text
                guard comment != placeholderText else {
                    return
                }
                review.comment = comment
            }

            Shop.shared.oDataService?.updateEntity(review) { error in

                guard error == nil else {
                    self.logger.error("Error updating review")
                    self.showPopup(error: error!)
                    return
                }

                FUIToastMessage.show(message: "Review updated")

                self.dismiss(animated: true)
                self.delegate?.createReviewViewController(self, review: review, update: true)
            }

            // when we don't have an existing review we create a new one
        } else {

            // we need the product ID for creating a new review
            if let product = product {

                let newReview = Review()
                newReview.isReviewOfCurrentUser = true
                newReview.productID = product.id
                newReview.rating = BigInteger(ratingButtonView.rating)
                newReview.createIfNonExistent = true

                if let comment = ratingComment.text {

                    newReview.comment = comment

                    // don't save the placeholder text
                    guard comment != placeholderText else {
                        return
                    }
                }

                Shop.shared.oDataService?.createEntity(newReview) { error in

                    guard error == nil else {
                        self.logger.error("Error creating new review")
                        self.showPopup(error: error!)
                        return
                    }

                    FUIToastMessage.show(message: "Review created")

                    self.dismiss(animated: true)
                    self.delegate?.createReviewViewController(self, review: newReview, update: false)
                }
            }

        }
    }
}

// MARK: - UITextViewDelegate
extension CreateReviewViewController: UITextViewDelegate {

    /// Manually remove the placeholder text when we begin editing.
    /// The UITextView does not support placeholder text.
    public func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }

    /// Manually set the placeholder text when we end editing.
    /// The UITextView does not support a placeholder text.
    public func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {
            textView.text = placeholderText
            textView.textColor = .preferredFioriColor(forStyle: .line)
        }
        textView.resignFirstResponder()
    }
}
