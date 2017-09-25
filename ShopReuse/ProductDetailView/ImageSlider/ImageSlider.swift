//
//  ImageSlider.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit

class ImageSlider: NibDesignable {

    @IBOutlet weak var imageScrollViewContainer: UIView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagePageControl: UIPageControl!

    fileprivate var imageViews = [UIImageView]()
    private var previousImage: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
        applyFioriStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
        applyFioriStyle()
    }

    private func initialize() {
        imageScrollView.delegate = self
        imagePageControl.numberOfPages = 0
        imagePageControl.currentPage = 0
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyFioriStyle()
    }

    func applyFioriStyle() {
        imagePageControl.pageIndicatorTintColor = .lightGray
        imagePageControl.currentPageIndicatorTintColor = .black
    }

    public override func prepareForInterfaceBuilder() {
        applyFioriStyle()

        super.prepareForInterfaceBuilder()
    }

    func add(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageScrollView.addSubview(imageView)

        imageView.widthAnchor.constraint(equalTo: imageScrollViewContainer.widthAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: imageScrollViewContainer.centerYAnchor).isActive = true
        if let previousImage = previousImage {
            imageView.leftAnchor.constraint(equalTo: previousImage.rightAnchor).isActive = true
        } else {
            imageView.leftAnchor.constraint(equalTo: imageScrollView.leftAnchor).isActive = true
        }

        imageViews.append(imageView)
        previousImage = imageView

        updateSize()
    }

    func updateSize() {
        imagePageControl.numberOfPages = imageViews.count

        let containerSize = imageScrollViewContainer.frame.size
        imageScrollView.contentSize = CGSize(width: CGFloat(imageViews.count) * containerSize.width, height: containerSize.height)
        imageScrollView.updateConstraints()
    }

    func clear() {
        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
        previousImage = nil
    }
}

// MARK: - UIScrollViewDelegate
extension ImageSlider: UIScrollViewDelegate {

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width > 0 else {
            return
        }
        let pageNumber: CGFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
        imagePageControl.currentPage = Int(roundf(Float(pageNumber)))

    }
}
