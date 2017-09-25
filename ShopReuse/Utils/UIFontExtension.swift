//
//  UIFontExtension.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit

extension UIFont {
    private func apply(_ traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits)) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return self
    }

    var bold: UIFont {
        return apply(.traitBold)
    }

    var italic: UIFont {
        return apply(.traitItalic)
    }

    var boldItalic: UIFont {
        return apply(.traitBold, .traitItalic)
    }

    var condensed: UIFont {
        return apply(.traitCondensed)
    }
}
