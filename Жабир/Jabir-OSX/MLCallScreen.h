//
//  MLCallScreen.h
//  Jabir-OSX
//
//  Created by Anurodh Pokharel on 1/8/18.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLCallScreen : NSViewController

@property (nonatomic, strong) NSDictionary *contact;

@property (nonatomic, weak) IBOutlet NSTextField  *contactName;
@property (nonatomic, weak) IBOutlet NSButton  *callButton;

-(IBAction)hangup:(id)sender;

@end
