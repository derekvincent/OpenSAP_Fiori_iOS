//
//  WorklistView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

public class WorklistView: NibDesignable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: WorklistFooterView!
    @IBOutlet weak var emptyListLabel: UILabel!

    public var dataSource: WorklistViewDataSource?
    public var emptyListText = ""

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()

        tableView.register(WorklistCell.self, forCellReuseIdentifier: WorklistCell.reuseCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func applyFioriStyle() {
        emptyListLabel.font = .preferredFioriFont(forTextStyle: .headline)
        emptyListLabel.textColor = .preferredFioriColor(forStyle: .primary1)
        emptyListLabel.isHidden = true
    }

    public override func prepareForInterfaceBuilder() {
        dataSource = SampleDataSource()
        totalLabelText = "Subtotal"
        totalValueText = "$956.00"
        tableView.reloadData()

        super.prepareForInterfaceBuilder()
    }

    @IBInspectable
    public var totalLabelText = "" {
        didSet {
            footerView.totalLabelText = totalLabelText
        }
    }

    @IBInspectable
    public var totalValueText = "" {
        didSet {
            footerView.totalValueText = totalValueText
        }
    }

    public func reloadData() {
        tableView.reloadData()
    }

    private class SampleDataSource: WorklistViewDataSource {

        func numberOfRows(in worklistView: WorklistView) -> Int {
            return 1
        }

        func worklistView(_ worklistView: WorklistView, for cell: WorklistCell, atRow indexPath: IndexPath,
                          imageCompletionHandler: @escaping (UIImage?) -> Void) {

            cell.headlineText = "Notebook Basic 15"
            cell.statusText = "$956.00"
            cell.quantityText = "1"
            imageCompletionHandler(#imageLiteral(resourceName: "Placeholder"))
        }

        func worklistView(_ worklistView: WorklistView, deleteRowAt indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {

        }

        func worklistView(_ worklistView: WorklistView, didUpdateItemQuantity: Int, for cell: WorklistCell, atRow indexPath: IndexPath) {

        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WorklistView: UITableViewDelegate, UITableViewDataSource {

    /// Enable every cell to be editable.
    ///
    /// - Parameters:
    ///   - tableView
    ///   - indexPath
    /// - Returns: true if the cell is editable
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /// Event handler after the swipe-to-delete button is pressed.
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - editingStyle
    ///   - indexPath
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            // inform the cell that we are in the middle of a deletion operation
            let cell = tableView.cellForRow(at: indexPath) as! WorklistCell
            cell.deletionRequested = true

            // Delete the row from the data source
            dataSource?.worklistView(self, deleteRowAt: indexPath, completionHandler: { deleteRow in
                if deleteRow {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    // reset the delete button
                    tableView.setEditing(false, animated: true)
                }
            })
        }
    }

    /// Getting the number of rows in section.
    ///
    /// - Parameters:
    ///   - tableView
    ///   - section
    /// - Returns: number of rows in section
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = dataSource?.numberOfRows(in: self) ?? 0

        tableView.isHidden = numberOfRows == 0
        footerView.isHidden = numberOfRows == 0

        if numberOfRows == 0 && !emptyListText.isEmpty {
            emptyListLabel.text = emptyListText
            emptyListLabel.isHidden = false
        } else {
            emptyListLabel.isHidden = true
        }

        return numberOfRows
    }

    /// Getting the cell of the table view, attaching the onQuantityChangedHandler and
    /// handling the delayed loading of the image.
    ///
    /// - Parameters:
    ///   - tableView
    ///   - indexPath
    /// - Returns: UITableViewCell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: WorklistCell.reuseCellIdentifier, for: indexPath) as! WorklistCell

        cell.onQuantityChangedHandler = { quantity, cell in
            self.dataSource?.worklistView(self, didUpdateItemQuantity: quantity!, for: cell, atRow: indexPath)
        }

        dataSource?.worklistView(self, for: cell, atRow: indexPath) { image in
            if let delayedUpdatedCell = tableView.cellForRow(at: indexPath) as? WorklistCell {
                delayedUpdatedCell.detailImage = image
            }
        }

        return cell
    }
}
