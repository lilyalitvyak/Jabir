//
//  UIViewController+StoryboardLoading.swift
//  Jabir
//
//  Created by Vladimir Vaskin on 08.07.2018.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

import UIKit

@objc public extension UIViewController {
    public var barController: TabBarController {
        return TabBarController.shared
    }
    
    public static func presentAlert(title: String, message: String, options: [String], completion: ((Int) -> Void)?) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for (index, option) in options.enumerated() {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                    completion?(index)
                }))
            }
            DispatchQueue.main.async {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
