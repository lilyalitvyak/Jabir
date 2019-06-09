//
//  chat.m
//  SworIM
//
//  Created by Anurodh Pokharel on 1/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "chatViewController.h"
#import "MLChatCell.h"
#import "MLChatImageCell.h"
#import "ChatSectionHeaderCell.h"
#import "RoomRosterViewController.h"

#import "MLConstants.h"
#import "JabirAppDelegate.h"
#import "MBProgressHUD.h"
#import "UIActionSheet+Blocks.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

#import "MWPhotoBrowser.h"
#import "UIImage+ColorMask.h"

@import QuartzCore;
@import MobileCoreServices;

static const int ddLogLevel = DDLogLevelVerbose;

@interface chatViewController() <MWPhotoBrowserDelegate>

@property (nonatomic, strong)  NSDateFormatter* destinationDateFormat;
@property (nonatomic, strong)  NSDateFormatter* sourceDateFormat;
@property (nonatomic, strong)  NSCalendar *gregorian;
@property (nonatomic, assign)  NSInteger thisyear;
@property (nonatomic, assign)  NSInteger thismonth;
@property (nonatomic, assign)  NSInteger thisday;
@property (nonatomic, strong)  MBProgressHUD *uploadHUD;
@property (nonatomic, assign, readonly) int wheelCounter;

@property (nonatomic, strong) NSMutableArray* messagesDateList;
@property (nonatomic, strong) NSMutableArray* photos;
@property (nonatomic, strong) NSMutableDictionary* nameColorHash;

@property (nonatomic, strong) DBTeamClient *restClient;

@property (nonatomic, assign) BOOL usingExternalKeybaord;

@property (nonatomic, assign) BOOL manualScrolled;
@property (nonatomic, assign) BOOL scrolledToBottom;

/**
 if set to yes will prevent scrolling and resizing. useful for resigning first responder just to set auto correct
 */
@property (nonatomic, assign) BOOL blockAnimations;

@end

@implementation chatViewController

@synthesize wheelCounter = _wheelCounter;

-(void) setup
{
    _contactName=[_contact objectForKey:@"buddy_name"];
    if(!_contactName)
    {
        _contactName=[_contact objectForKey:@"message_from"];
    }
    _contactFullName=[[DataLayer sharedInstance] fullName:_contactName forAccount:[NSString stringWithFormat:@"%@",[_contact objectForKey:@"account_id"]]];
    if (!_contactFullName) _contactFullName=_contactName;
    
    self.accountNo=[NSString stringWithFormat:@"%ld",[[_contact objectForKey:@"account_id"] integerValue]];
    self.hidesBottomBarWhenPushed=YES;
    
    NSArray* accountVals =[[DataLayer sharedInstance] accountVals:self.accountNo];
    if([accountVals count]>0)
    {
        self.jid=[NSString stringWithFormat:@"%@@%@",[[accountVals objectAtIndex:0] objectForKey:@"username"], [[accountVals objectAtIndex:0] objectForKey:@"domain"]];
    }
}

-(void) setupWithContact:(NSDictionary*) contact
{
    _contact=contact;
    [self setup];
    
}

