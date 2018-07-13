//
//  AccountsViewController.h
//  Jabir
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import <UIKit/UIKit.h>


@interface AccountsViewController : UITableViewController
{
    NSArray* _accountList;
    NSArray* _protocolList; 
}


@property (nonatomic, strong) UITableView* accountsTable;

-(IBAction)connect:(id)sender;
-(IBAction)logout:(id)sender;

@end
