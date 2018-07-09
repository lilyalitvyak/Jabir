//
//  RoundedView.swift
//  Monal
//
//  Created by Vladimir Vaskin on 09.07.2018.
//  Copyright © 2018 Monal.im. All rights reserved.
//

import UIKit

@IBDesignable public class RoundedView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
}
