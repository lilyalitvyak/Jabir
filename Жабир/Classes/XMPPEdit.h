//
//  buddylist.h
//  SworIM
//
//  Created by Anurodh Pokharel on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataLayer.h"
#import "SAMKeychain.h"
#import "MLXMPPManager.h"


@interface XMPPEdit: UITableViewController <UITextFieldDelegate> {
	CGRect oldFrame;
	IBOutlet UILabel *JIDLabel;
}

extern NSString *const kGtalk;

@property (nonatomic, strong) DataLayer *db;
@property (nonatomic, strong ) 	NSArray *sectionArray;

@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) NSString *accountno;
@property (nonatomic, strong) NSIndexPath *originIndex;
@property (nonatomic, strong) NSString *accountType;

-(IBAction) delClicked: (id) sender;
-(void)authenticateWithOAuth;
-(IBAction) save:(id) sender;


@end


