//
//  MLSettingsTableViewController.m
//  Jabir
//
//  Created by Anurodh Pokharel on 12/26/17.
//  Copyright © 2017 Jabir.im. All rights reserved.
//

#import "MLSettingsTableViewController.h"
#import "MLWebViewController.h"


NS_ENUM(NSInteger, kSettingSection)
{
    kSettingSectionApp=0,
    kSettingSectionSupport,
    kSettingSectionAbout,
    kSettingSectionCount
};

@interface MLSettingsTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *appRows;
@property (nonatomic, strong) NSArray *supportRows;
@property (nonatomic, strong) NSArray *aboutRows;

@end

@implementation MLSettingsTableViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sections =@[NSLocalizedString(@"App",@""),
                     NSLocalizedString(@"Support",@""),
                     NSLocalizedString(@"About",@"")];
    
    self.appRows=@[NSLocalizedString(@"Accounts", @""),
                   NSLocalizedString(@"Notifications", @""),
                   NSLocalizedString(@"Display", @""),
                   NSLocalizedString(@"Chat Logs", @"")];  //@"Cloud Storage"
    self.supportRows=@[NSLocalizedString(@"Email Support",@""),
                       NSLocalizedString(@"Submit A Bug",@"")];
#ifdef DEBUG
    self.aboutRows=@[NSLocalizedString(@"About",@""),
                     NSLocalizedString(@"Version",@""),
                     NSLocalizedString(@"Log",@"")];
#else
    self.aboutRows=@[NSLocalizedString(@"About",@""),
                     NSLocalizedString(@"Version",@"")];
#endif
    self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModeAllVisible;
    
    self.navigationItem.title=NSLocalizedString(@"Settings",@"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger toreturn=0;
    switch(section)
    {
        case kSettingSectionApp: {
           toreturn= self.appRows.count;
            break;
        }
        case kSettingSectionSupport: {
            toreturn=  self.supportRows.count;
            break;
        }
        case kSettingSectionAbout: {
            toreturn= self.aboutRows.count;
            break;
        }

    }
    
    return toreturn;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    switch(indexPath.section)
    {
        case kSettingSectionApp: {
            cell.textLabel.text= self.appRows[indexPath.row];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case kSettingSectionSupport: {
            cell.textLabel.text= self.supportRows[indexPath.row];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case kSettingSectionAbout: {
            if(indexPath.row==1)
            {
                NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
                NSString* build = [infoDict objectForKey:@"CFBundleVersion"];
                
                cell.textLabel.text= [NSString stringWithFormat:@"%@  %@ (%@)",self.aboutRows[indexPath.row], version, build];
                cell.accessoryType=UITableViewCellAccessoryNone;
            } else {
                cell.textLabel.text= self.aboutRows[indexPath.row];
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        }
            
    }
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *toreturn;
    if(section!=kSettingSectionApp) toreturn= self.sections[section];
    return toreturn;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(indexPath.section)
    {
        case kSettingSectionApp: {
           
            switch ((indexPath.row)) {
                case 0:
                    [self performSegueWithIdentifier:@"showAccounts" sender:self];
                    break;
                    
                case 1:
                    [self performSegueWithIdentifier:@"showNotification" sender:self];
                    break;
                    
                case 2:
                    [self performSegueWithIdentifier:@"showDisplay" sender:self];
                    break;
                    
                case 3:
                    [self performSegueWithIdentifier:@"showChatLog" sender:self];
                    break;
                    
                case 4:
                    [self performSegueWithIdentifier:@"showCloud" sender:self];
                    break;
                    
              
                    
                default:
                    break;
            }
            
            break;
        }
        case kSettingSectionSupport: {
            switch ((indexPath.row)) {
                case 0:
                    [self composeMail];
                    break;
                    
                case 1:
                    [self performSegueWithIdentifier:@"showBug" sender:self];
                    break;
                default:
                    break;
            }
            break;
        }
        case kSettingSectionAbout: {
            switch ((indexPath.row)) {
                case 0:
                    [self performSegueWithIdentifier:@"showAbout" sender:self];
                    break;
                    
                case 2:
                    [self performSegueWithIdentifier:@"showLogs" sender:self];
                    break;
               
                default:
                    break;
            }
            
            
            break;
        }
            
    }
}

#pragma mark - Actions


//- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier {
//    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
//
//    storeViewController.delegate = self;
//
//    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
//    //, @"action":@"write-review"
//    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier};
//
//    [storeViewController loadProductWithParameters:parameters
//                                   completionBlock:^(BOOL result, NSError *error) {
//                                       if (result)
//                                           [self presentViewController:storeViewController
//                                                              animated:YES
//                                                            completion:nil];
//                                       else NSLog(@"SKStoreProductViewController: %@", error);
//                                   }];
//
//
//}

-(void)composeMail
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        [composeVC setToRecipients:@[@"info@jabir.im"]];
        [self presentViewController:composeVC animated:YES completion:nil];
    }
    else  {
        UIAlertController *messageAlert =[UIAlertController alertControllerWithTitle:@"Error" message:@"There is no configured email account. Please email info@jabir.im ." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction =[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [messageAlert addAction:closeAction];
        
        [self presentViewController:messageAlert animated:YES completion:nil];
    }
    
}

#pragma mark - Message ui delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)  prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showBug"])
    {
        UINavigationController *nav = (UINavigationController *)  segue.destinationViewController;
        MLWebViewController *web = (MLWebViewController *) nav.topViewController;
        web.urltoLoad=[NSURL URLWithString:@"https://github.com/lilyalitvyak/Jabir/issues"];
    }
    else if([segue.identifier isEqualToString:@"showAbout"])
    {
        UINavigationController *nav = (UINavigationController *)  segue.destinationViewController;
        MLWebViewController *web = (MLWebViewController *) nav.topViewController;
        web.urltoLoad=[NSURL URLWithString:@"https://jabir.im/about/"];
    }
}


@end
