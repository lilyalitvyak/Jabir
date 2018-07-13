//
//  MLAddContact.h
//  Jabir
//
//  Created by Anurodh Pokharel on 11/18/15.
//  Copyright © 2015 Jabir.im. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLAddContact : NSViewController

@property  (nonatomic, weak) IBOutlet NSComboBox *accounts;
@property  (nonatomic, weak) IBOutlet NSTextField *contactName;

-(IBAction)add:(id)sender;

@end