- (void)makeTitleWithName:(NSString*)name {
    CGFloat width = self.view.frame.size.width - 60;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = _isMUC ? 2 : 1;
    label.font = [UIFont boldSystemFontOfSize: _isMUC ? 14.0f : 16.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _isMUC ? [NSString stringWithFormat:@"Конференция\n%@", name] : name;
    
    self.navigationItem.titleView = label;
}

#pragma mark view lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setupDateObjects];
    containerView= self.view;
    //self.messageTable.scrollsToTop=YES;
    self.chatInput.scrollsToTop=NO;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNewMessage:) name:kJabirNewMessageNotice object:nil];
    [nc addObserver:self selector:@selector(handleSendFailedMessage:) name:kJabirSendFailedMessageNotice object:nil];
    [nc addObserver:self selector:@selector(handleSentMessage:) name:kJabirSentMessageNotice object:nil];
    
    [nc addObserver:self selector:@selector(dismissKeyboard:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc addObserver:self selector:@selector(handleForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    [nc addObserver:self selector:@selector(handleBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    [nc addObserver:self selector:@selector(refreshMessage:) name:kJabirMessageReceivedNotice object:nil];
    
    
    [nc addObserver:self selector:@selector(refreshButton:) name:kJabirAccountStatusChanged object:nil];
    
    
    self.hidesBottomBarWhenPushed=YES;
    
    self.chatInput.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.chatInput.layer.cornerRadius=3.0f;
    self.chatInput.layer.borderWidth=0.5f;
    self.chatInput.textContainerInset=UIEdgeInsetsMake(5, 0, 5, 0);
    
    
    self.inputContainerView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.inputContainerView.layer.borderWidth=0.5f;
    
    //    if ([DBSession sharedSession].isLinked) {
    //        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    //        self.restClient.delegate = self;
    //    }
    
    self.messageTable.rowHeight = UITableViewAutomaticDimension;
    self.messageTable.estimatedRowHeight=75.0f;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//
//        browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
//        browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
//        browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
//        browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
//        browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
//        browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
//        browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
//
//        UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:browser];
//
//
//        [self presentViewController:nav animated:YES completion:nil];
//
//    });
}

-(void) handleForeGround {
    [self refreshData];
}


-(void) handleBackground {
    [self refreshCounter];
}



-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [MLNotificationManager sharedInstance].currentAccountNo=self.accountNo;
    [MLNotificationManager sharedInstance].currentContact=self.contactName;
    
    [self.barController setTabBarWithHidden:YES animated:YES along:nil];
    
    self.manualScrolled = NO;
    
    if(![_contactFullName isEqualToString:@"(null)"] && [[_contactFullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0)
    {
        [self makeTitleWithName:_contactFullName];
    }
    else {
        [self makeTitleWithName:_contactName];
    }
    
    if(self.day) {
        NSString *oldTitle = @"";
        if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
            UILabel *titleLabel = (UILabel*)self.navigationItem.titleView;
            oldTitle = titleLabel.text;
        }
        
        self.navigationItem.title=  [NSString stringWithFormat:@"%@(%@)", oldTitle, _day];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.inputContainerView.hidden=YES;
    }
    else {
        self.inputContainerView.hidden=NO;
    }
    
    [self handleForeGround];
    
    xmpp* xmppAccount = [[MLXMPPManager sharedInstance] getConnectedAccountForID:self.accountNo];
    if(xmppAccount.supportsMam0) {
        
        if(self.messagesDateList.count==0)
        {
            //fetch default
            NSDate *yesterday =[NSDate dateWithTimeInterval:-86400 sinceDate:[NSDate date]];
            [xmppAccount setMAMQueryFromStart: yesterday toDate:[NSDate date] andJid:self.contactName];
        }
        
    }
    
    [self refreshButton:nil];
    
    //    UIEdgeInsets currentInset = self.messageTable.contentInset;
    //    self.messageTable.contentInset =UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, currentInset.left, currentInset.bottom, currentInset.right);
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshCounter];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MLNotificationManager sharedInstance].currentAccountNo=nil;
    [MLNotificationManager sharedInstance].currentContact=nil;
    
    [self.barController setTabBarWithHidden:NO animated:YES along:nil];
    
    [self refreshCounter];
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark rotation


-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.chatInput resignFirstResponder];
}


#pragma mark gestures

-(IBAction)dismissKeyboard:(id)sender
{
    [self.chatInput resignFirstResponder];
}

#pragma mark message signals

-(void) refreshCounter
{
    if(!_day) {
        [[DataLayer sharedInstance] markAsReadBuddy:self.contactName forAccount:self.accountNo];
        
        JabirAppDelegate* appDelegate= (JabirAppDelegate*) [UIApplication sharedApplication].delegate;
        [appDelegate updateUnread];
    }
    
}

-(void) refreshData
{
    NSArray *messagesList;
    
    if(!_day) {
        messagesList =[[DataLayer sharedInstance] messageHistory:_contactName forAccount: _accountNo];
        [[DataLayer sharedInstance] countUserUnreadMessages:_contactName forAccount: _accountNo withCompletion:^(NSNumber *unread) {
            if([unread integerValue]==0) self->_firstmsg=YES;
            
        }];
        _isMUC=[[DataLayer sharedInstance] isBuddyMuc:_contactName forAccount: _accountNo];
    }
    else
    {
        messagesList =[[[DataLayer sharedInstance] messageHistoryDate:_contactName forAccount: _accountNo forDate:_day] mutableCopy];
    }
    
    self.roomRosterButtonItem.title = _isMUC ? nil : @"   ";
    self.roomRosterButtonItem.image = _isMUC ? [UIImage imageNamed:@"chat-roster"] : nil;
    self.roomRosterButtonItem.enabled = _isMUC;
    
    self.messagesDateList = [self groupByDate:messagesList];
    [_messageTable reloadData];
    
    if (self.messagesDateList.count > 0) {
        [self scrollToBottom:NO];
    }
}

- (NSMutableArray*)groupByDate:(NSArray*)messages {
    NSMutableArray *result = [NSMutableArray new];
    NSString *saveddate = @"";
    NSMutableArray *dayMessages;
    for (NSDictionary *msg in messages) {
        NSString *date = [self formattedDateWithSource:[msg objectForKey:@"thetime"]];
        if (![date isEqualToString:saveddate]) {
            if ([dayMessages count]) {
                [result addObject:[dayMessages mutableCopy]];
            }
            dayMessages = [NSMutableArray new];
            saveddate = date;
        }
        [dayMessages addObject:msg];
    }
    if ([dayMessages count]) {
        [result addObject:[dayMessages mutableCopy]];
    }
    
    return result;
}

#pragma mark textview
-(void) sendMessage:(NSString *) messageText
{
    [self sendMessage:messageText andMessageID:nil];
}

-(void) sendMessage:(NSString *) messageText andMessageID:(NSString *)messageID
{
    DDLogVerbose(@"Sending message");
    NSString *newMessageID =[[NSUUID UUID] UUIDString];
    
    [[MLXMPPManager sharedInstance] sendMessage:messageText toContact:_contactName fromAccount:_accountNo isMUC:_isMUC messageId:newMessageID
                          withCompletionHandler:nil];
    
    //dont readd it, use the exisitng
    if(!messageID) {
        [self addMessageto:_contactName withMessage:messageText andId:newMessageID];
    }
}

-(void)resignTextView
{
    NSString *cleanstring = [self.chatInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(cleanstring.length>0)
    {
        self.blockAnimations=YES;
        if(self.chatInput.isFirstResponder) {
            [self.chatInput resignFirstResponder];//apply autocorrect
            [self.chatInput becomeFirstResponder];
        }
        self.blockAnimations=NO;
        
        [self sendMessage:cleanstring];
        
        [self.chatInput setText:@""];
        [self scrollToBottom];
    }
}

-(IBAction)sendMessageText:(id)sender
{
    [self resignTextView];
    [self updateInputViewSize];
    
}

#pragma mark - Dropbox upload and delegate

//- (void) uploadImageToDropBox:(NSData *) imageData {
//
//    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[NSUUID UUID].UUIDString];
//    NSString *tempDir = NSTemporaryDirectory();
//    NSString *imagePath = [tempDir stringByAppendingPathComponent:fileName];
//    [imageData writeToFile:imagePath atomically:YES];
//
//    [self.restClient uploadFile:fileName toPath:@"/" withParentRev:nil fromPath:imagePath];
//}
//
//- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
//              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
//    DDLogVerbose(@"File uploaded successfully to dropbox path: %@", metadata.path);
//    [self.restClient loadSharableLinkForFile:metadata.path];
//}
//
//- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
//    DDLogVerbose(@"File upload to dropbox failed with error: %@", error);
//}
//
//- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
//           forFile:(NSString*)destPath from:(NSString*)srcPat
//{
//    self.uploadHUD.progress=progress;
//}
//
//- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link
//           forFile:(NSString*)path{
//    self.chatInput.text= link;
//    self.uploadHUD.hidden=YES;
//    self.uploadHUD=nil;
//}
//
//- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error{
//    self.uploadHUD.hidden=YES;
//    self.uploadHUD=nil;
//    DDLogVerbose(@"Failed to get Dropbox link with error: %@", error);
//}

#pragma mark - image picker

-(IBAction)attach:(id)sender
{
    [self.chatInput resignFirstResponder];
    xmpp* account=[[MLXMPPManager sharedInstance] getConnectedAccountForID:self.accountNo];
    if(!account.supportsHTTPUpload && !self.restClient)
    {
        [UIViewController presentAlertWithTitle:@"Error" message:@"This server does not appear to support HTTP file uploads (XEP-0363). Please ask the administrator to enable it. You can also link to DropBox in settings and use that to share files." options:@[@"Close"] completion:nil];
        
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate =self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Image Source" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void) uploadData:(NSData *) data
{
    if(!self.uploadHUD) {
        self.uploadHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.uploadHUD.removeFromSuperViewOnHide=YES;
        self.uploadHUD.label.text =@"Uploding";
        self.uploadHUD.detailsLabel.text =@"Upoading file to server";
    }
    
    //if you have configured it, defer to dropbox
    //    if(self.restClient)
    //    {
    //        self.uploadHUD.mode=MBProgressHUDModeDeterminate;
    //        self.uploadHUD.progress=0;
    //        [self uploadImageToDropBox:data];
    //    }
    //    else  {
    [[MLXMPPManager sharedInstance]  httpUploadJpegData:data toContact:self.contactName onAccount:self.accountNo withCompletionHandler:^(NSString *url, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadHUD.hidden=YES;
            
            if(url) {
                self.chatInput.text= url;
            }
            else  {
                [UIViewController presentAlertWithTitle:@"There was an error uploading the file to the server" message:[NSString stringWithFormat:@"%@", error.localizedDescription] options:@[@"Close"] completion:nil];
            }
        });
        
    }];
    //    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,
                                                                                               id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *selectedImage= info[UIImagePickerControllerEditedImage];
        if(!selectedImage) selectedImage= info[UIImagePickerControllerOriginalImage];
        NSData *jpgData=  UIImageJPEGRepresentation(selectedImage, 0.5f);
        if(jpgData)
        {
            [self uploadData:jpgData];
        }
        
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - handling notfications

-(void) reloadTable
{
    [_messageTable reloadData];
}

//always messages going out
-(void) addMessageto:(NSString*)to withMessage:(NSString*) message andId:(NSString *) messageId
{
    if(!self.jid || !message)  {
        DDLogError(@" not ready to send messages");
        return;
    }
    
    [[DataLayer sharedInstance] addMessageHistoryFrom:self.jid to:to forAccount:_accountNo withMessage:message actuallyFrom:self.jid withId:messageId withCompletion:^(BOOL result, NSString *messageType) {
        DDLogVerbose(@"added message");
        
        if(result) {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               NSDictionary* userInfo = @{@"af": self.jid,
                                                          @"message": message ,
                                                          @"thetime": [self currentGMTTime],
                                                          @"delivered":@YES,
                                                          @"messageid": messageId,
                                                          kMessageType:messageType
                                                          };
                               
                               NSMutableArray *lastDayMessages = [self.messagesDateList lastObject];
                               NSString *lastDate = [self formattedDateWithSource:[[lastDayMessages firstObject] objectForKey:@"thetime"]];
                               NSString *msgDate = [self formattedDateWithSource:[userInfo objectForKey:@"thetime"]];
                               if ([lastDate isEqualToString:msgDate]) {
                                   [lastDayMessages addObject:[userInfo mutableCopy]];
                               } else {
                                   [self.messagesDateList addObject:[[NSMutableArray alloc] initWithArray:@[[userInfo mutableCopy]]]];
                               }
                               
                               NSIndexPath *path1;
                               [self->_messageTable beginUpdates];
                               NSInteger bottom = [(NSMutableArray*)[self.messagesDateList lastObject] count]-1;
                               NSInteger section = [self.messagesDateList count]-1;
                               if(bottom>=0) {
                                   path1 = [NSIndexPath indexPathForRow:bottom  inSection:section];
                                   NSLog(@"xlog--------> SECTION %ld PATH %@", (long)section, path1);
                                   [self->_messageTable insertRowsAtIndexPaths:@[path1]
                                                              withRowAnimation:UITableViewRowAnimationBottom];
                               }
                               [self->_messageTable endUpdates];
                               
                               [self scrollToBottom];
                               
                           });
            
        }
        else {
            DDLogVerbose(@"failed to add message");
        }
    }];
    
    // make sure its in active
    if(_firstmsg==YES)
    {
        [[DataLayer sharedInstance] addActiveBuddies:to forAccount:_accountNo withCompletion:nil];
        _firstmsg=NO;
    }
    
}

-(void) refreshButton:(NSNotification *) notificaiton
{
    xmpp* xmppAccount = [[MLXMPPManager sharedInstance] getConnectedAccountForID:self.accountNo];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title=self->_contactName;
        if(![self->_contactFullName isEqualToString:@"(null)"] && [[self->_contactFullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0)
        {
            title=self->_contactFullName;
        }
        
        if(xmppAccount.accountState<kStateLoggedIn)
        {
            self.sendButton.enabled=NO;
            [self makeTitleWithName:[NSString stringWithFormat:@"%@ [%@]", title, @"Logged Out"]];
        }
        else  {
            self.sendButton.enabled=YES;
            [self makeTitleWithName:title];
            
        }
    });
}

-(void) handleNewMessage:(NSNotification *)notification
{
    DDLogVerbose(@"chat view got new message notice %@", notification.userInfo);
    
    if([[notification.userInfo objectForKey:@"accountNo"] isEqualToString:_accountNo]
       &&( ( [[notification.userInfo objectForKey:@"from"] isEqualToString:_contactName]) || ([[notification.userInfo objectForKey:@"to"] isEqualToString:_contactName] ))
       )
    {
        [[DataLayer sharedInstance] messageTypeForMessage: [notification.userInfo objectForKey:@"messageText"] withCompletion:^(NSString *messageType) {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               NSString *finalMessageType=messageType;
                               NSDictionary* userInfo;
                               if([[notification.userInfo objectForKey:kMessageType] isEqualToString:kMessageTypeStatus])
                               {
                                   finalMessageType =kMessageTypeStatus;
                               }
                               
                               
                               
                               if([[notification.userInfo objectForKey:@"to"] isEqualToString:self->_contactName])
                               {
                                   userInfo = @{@"af": [notification.userInfo objectForKey:@"actuallyfrom"],
                                                @"message": [notification.userInfo objectForKey:@"messageText"],
                                                @"thetime": [self currentGMTTime],   @"delivered":@YES,
                                                kMessageType:finalMessageType
                                                };
                                   
                               } else  {
                                   userInfo = @{@"af": [notification.userInfo objectForKey:@"actuallyfrom"],
                                                @"message": [notification.userInfo objectForKey:@"messageText"],
                                                @"thetime": [self currentGMTTime], kMessageType:finalMessageType
                                                };
                               }
                               
                               
                               NSMutableArray *lastDayMessages = [self.messagesDateList lastObject];
                               NSString *lastDate = [self formattedDateWithSource:[[lastDayMessages firstObject] objectForKey:@"thetime"]];
                               NSString *msgDate = [self formattedDateWithSource:[userInfo objectForKey:@"thetime"]];
                               if ([lastDate isEqualToString:msgDate]) {
                                   [lastDayMessages addObject:[userInfo mutableCopy]];
                               } else {
                                   [self.messagesDateList addObject:[[NSMutableArray alloc] initWithArray:@[[userInfo mutableCopy]]]];
                               }
                               
                               [self->_messageTable beginUpdates];
                               NSIndexPath *path1;
                               NSInteger row = [(NSMutableArray*)[self.messagesDateList lastObject] count]-1;
                               NSInteger section = [self.messagesDateList count]-1;
                               path1 = [NSIndexPath indexPathForRow:row  inSection:section];
                               [self->_messageTable insertRowsAtIndexPaths:@[path1]
                                                          withRowAnimation:UITableViewRowAnimationBottom];
                               
                               [self->_messageTable endUpdates];
                               
                               [self scrollToBottom];
                               
                               //mark as read
                               // [[DataLayer sharedInstance] markAsReadBuddy:_contactName forAccount:_accountNo];
                           });
            
        }];
        
    }
}

