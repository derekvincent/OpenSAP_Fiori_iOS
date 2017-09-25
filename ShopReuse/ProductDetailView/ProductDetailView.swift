//
//  ProductDetailView.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFiori
import SAPOData

enum CellType: Int {
    case headerCell = 0
    case propertyCellInfo
    case propertyCellDimension
    case reviewSummary
    case reviewCell

    static let count = 5
}

protocol ProductDetailViewDelegate: class {
    func didSelectAddToCart(_ button: FUIButton)
    func didSelectReview(_ review: Review)
    func didSelectWriteReview(_ button: FUIButton)
    func didSelectShowAllReviews(_ button: FUIButton)
}

@IBDesignable
public class ProductDetailView: NibDesignable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageSlider: ImageSlider!
    @IBOutlet weak var detailTableView: UITableView!

    weak var delegate: ProductDetailViewDelegate?

    var product: Product? {
        didSet {
            updateValues()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public override func awakeFromNib() {
        setup()
        super.awakeFromNib()
    }

    func setup() {
        detailTableView.separatorStyle = .none
        detailTableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseIdentifier)
        detailTableView.register(ReviewSummaryCell.self, forCellReuseIdentifier: ReviewSummaryCell.reuseIdentifier)
        detailTableView.register(PropertyCell.self, forCellReuseIdentifier: PropertyCell.reuseIdentifier)
        detailTableView.register(HeaderCell.self, forCellReuseIdentifier: HeaderCell.reuseIdentifier)
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.estimatedRowHeight = 200
        detailTableView.tableFooterView = UIView()

        imageSlider.clear()
    }

    public override func prepareForInterfaceBuilder() {
        setup()
        let data = SampleDataSource()
        product = data.product

        imageSlider.add(image: UIImage(named: "Prod1", in: Bundle(for: type(of: self)), compatibleWith: nil)!)
        imageSlider.add(image: UIImage(named: "Prod2", in: Bundle(for: type(of: self)), compatibleWith: nil)!)
        imageSlider.add(image: UIImage(named: "Prod3", in: Bundle(for: type(of: self)), compatibleWith: nil)!)

        super.prepareForInterfaceBuilder()
    }

    func updateValues() {
        if let product = product {
            detailTableView.separatorStyle = .singleLine
            detailTableView.reloadData()
            imageSlider.clear()

            // add images asynchronously as they are loaded
            for imageEntity in product.images {
                product.loadImage(for: imageEntity) { image, error in
                    if error == nil, let image = image {
                        self.imageSlider.add(image: image)
                    }
                }
            }
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass != .compact {
            detailTableView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        } else {
            detailTableView.isScrollEnabled = true
            scrollView.isScrollEnabled = false
        }
    }

    private class SampleDataSource {

        var product: Product?
        init() {
            product = Product()
            product?.name = "Notebook Basic 17"
            product?.id = "HT-1001"
            product?.averageRating = BigDecimal(4)
            product?.ratingCount = 78
            product?.stockQuantity = 8
            product?.description = "Business Notebook"
            product?.dimensionUnit = "mm"
            product?.dimensionDepth = BigDecimal(200)
            product?.dimensionWidth = BigDecimal(300)
            product?.dimensionHeight = BigDecimal(20)
            product?.weightUnit = "KG"
            product?.weightMeasure = BigDecimal(2)
            product?.supplierName = "Akron"
            product?.mainCategoryName = "Computer"
            product?.subCategoryName = "Portable devices"
            product?.price = BigDecimal(1999)
            product?.currencyCode = "USD"
            product?.hasReviewOfCurrentUser = true
            product?.reviewCount1 = 2
            product?.reviewCount2 = 3
            product?.reviewCount3 = 4
            product?.reviewCount4 = 5
            product?.reviewCount5 = 6

            let review = Review()
            review.changedAt = GlobalDateTime.now()
            review.comment = "Very good device"
            review.userDisplayName = "John Doe"
            review.rating = BigInteger(3)
            review.isReviewOfCurrentUser = true
            review.helpfulForCurrentUser = true
            review.helpfulCount = 5
            product?.reviews.append(review)

            let review2 = Review()
            review2.changedAt = GlobalDateTime.now()
            review2.comment = "Lightweight and usable"
            review2.userDisplayName = "Jane Doe"
            review2.rating = BigInteger(4)
            product?.reviews.append(review2)
        }
    }
}

// MARK: - ReviewSummaryDelegate
extension ProductDetailView: ReviewSummaryDelegate {
    func writeSummary(_ button: FUIButton) {
        delegate?.didSelectWriteReview(button)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ProductDetailView: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return CellType.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let product = product {

            if let cellType = CellType(rawValue: section),
                cellType == CellType.reviewCell {
                return min(product.reviews.count, 3)
            } else {
                return 1
            }
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellType = CellType(rawValue: indexPath.section)!

        switch cellType {

        case .headerCell:

            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.reuseIdentifier, for: indexPath) as! HeaderCell
            cell.product = product
            cell.onButtonTouched = { button in
                self.delegate?.didSelectAddToCart(button)
            }

            return cell

        case .propertyCellInfo:

            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyCell.reuseIdentifier, for: indexPath) as! PropertyCell

            if let product = product {
                if indexPath.section == 1 {
                    let properties = [
                        ("Product ID", product.id),
                        ("Category", product.mainCategoryName),
                        ("Sub-category", product.subCategoryName)
                    ]
                    cell.properties = properties
                }
            }
            return cell

        case .propertyCellDimension:

            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyCell.reuseIdentifier, for: indexPath) as! PropertyCell

            if let product = product {

                let dimensions = String.init(format: "%.02f x %.02f x %.02f %@", product.dimensionHeight.floatValue(), product.dimensionWidth.floatValue(), product.dimensionDepth.floatValue(), product.dimensionUnit)
                let weight = String.init(format: "%.02f %@", product.weightMeasure.floatValue(), product.weightUnit)
                let properties = [
                    ("Product Dimensions (H x W x D)", dimensions),
                    ("Weight", weight),
                    ("Supplier", product.supplierName)
                ]
                cell.properties = properties
            }

            return cell

        case .reviewSummary:

            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewSummaryCell.reuseIdentifier, for: indexPath) as! ReviewSummaryCell

            if let product = product {

                if product.hasReviewOfCurrentUser {
                    cell.writeReviewButton.setTitle("Edit Review", for: .normal)
                }

                cell.delegate = self
                cell.numberOfRatings = RatingValues(five: product.reviewCount5,
                                                    four: product.reviewCount4,
                                                    three: product.reviewCount3,
                                                    two: product.reviewCount2,
                                                    one: product.reviewCount1)
            }

            return cell

        case .reviewCell:

            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseIdentifier, for: indexPath) as! ReviewCell
            if let product = product {
                let reviewItem = product.reviews[indexPath.row]
                cell.authorText = "by \(reviewItem.userDisplayName)"
                cell.createdOnText = ODataDateFormatter.format(string: reviewItem.changedAt.toString())
                cell.reviewDescriptionText = reviewItem.comment
                cell.rating = Int(reviewItem.rating.doubleValue().rounded())
            }

            return cell
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let cellType = CellType(rawValue: indexPath.section)!

        switch cellType {
        case .headerCell:
            return 283
        case .propertyCellInfo, .propertyCellDimension :
            return 59 * 3
        default:
            return UITableViewAutomaticDimension
        }
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let cellType = CellType(rawValue: section) {
            if cellType == .reviewCell {
                return 38
            }
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cellType = CellType(rawValue: section) {
            if cellType == .reviewCell {
                let view = SectionHeaderView(frame: CGRect.zero)
                view.titleText = "Most Helpful Reviews"
                view.buttonTitle = "See All"
                view.showButton = true
                view.showBorder = true

                view.buttonTapAction = { view in
                    self.delegate?.didSelectShowAllReviews(view.actionButton)
                }

                return view
            }
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = CellType(rawValue: indexPath.section)!
        if cellType == .reviewCell {
            if let product = product {
                let reviewItem = product.reviews[indexPath.row]
                delegate?.didSelectReview(reviewItem)
            }
        }
    }
}
