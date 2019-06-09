//
//  UIColor+Contrast.swift
//  Jabir
//
//  Created by Lilya Litvyak on 09.07.2018.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

import UIKit

@objc public extension UIColor {
    
    /// Relative luminance of a color according to W3's WCAG 2.0:
    /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
    
    /// Contrast ratio between two colors according to W3's WCAG 2.0:
    /// https://www.w3.org/TR/WCAG20/#contrast-ratiodef
    func contrastRatio(to otherColor: UIColor) -> CGFloat {
        let ourLuminance = self.luminance
        let theirLuminance = otherColor.luminance
        let lighterColor = min(ourLuminance, theirLuminance)
        let darkerColor = max(ourLuminance, theirLuminance)
        return 1 / ((lighterColor + 0.05) / (darkerColor + 0.05))
    }
    
    /// Determines whether the contrast between this `UIColor` and the provided
    /// `UIColor` is sufficient to meet the recommendations of W3's WCAG 2.0.
    ///
    /// The recommendation is that the contrast ratio between text and its
    /// background should be at least 4.5:1 for small text and at least
    /// 3.0:1 for larger text.
    func sufficientContrast(to otherColor: UIColor, withFont font: UIFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)) -> Bool {
        let pointSizeThreshold: CGFloat = 12.0
        let contrastRatioThreshold: CGFloat = font.fontDescriptor.pointSize < pointSizeThreshold ? 4.5 : 3.0
        return contrastRatio(to: otherColor) > contrastRatioThreshold
    }
}
