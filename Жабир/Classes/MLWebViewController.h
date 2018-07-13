//
//  MLWebViewController.h
//  Jabir
//
//  Created by Anurodh Pokharel on 1/1/18.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface MLWebViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, strong)  WKWebView  *webview;
@property  (nonatomic, strong) NSURL *urltoLoad;
@end
