//
//  DetailViewController.swift
//  Shop
//
//  Created by Derek Vincent on 2017-09-06.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPCommon
import SAPFiori
import SAPOData

class DetailViewController: UIViewController {

    let logger = Logger.shared(named: "DetailViewController")
    
    @IBOutlet var productView: ProductDetailView!
    
    var productID: String?
    
    fileprivate var product: Product? {
        didSet {
            productView.product = product
            navigationController?.title = product?.name
            productView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Load the product details including reviews and images
    func loadProductDetails() {
        
        if let productID = productID {
            
            // create a query for products matching the given id
            // (which will return only on product)
            var query = DataQuery().withKey(Product.key(id: productID))
            
            // include all associated images in the result
            query = query.expand(Product.images)
            
            // include associated reviews in the result and sort them by the helpfull count in 
            // descending order, 
            // then limit to 3 entries (= top 3 helpfull reviews) 
            query = query.expand(Product.reviews, withQuery: DataQuery().orderBy(Review.helpfulCount, .descending).top(3))
            
            let loadingIndicator = FUIModalLoadingIndicator.show(inView: view)
            Shop.shared.oDataService?.product(query: query) { products, error in
                
                loadingIndicator.dismiss()
                
                guard error == nil else {
                    self.logger.warn("Error while loading product details", error: error)
                    self.product = nil
                    return
                }
                
                self.product = products?.first
            }
        }
        NotificationCenter.default.post(name: Shop.shoppingCartDidUpdateNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        loadProductDetails()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController: ProductDetailViewDelegate {
    
    func didSelectAddToCart(_ button: FUIButton) {
        guard let product = product else {
            return
        }
        
        button.isEnabled = false
        
        Shop.shared.oDataService?.addProductToShoppingCart(productID: product.id) { shoppingCartItem, error in
            
            button.isEnabled = true
            
            guard error == nil else {
                self.logger.warn("Error adding product \(product.name) (\(product.id)) to shopping cart.", error: error)
                return
            }
            
            FUIToastMessage.show(message: "\(product.name) added to cart.", maxNumberOfLines: 2)
            NotificationCenter.default.post(name: Shop.shoppingCartDidUpdateNotification, object: nil)
        }       
    }
    
    func didSelectReview(_ review: Review) {
        
    }
    
    func didSelectShowAllReviews(_ button: FUIButton) {
        
    }
    
    func didSelectWriteReview(_ button: FUIButton) {
        
    }
}
