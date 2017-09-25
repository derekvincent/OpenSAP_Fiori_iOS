//
//  UserMenuButtonItem.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPFiori
import UIKit

public protocol UserMenuButtonItemDelegate: class {
    func didTapUserMenu()
}

@IBDesignable
public class UserMenuButtonItem: UIBarButtonItem {

    var userImageView = FUIImageView()
    public weak var presentingNavigationController: UINavigationController?

    public override var image: UIImage? {
        set(value) {
            userImageView.image = value
        }
        get {
            return userImageView.image
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        userImageView.isCircular = true
        image = UIImage(named: "UserProfile", in: Bundle(for: type(of: self)), compatibleWith: nil)
        userImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        customView = userImageView

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        customView?.addGestureRecognizer(tap)
    }

    public override func prepareForInterfaceBuilder() {
        userImageView.isCircular = true
        image = UIImage(named: "UserProfile", in: Bundle(for: type(of: self)), compatibleWith: nil)
        userImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        customView = userImageView

        super.prepareForInterfaceBuilder()
    }

    func didTapImageView() {

        let userMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: { _ in

        })

        let offboardingAction = UIAlertAction(title: "Change connection", style: .default, handler: { _ in

        })

        let changePasscodeAction = UIAlertAction(title: "Change passcode", style: .default, handler: { _ in

        })

        userMenuController.addAction(changePasscodeAction)
        userMenuController.addAction(offboardingAction)
        userMenuController.addAction(logOutAction)

        userMenuController.popoverPresentationController?.sourceView = customView

        let xPosition = customView!.frame.size.width / 2
        let yPosition = customView!.frame.size.height
        userMenuController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)

        presentingNavigationController?.present(userMenuController, animated: true)
    }
}
