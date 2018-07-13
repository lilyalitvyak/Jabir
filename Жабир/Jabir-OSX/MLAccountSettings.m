//
//  MLAccountSettings.m
//  Jabir
//
//  Created by Anurodh Pokharel on 7/29/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import "MLAccountSettings.h"
#import "MLAccountRow.h"
#import "MLAccountEdit.h"
#import "DataLayer.h"
#import "MLConstants.h"
#import "NXOAuth2AccountStore.h"
#import "SAMKeychain.h"

@interface MLAccountSettings ()
@property (nonatomic, strong) NSArray *accountList;

@end

@implementation MLAccountSettings

- (void)viewDidLoad {
    [super viewDidLoad];
    
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     [nc addObserver:self selector:@selector(refreshAccountList) name:kJabirAccountStatusChanged object:nil];
    
}

-(void) dealloc
{
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void) viewWillAppear
{
    [self refreshAccountList];
    [self.accountTable setDoubleAction:@selector(editAccount)];
}

-(void) refreshAccountList
{
    [[DataLayer sharedInstance] accountListWithCompletion:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.accountList=result;
            [self.accountTable reloadData];
        });
        
    }];
}

-(IBAction)deleteAccount:(id)sender
{
    //get selected.
    
    NSInteger selected = [self.accountTable selectedRow];
    if(selected < self.accountList.count) {
        NSDictionary * row = [self.accountList objectAtIndex:selected];
        
        NSString *jid = [row objectForKey:kAccountName];
        
        NSArray *accounts= [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:jid];
        NXOAuth2AccountStore *store= [NXOAuth2AccountStore sharedStore] ;
        for(NXOAuth2Account *oauthAccount in accounts ) {
            [store removeAccount:oauthAccount];
        }
        
        // pass to database
        NSNumber *accountID = [row objectForKey:kAccountID];
        [[DataLayer sharedInstance] removeAccount:[NSString stringWithFormat:@"%@", accountID]];
        
        [SAMKeychain deletePasswordForService:@"Jabir"  account:[NSString stringWithFormat:@"%@", accountID]];

        NSMutableArray *mutableAccounts = [self.accountList mutableCopy];
        [mutableAccounts removeObjectAtIndex:selected];
        self.accountList= mutableAccounts;
        
        // update display
        [self.accountTable reloadData];
    }
}


-(void)editAccount
{
    NSInteger selected = [self.accountTable selectedRow];
    if(selected < self.accountList.count) {
        NSDictionary * row = [self.accountList objectAtIndex:selected];
        
      [self performSegueWithIdentifier:@"showAccountEdit" sender:row];
    }
}

#pragma mark - segues

-(IBAction)showXMPP:(id)sender {
    [self performSegueWithIdentifier:@"showAccountEdit" sender:@"XMPP"];
}

-(IBAction)showGtalk:(id)sender {
     [self performSegueWithIdentifier:@"showAccountEdit" sender:@"Gtalk"];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    MLAccountEdit *sheet = (MLAccountEdit *)[segue destinationController];
    if([sender isKindOfClass:[NSString class]]) {
        sheet.accountType= sender;
    }
    else  {
        sheet.accountToEdit=sender;
    }
}


#pragma mark  - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return self.accountList.count;
}


#pragma  mark - tableview delegate
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row;
{
    MLAccountRow *tableRow = [tableView makeViewWithIdentifier:@"AccountRow" owner:nil];
    
    NSDictionary *account = [self.accountList objectAtIndex:row];
    [tableRow updateWithAccountDictionary:account];
    
    return tableRow;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    
}

#pragma mark - preferences delegate

- (NSString *)identifier
{
    return self.title;
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"1049-at-sign"];
}

- (NSString *)toolbarItemLabel
{
    return @"Accounts";
}


@end