-(void) setMessageId:(NSString *) messageId delivered:(BOOL) delivered
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self->_messageTable beginUpdates];
                       
                       for (int section = 0; section < [self.messagesDateList count]; section++) {
                           NSArray *messagesList = [self.messagesDateList objectAtIndex:section];
                           int row=0;
                           for(NSMutableDictionary *rowDic in messagesList)
                           {
                               if([[rowDic objectForKey:@"messageid"] isEqualToString:messageId]) {
                                   [rowDic setObject:[NSNumber numberWithBool:delivered] forKey:@"delivered"];
                                   NSIndexPath *indexPath =[NSIndexPath indexPathForRow:row inSection:section];
                                   [self->_messageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                   break;
                               }
                               row++;
                           }
                       }
                       
                       [self->_messageTable endUpdates];
                   });
}

-(void) setMessageId:(NSString *) messageId received:(BOOL) received
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self->_messageTable beginUpdates];
                       
                       for (int section = 0; section < [self.messagesDateList count]; section++) {
                           NSArray *messagesList = [self.messagesDateList objectAtIndex:section];
                           int row=0;
                           for(NSMutableDictionary *rowDic in messagesList)
                           {
                               if([[rowDic objectForKey:@"messageid"] isEqualToString:messageId]) {
                                   [rowDic setObject:[NSNumber numberWithBool:received] forKey:@"received"];
                                   NSIndexPath *indexPath =[NSIndexPath indexPathForRow:row inSection:section];
                                   [self->_messageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                   break;
                               }
                               row++;
                           }
                       }
                       
                       [self->_messageTable endUpdates];
                   });
}


