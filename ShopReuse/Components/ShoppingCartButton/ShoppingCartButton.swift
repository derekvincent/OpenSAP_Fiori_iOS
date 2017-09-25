//
//  ShoppingCartButton.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFiori
import SAPCommon
import SAPOData

@IBDesignable
public class ShoppingCartButton: UIButton {

    let logger = Logger.shared(named: "ShoppingCartButton")

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountLabel: UILabel!

    public var showLoadingAnimation = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ShoppingCartButton", bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        self.applyFioriStyle()
        addSubview(view)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ShoppingCartButton", bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView

        self.applyFioriStyle()
        addSubview(view)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        applyFioriStyle()
        amountView.isHidden = true
        addSubview(view)

        NotificationCenter.default.addObserver(self, selector: #selector(updateShoppingCartCounter), name: Shop.shoppingCartDidUpdateNotification, object: nil)
    }

    /// Don't forget to remove observer once the view controller goes away
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func applyFioriStyle() {
        amountLabel.textColor = UIColor.preferredFioriColor(forStyle: .tintColorDark)

        amountView.layer.cornerRadius = 7
        amountView.layer.masksToBounds = true

        itemCount = 0
    }

    public override func prepareForInterfaceBuilder() {
        frame.size = CGSize(width: 40, height: 35)
        iconView.frame.size = CGSize(width: 34, height: 26)

        super.prepareForInterfaceBuilder()
    }

    func updateShoppingCartCounter() {
        
        // use -1 to get the ShoppingCart of the current user and read the total quantity property
        let dataQuery = DataQuery().withKey(ShoppingCart.key(id: -1)).select(ShoppingCart.totalQuantity)
        
        Shop.shared.oDataService?.shoppingCart(query: dataQuery) { shoppingCarts, error in
            
            guard error == nil else {
                self.logger.warn("Error while loading shopping cart item count.", error: error)
                self.itemCount = 0
                return
            }
            
            let shoppingCart = shoppingCarts?.first
            let totalQuantity = shoppingCart?.totalQuantity ?? 0
            self.itemCount = totalQuantity
        }
    }

    /// Text of Add to cart button
    @IBInspectable
    public var itemCount: Int = 0 {
        didSet {
            OperationQueue.main.addOperation {
                if self.itemCount <= 0 {
                    self.amountView.isHidden = true
                    self.amountLabel.text = ""
                } else {
                    self.amountView.isHidden = false
                    self.amountLabel.text = String(self.itemCount)
                    self.amountLabel.adjustsFontSizeToFitWidth = true
                }
            }
        }
    }
}
