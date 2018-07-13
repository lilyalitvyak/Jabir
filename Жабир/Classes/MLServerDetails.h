//
//  MLServerDetails.h
//  Jabir
//
//  Created by Anurodh Pokharel on 12/21/17.
//  Copyright © 2017 Jabir.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xmpp.h"

@interface MLServerDetails : UITableViewController

@property (nonatomic, weak) xmpp *xmppAccount;

@end