-(void) handleSendFailedMessage:(NSNotification *)notification
{
    NSDictionary *dic =notification.userInfo;
    [self setMessageId:[dic objectForKey:kMessageId]  delivered:NO];
}

-(void) handleSentMessage:(NSNotification *)notification
{
    NSDictionary *dic =notification.userInfo;
    [self setMessageId:[dic objectForKey:kMessageId]  delivered:YES];
}


-(void) refreshMessage:(NSNotification *)notification
{
    NSDictionary *dic =notification.userInfo;
    [self setMessageId:[dic objectForKey:kMessageId]  received:YES];
}


#pragma mark MUC display elements

-(void)scrollToBottom:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.messageTable.numberOfSections) {
            NSInteger lastSectionIndex = self.messageTable.numberOfSections-1;
            NSInteger bottom = [self.messageTable numberOfRowsInSection:lastSectionIndex];
            if(bottom>0)
            {
                NSIndexPath *path1 = [NSIndexPath indexPathForRow:bottom-1  inSection:lastSectionIndex];
                if(!self.manualScrolled)
                {
                    [self.messageTable scrollToRowAtIndexPath:path1 atScrollPosition:UITableViewScrollPositionTop animated:animated];
                }
            }
        }
    });
}

-(void)scrollToBottom
{
    [self scrollToBottom:[(NSMutableArray*)[self.messagesDateList lastObject] count] < 3];
}

