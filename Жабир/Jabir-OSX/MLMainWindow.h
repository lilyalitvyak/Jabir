//
//  MLMainWindow.h
//  Jabir
//
//  Created by Anurodh Pokharel on 6/28/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLContactsViewController.h"


@interface MLMainWindow : NSWindowController <NSUserNotificationCenterDelegate>

@property (nonatomic, strong) IBOutlet NSTextField *contactNameField;

@property (nonatomic, strong) IBOutlet NSSearchField *contactSearchField;

@property (nonatomic, weak)  MLContactsViewController *contactsViewController;
@property (nonatomic, weak)  MLChatViewController *chatViewController;

/**
 Allows  the window to know what contact is currently selected
 */
-(void) updateCurrentContact:(NSDictionary *) contact;

-(IBAction)showContactsTab:(id)sender;
-(IBAction)showActiveChatTab:(id)sender;

-(IBAction)showContactDetails:(id)sender;
-(IBAction)showAddContactSheet:(id)sender;


@end
