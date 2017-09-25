//
//  PropertyCell.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit
import SAPFiori

@IBDesignable
class PropertyCell: NibDesignableTableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    open static var reuseIdentifier: String {
        return "\(String(describing: self))"
    }

    var properties: [(String, String)]? {
        didSet {
            collectionView?.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    func setup() {
        let layout = FUIKeyValueFlowLayout()
        layout.numberOfColumns = 1
        layout.sectionInset = .zero
        collectionView.collectionViewLayout = layout

        collectionView.register(FUIKeyValueCollectionViewCell.self, forCellWithReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = .zero
    }

    override func prepareForInterfaceBuilder() {
        setup()

        super.prepareForInterfaceBuilder()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension PropertyCell: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = properties?.count {
            return count
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier, for: indexPath) as! FUIKeyValueCollectionViewCell

        if let property = properties?[indexPath.row] {
            cell.keyLabel.lineBreakMode = .byWordWrapping
            cell.keyLabel.numberOfLines = 2
            cell.keyName = property.0
            cell.value = property.1
        }
        return cell
    }
}
