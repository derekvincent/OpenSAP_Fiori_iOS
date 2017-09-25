//
//  ShoppingCartTableViewControllerCellTableViewCell.swift
//  shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPFiori

@IBDesignable
public class WorklistCell: NibDesignableTableViewCell {

    static let reuseCellIdentifier = "WorklistCell"

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityLabel: UILabel!

    var onQuantityChangedHandler: ((Int?, WorklistCell) -> Void)?

    // we need to track if we are in the middle of an deletion operation
    // so that we can suppress any ongoing quantity changes
    var deletionRequested = false

    // MARK: - Initializer
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        quantityTextField.delegate = self
    }

    // MARK: - NSCoding
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        quantityTextField.delegate = self
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        quantityTextField.delegate = self
        applyFioriStyle()
    }

    func applyFioriStyle() {
        headlineLabel.font = .preferredFioriFont(forTextStyle: .headline)
        statusLabel.font = .preferredFioriFont(forTextStyle: .headline)
        quantityTextField.font = .preferredFioriFont(forTextStyle: .body)
        quantityLabel.font = .preferredFont(forTextStyle: .caption2)

        headlineLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        statusLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        quantityTextField.textColor = .preferredFioriColor(forStyle: .primary1)
        quantityLabel.textColor = .preferredFioriColor(forStyle: .primary2)

        headlineText = ""
        statusText = ""
        quantityText = ""
        quantityLabel.text = "Quantity"
        detailImage = #imageLiteral(resourceName: "Placeholder")
    }

    public override func prepareForInterfaceBuilder() {
        headlineText = "Headline"
        statusText = "Status"
        quantityText = "1"
        quantityLabel.text = "Quantity"
        detailImage = #imageLiteral(resourceName: "Placeholder")

        super.prepareForInterfaceBuilder()
    }

    /// Detail image
    @IBInspectable
    public var detailImage: UIImage? {
        didSet {
            guard let detailImage = detailImage else {
                detailImageView.image = #imageLiteral(resourceName: "Placeholder")
                return
            }
            detailImageView.image = detailImage
        }
    }

    /// Headline text
    @IBInspectable
    public var headlineText = "" {
        didSet {
            headlineLabel.text = headlineText
        }
    }

    /// Status text
    @IBInspectable
    public var statusText = "" {
        didSet {
            statusLabel.text = statusText
        }
    }

    /// Quantity text
    @IBInspectable
    public var quantityText = "" {
        didSet {
            quantityTextField.text = quantityText
        }
    }
}

// MARK: - UITextFieldDelegate
extension WorklistCell: UITextFieldDelegate {

    /// Pressing the enter key should end the text field editing.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    /// If a value was entered we inform the changeHandler about
    /// the changed quantity and in which cell the value has been changed.
    public func textFieldDidEndEditing(_ textField: UITextField) {

        // if we are in the middle of a deletion operation we suppress
        // the quantity changes
        guard !deletionRequested else {
            return
        }

        if let changedHandler = onQuantityChangedHandler {

            if let text = textField.text,
                let quantitiy = Int(text) {

                changedHandler(quantitiy, self)
            }
        }

    }
}
