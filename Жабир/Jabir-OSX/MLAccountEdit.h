//
//  MLAccountEdit.h
//  Jabir
//
//  Created by Anurodh Pokharel on 8/3/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLAccountEdit : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *jabberID;
@property (nonatomic, weak) IBOutlet NSTextField *password;

@property (nonatomic, weak) IBOutlet NSButton *enabledCheck;

@property (nonatomic, weak) IBOutlet NSTextField *server;
@property (nonatomic, weak) IBOutlet NSTextField *port;

@property (nonatomic, weak) IBOutlet NSTextField *resource;

@property (nonatomic, weak) IBOutlet NSButton *sslCheck;
@property (nonatomic, weak) IBOutlet NSButton *oldStyleSSL;
@property (nonatomic, weak) IBOutlet NSButton *selfSigned;

@property (nonatomic, weak) IBOutlet NSButton *oAuthTokenButton;
@property (nonatomic, weak) IBOutlet NSBox *advancedBox;

@property (nonatomic, strong) NSString *accountType;

@property (nonatomic, strong) NSDictionary *accountToEdit;

-(IBAction)save:(id)sender;
-(IBAction)authenticateWithOAuth:(id)sender;


@end
