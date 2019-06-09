//
//  UIViewController+Topmost.m
//  Жабир
//
//  Created by Lilya Litvyak on 11.07.2018.
//  Copyright © 2018 ipse.im. All rights reserved.
//

#import "UIViewController+Topmost.h"

@implementation UIViewController (Topmost)

+ (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