#pragma mark date time

-(void) setupDateObjects
{
    self.destinationDateFormat = [[NSDateFormatter alloc] init];
    [self.destinationDateFormat setLocale:[NSLocale currentLocale]];
    [self.destinationDateFormat setDoesRelativeDateFormatting:YES];
    
    self.sourceDateFormat = [[NSDateFormatter alloc] init];
    [self.sourceDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.gregorian = [[NSCalendar alloc]
                      initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate* now =[NSDate date];
    self.thisday =[self.gregorian components:NSCalendarUnitDay fromDate:now].day;
    self.thismonth =[self.gregorian components:NSCalendarUnitMonth fromDate:now].month;
    self.thisyear =[self.gregorian components:NSCalendarUnitYear fromDate:now].year;
    
    self.nameColorHash = [[NSMutableDictionary alloc] init];
    self.manualScrolled = NO;
}

-(int)wheelCounter {
    if (_wheelCounter < 1 || _wheelCounter > 5) {
        _wheelCounter = 1;
    } else {
        _wheelCounter++;
    }
    
    return _wheelCounter;
}

-(NSString*) currentGMTTime
{
    NSDate* sourceDate =[NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone systemTimeZone];
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    return [self.sourceDateFormat stringFromDate:destinationDate];
}

- (NSString*)formattedDateWithSource:(NSString*) sourceDateString
{
    NSString* dateString;
    
    if(sourceDateString!=nil)
    {
        
        NSDate* sourceDate=[self.sourceDateFormat dateFromString:sourceDateString];
        
        dateString = [tools dateFromDate:sourceDate];
    }
    
    return dateString;
}

- (NSString*)formattedDateTimeWithSource:(NSString*) sourceDateString
{
    NSString* dateString;
    
    if(sourceDateString!=nil)
    {
        NSDate* sourceDate=[self.sourceDateFormat dateFromString:sourceDateString];
        dateString = [tools timeFromDate:sourceDate];
    }
    
    return dateString;
}



-(void) retry:(id) sender
{
    NSInteger historyId = ((UIButton*) sender).tag;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Retry sending message?" message:@"It is possible this message may have failed to send." preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *messageArray =[[DataLayer sharedInstance] messageForHistoryID:historyId];
        if([messageArray count]>0) {
            NSDictionary *dic= [messageArray objectAtIndex:0];
            [self sendMessage:[dic objectForKey:@"message"] andMessageID:[dic objectForKey:@"messageid"]];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showUserList"])
    {
        RoomRosterViewController* rosterVC = (RoomRosterViewController *)segue.destinationViewController;
        [rosterVC setupConference:self.contactName forAccount:self.accountNo];
    }
}

#pragma mark tableview datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.messagesDateList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [((NSMutableArray*)[self.messagesDateList objectAtIndex:section]) count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLBaseCell* cell;
    
    NSArray *messagesList = [self.messagesDateList objectAtIndex:indexPath.section];
    NSDictionary* row= [messagesList objectAtIndex:indexPath.row];
    
    NSString *from =[row objectForKey:@"af"];
    
    //intended to correct for bad data. Can be removed later probably.
    if([from isEqualToString:@"(null)"])
    {
        from=[row objectForKey:@"message_from"];;
    }
    NSString *messageType =[row objectForKey:kMessageType];
    
    if([messageType isEqualToString:kMessageTypeStatus])
    {
        cell=[tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
        cell.messageBody.text =[row objectForKey:@"message"];
        cell.link=nil;
        return cell;
    }
    
    if(_isMUC)
    {
        if([from isEqualToString:_jid])
        {
            cell=[tableView dequeueReusableCellWithIdentifier:@"textOutCell"];
        }
        else
        {
            cell=[tableView dequeueReusableCellWithIdentifier:@"textInCell"];
        }
    } else  {
        if([from isEqualToString:self.contactName])
        {
            cell=[tableView dequeueReusableCellWithIdentifier:@"textInCell"];
        }
        else
        {
            cell=[tableView dequeueReusableCellWithIdentifier:@"textOutCell"];
        }
        
        NSNumber *received = [row objectForKey:@"message"];
        if(received){
            
        }
    }
    
    
    NSDictionary *messageRow = [messagesList objectAtIndex:indexPath.row];
    
    NSString *messageString =[messageRow objectForKey:@"message"];
    
    if([messageType isEqualToString:kMessageTypeImage])
    {
        MLChatImageCell* imageCell;
        
        if([from isEqualToString:self.contactName])
        {
            imageCell= (MLChatImageCell *) [tableView dequeueReusableCellWithIdentifier:@"imageInCell"];
            imageCell.outBound=NO;
            
        }
        else  {
            imageCell= (MLChatImageCell *) [tableView dequeueReusableCellWithIdentifier:@"imageOutCell"];
            imageCell.outBound=YES;
        }
        
        imageCell.link = messageString;
        [imageCell loadImageWithCompletion:^{
            
            [self.messageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        cell=imageCell;
        
    } else  {
        
        NSString* lowerCase= [[row objectForKey:@"message"] lowercaseString];
        NSRange pos = [lowerCase rangeOfString:@"https://"];
        if(pos.location==NSNotFound) {
            pos=[lowerCase rangeOfString:@"http://"];
        }
        
        NSRange pos2;
        if(pos.location!=NSNotFound)
        {
            NSString* urlString =[[row objectForKey:@"message"] substringFromIndex:pos.location];
            pos2= [urlString rangeOfString:@" "];
            if(pos2.location==NSNotFound) {
                pos2= [urlString rangeOfString:@">"];
            }
            
            
            if(pos2.location!=NSNotFound) {
                urlString=[urlString substringToIndex:pos2.location];
            }
            
            
            cell.link=[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            NSAttributedString* underlined = [[NSAttributedString alloc] initWithString:cell.link
                                                                             attributes:underlineAttribute];
            
            
            if ([underlined length]==[[row objectForKey:@"message"] length])
            {
                cell.messageBody.attributedText=underlined;
            }
            else
            {
                NSMutableAttributedString* stitchedString  = [[NSMutableAttributedString alloc] init];
                [stitchedString appendAttributedString:
                 [[NSAttributedString alloc] initWithString:[[row objectForKey:@"message"] substringToIndex:pos.location] attributes:nil]];
                [stitchedString appendAttributedString:underlined];
                if(pos2.location!=NSNotFound)
                {
                    NSString* remainder = [[row objectForKey:@"message"] substringFromIndex:pos.location+[underlined length]];
                    [stitchedString appendAttributedString:[[NSAttributedString alloc] initWithString:remainder attributes:nil]];
                }
                cell.messageBody.attributedText=stitchedString;
            }
            
        }
        else
        {
            cell.messageBody.text =[row objectForKey:@"message"];
            cell.link=nil;
        }
        
    }
    
    if(_isMUC)
    {
        NSString *userName = [row objectForKey:@"af"];
        UIColor *userColor = [self.nameColorHash valueForKey:userName];
        UIColor *chatNameColor = [UIColor colorNamed:@"chat-name-color"];
        if (!userColor) {
            //            int random = 1 + arc4random() % (6);
            userColor = [UIColor colorNamed:[NSString stringWithFormat:@"rand-color-%d", self.wheelCounter]];
            
            //            CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
            //            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.8;  //  0.5 to 1.0, away from white
            //            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.8;  //  0.5 to 1.0, away from black
            //            userColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.5];
            
            [self.nameColorHash setValue:userColor forKey:userName];
        }
        
        BOOL contrast = [userColor sufficientContrastTo:chatNameColor withFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:12]];
        cell.name.textColor = contrast ? [UIColor whiteColor] : chatNameColor;
        cell.nameView.backgroundColor = userColor;
        
        cell.name.hidden = NO;
        cell.name.text = userName;
    } else  {
        
        cell.name.text=@"";
        cell.name.hidden=YES;
    }
    
    if([row objectForKey:@"delivered"]){
        if([[row objectForKey:@"delivered"] boolValue]!=YES)
        {
            cell.deliveryFailed=YES;
        }
    }
    
    
    
    NSNumber *received = [row objectForKey:kReceived];
    if(received.boolValue==YES) {
        NSDictionary *prior =nil;
        if(indexPath.row>0)
        {
            prior = [messagesList objectAtIndex:indexPath.row-1];
        }
        if(indexPath.row==messagesList.count-1 || ![[prior objectForKey:@"af"] isEqualToString:self.jid]) {
            cell.messageStatus.hidden=NO;
        } else  {
            cell.messageStatus.hidden=YES;
        }
    }
    else  {
        cell.messageStatus.hidden=YES;
    }
    
    
    cell.messageHistoryId=[row objectForKey:@"message_history_id"];
    cell.date.text= [self formattedDateTimeWithSource:[row objectForKey:@"thetime"]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if([[row objectForKey:@"af"] isEqualToString:_jid])
    {
        cell.outBound=YES;
    }
    
    cell.parent=self;
    
    [cell updateCell];
    
    return cell;
}

#pragma mark - tableview delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatInput resignFirstResponder];
    MLBaseCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.link)
    {
        if([cell respondsToSelector:@selector(openlink:)]) {
            [(MLChatCell *)cell openlink:self];
        } else  {
            
            self.photos =[[NSMutableArray alloc] init];
            
            MLChatImageCell *imageCell = (MLChatImageCell *) cell;
            
            MWPhoto* photo=[MWPhoto photoWithImage:imageCell.thumbnailImage.image];
            // photo.caption=[row objectForKey:@"caption"];
            [self.photos addObject:photo];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            
            browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
            browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
            browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
            browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
            browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
            browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
            browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
            
            UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:browser];
            
            
            [self presentViewController:nav animated:YES completion:nil];
            
        });
        
    }
}

#pragma mark tableview datasource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; // for now
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *messagesList = [self.messagesDateList objectAtIndex:indexPath.section];
        NSDictionary* message= [messagesList objectAtIndex:indexPath.row];
        
        DDLogVerbose(@"%@", message);
        
        if([message objectForKey:@"message_history_id"])
        {
            [[DataLayer sharedInstance] deleteMessageHistory:[NSString stringWithFormat:@"%@",[message objectForKey:@"message_history_id"]]];
        }
        else
        {
            return;
        }
        [messagesList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}

//dummy function needed to remove warnign
-(void) openlink: (id) sender {
    
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ChatSectionHeaderCell *cell = (ChatSectionHeaderCell*)[tableView dequeueReusableCellWithIdentifier:@"headerCell"];
    NSMutableArray *messagesList = [self.messagesDateList objectAtIndex:section];
    NSDictionary* message= [messagesList firstObject];
    [cell.date setText:[self formattedDateWithSource:[message objectForKey:@"thetime"]]];;
    return cell.contentView;
}

# pragma mark Textview delegate functions

-(void) updateInputViewSize
{
    
    if(self.chatInput.intrinsicContentSize.height>43) {
        self.inputContainerHeight.constant= self.chatInput.intrinsicContentSize.height+16+10;
        self.chatInput.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    } else
    {
        self.inputContainerHeight.constant=43.0f;
        self.chatInput.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    }
    [self.chatInput setScrollEnabled:NO];
    [self.inputContainerView layoutIfNeeded];
    [self.chatInput setScrollEnabled:YES];
    [self.chatInput scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToBottom];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL shouldinsert=YES;
    
    if(self.usingExternalKeybaord && [text isEqualToString:@"\n"])
    {
        [self resignTextView];
        shouldinsert=NO;
        [self updateInputViewSize];
    }
    
    return shouldinsert;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateInputViewSize];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"BEGIN");
    self.manualScrolled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat bottomInset = scrollView.contentInset.bottom;
    CGFloat bottomScrollY = offsetY + scrollHeight - bottomInset;
    CGFloat fuzzFactor = 3;
    CGFloat boundary = scrollView.contentSize.height-fuzzFactor;
    if (bottomScrollY >= boundary && !self.scrolledToBottom) {
        self.scrolledToBottom = YES;
        self.manualScrolled = NO;
    } else if (bottomScrollY < boundary ) {
        self.scrolledToBottom = NO;
    }
}


#pragma mark - photo browser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}


#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(self.blockAnimations) return;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.inputContainerBottom.constant = keyboardSize.height;
                         CGFloat yOffset = self.messageTable.contentOffset.y;
                         [self.messageTable setContentOffset:CGPointMake(0, yOffset + keyboardSize.height)];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if(self.blockAnimations) return;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.inputContainerBottom.constant = 0;
                         CGFloat yOffset = self.messageTable.contentOffset.y;
                         [self.messageTable setContentOffset:CGPointMake(0, yOffset - keyboardSize.height)];
                         [self.view layoutIfNeeded];
                     }];
    
    _keyboardVisible=NO;
    DDLogVerbose(@"kbd will hide scroll: %f", oldFrame.size.height);
}

@end
