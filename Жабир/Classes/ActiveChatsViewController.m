//
//  ActiveChatsViewController.m
//  Jabir
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import "ActiveChatsViewController.h"
#import "DataLayer.h"
#import "MLContactCell.h"
#import "chatViewController.h"
#import "JabirAppDelegate.h"

@interface ActiveChatsViewController ()

@end

@implementation ActiveChatsViewController

#pragma mark view lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title=NSLocalizedString(@"Active Chats",@"");
    self.view.backgroundColor=[UIColor lightGrayColor];
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    _chatListTable=[[UITableView alloc] init];
    _chatListTable.delegate=self;
    _chatListTable.dataSource=self;
    
    self.view=_chatListTable;
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close All",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(closeAll)];
    self.navigationItem.rightBarButtonItem=rightButton;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(refreshDisplay) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplay) name:kJabirAccountStatusChanged object:nil];
    
    [_chatListTable registerNib:[UINib nibWithNibName:@"MLContactCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"ContactCell"];
    
    self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModeAllVisible;
    
}


-(void) refreshDisplay
{
    
    [[DataLayer sharedInstance] activeContactsWithCompletion:^(NSMutableArray *cleanActive) {
        [[MLXMPPManager sharedInstance] cleanArrayOfConnectedAccounts:cleanActive];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MLXMPPManager sharedInstance] cleanArrayOfConnectedAccounts:cleanActive];
            
            _contacts=cleanActive;
            [_chatListTable reloadData];
            JabirAppDelegate* appDelegate= (JabirAppDelegate*) [UIApplication sharedApplication].delegate;
            [appDelegate updateUnread];
        });
    }];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDisplay];
    [[MLXMPPManager sharedInstance] handleNewMessage:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) closeAll
{
    [[DataLayer sharedInstance] removeAllActiveBuddies];
    [self refreshDisplay];
}

-(void) presentChatWithRow:(NSDictionary *)row
{
    [self  performSegueWithIdentifier:@"showConversation" sender:row];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showConversation"])
    {
        UINavigationController *nav = segue.destinationViewController;
        chatViewController *chatVC = (chatViewController *)nav.topViewController;
        [chatVC setupWithContact:sender];
    }
    
}



#pragma mark tableview datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [_contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLContactCell* cell =[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if(!cell)
    {
        cell =[[MLContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    

    NSDictionary* row = [_contacts objectAtIndex:indexPath.row];
    
    NSString* fullName=[row objectForKey:@"full_name"];
    if([[fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0) {
        [cell showDisplayName:fullName];
    }
    else {
        [cell showDisplayName:[row objectForKey:@"buddy_name"]];
    }
    
    NSString *state= [[row objectForKey:@"state"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(![[row objectForKey:@"status"] isEqualToString:@"(null)"] && ![[row objectForKey:@"status"] isEqualToString:@""]) {
       [cell showStatusText:[row objectForKey:@"status"]];
    }
    else
    {
        [cell showStatusText:nil];
    }
    
    if(([state isEqualToString:@"away"]) ||
       ([state isEqualToString:@"dnd"])||
       ([state isEqualToString:@"xa"])
       )
    {
        cell.status=kStatusAway;
    }
    else if([state isEqualToString:@"offline"]) {
        cell.status=kStatusOffline;
    }
    else if([state isEqualToString:@"(null)"] || [state isEqualToString:@""]) {
        cell.status=kStatusOnline;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.accountNo=[[row objectForKey:@"account_id"] integerValue];
    cell.username=[row objectForKey:@"buddy_name"] ;
    
    //cell.count=[[row objectForKey:@"count"] integerValue];
    NSString* accountNo=[NSString stringWithFormat:@"%ld", (long)cell.accountNo];
    [[DataLayer sharedInstance] countUserUnreadMessages:cell.username forAccount:accountNo withCompletion:^(NSNumber *unread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.count=[unread integerValue];
        });
    }];
    
    [[MLImageManager sharedInstance] getIconForContact:[row objectForKey:@"buddy_name"] andAccount:accountNo withCompletion:^(UIImage *image) {
            cell.userImage.image=image;
    }];
    [cell setOrb];
    return cell;
}


#pragma mark tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Close";
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary* contact= [_contacts objectAtIndex:indexPath.row];
        
        [[DataLayer sharedInstance] removeActiveBuddy:[contact objectForKey:@"buddy_name"] forAccount:[contact objectForKey:@"account_id"]];
        [[DataLayer sharedInstance] activeContactsWithCompletion:^(NSMutableArray *cleanActive) {
            [[MLXMPPManager sharedInstance] cleanArrayOfConnectedAccounts:cleanActive];
            dispatch_async(dispatch_get_main_queue(), ^{
                _contacts=cleanActive;
                [_chatListTable deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }];
        
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
      
    // [[_contacts objectAtIndex:indexPath.row] setObject:[NSNumber numberWithInt:0] forKey:@"count"];
 
    [self presentChatWithRow:[_contacts objectAtIndex:indexPath.row] ];
    
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
        
        
        _lastSelectedUser=[_contacts objectAtIndex:indexPath.row];
//    }
    
    
}



@end
