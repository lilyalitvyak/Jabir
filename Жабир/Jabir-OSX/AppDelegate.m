//
//  AppDelegate.m
//  Jabir-OSX
//
//  Created by Anurodh Pokharel on 6/9/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import "AppDelegate.h"

#import "MASPreferencesWindowController.h"
#import "MLAccountSettings.h"
#import "MLDisplaySettings.h"
#import "MLPresenceSettings.h"
#import "MLCloudStorageSettings.h"
#import "MLXMPPManager.h"

#import "NXOAuth2.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DDLogMacros.h"
#import "DataLayer.h"

#import <DropboxOSX/DropboxOSX.h>

static const int ddLogLevel = DDLogLevelVerbose;

@interface AppDelegate ()

@property (nonatomic , strong) MASPreferencesWindowController *preferencesWindow;
@property (nonatomic , weak)  MLAccountSettings *accountsVC;
@property (nonatomic , weak)  MLPresenceSettings *presenceVC;
@property (nonatomic , weak)  MLDisplaySettings *displayVC;
@property (nonatomic , weak)  MLCloudStorageSettings *cloudVC;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#ifdef  DEBUG
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    self.fileLogger.maximumFileSize=1024 * 500;
    [DDLog addLogger:self.fileLogger];
#endif
    
    [[MLXMPPManager sharedInstance] connectIfNecessary];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
    [Fabric with:@[[Crashlytics class]]];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receivedSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receivedWakeNotification:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
   
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    //Dropbox
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"a134q2ecj1hqa59"
                            appSecret:@"vqsf5vt6guedlrs"
                            root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];


    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    
    if(flag==NO){
        [self.mainWindowController showWindow:self];
    }
    return YES;	
}

-(void) application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    NSURL *url= [urls firstObject];
    [[NXOAuth2AccountStore sharedStore] handleRedirectURL: url];
}



- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
//    if ([[DBSession sharedSession] handleOpenURL:[event paramDescriptorForKeyword:keyDirectObject]]) {
//        if ([[DBSession sharedSession] isLinked]) {
//            DDLogVerbose(@"App linked successfully!");
//            // At this point you can start making API calls
//        }
    
 //   }
    // Add whatever other url handling code your app requires here
 
    
}


-(IBAction)displayWindow:(id)sender;
{
    [self.mainWindowController showWindow:self];
}

#pragma mark - device sleep 
- (void) receivedSleepNotification: (NSNotification*) notificaiton
{
    DDLogVerbose(@"Device Sleeping");
    [[MLXMPPManager sharedInstance] logoutAll];
}

- (void) receivedWakeNotification: (NSNotification*) notification
{
    DDLogVerbose(@"Device Waking. Connecting in 5 sec");
    dispatch_queue_t q_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), q_background,  ^{
        [[MLXMPPManager sharedInstance] connectIfNecessary];
    });
}

#pragma mark  - Actions
-(void) linkVCs
{
    NSStoryboard *storyboard= [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    if(!self.accountsVC)
    {
        self.accountsVC = [storyboard instantiateControllerWithIdentifier:@"accounts"];        
    }
    
    if(!self.presenceVC)
    {
        self.presenceVC = [storyboard instantiateControllerWithIdentifier:@"presence"];
    }
    
    if(!self.displayVC)
    {
        self.displayVC = [storyboard instantiateControllerWithIdentifier:@"display"];
    }
    
    if(!self.cloudVC)
    {
        self.cloudVC = [storyboard instantiateControllerWithIdentifier:@"cloudStorage"];
    }
    
}

-(IBAction)showPreferences:(id)sender
{
    [self linkVCs];
    if(!self.preferencesWindow) {
        NSArray *array = @[self.accountsVC, self.presenceVC, self.displayVC, self.cloudVC];
        self.preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:array];
    }
    [self.preferencesWindow showWindow:self];
    
}



#pragma mark - Menu delegate

-(void)menuWillOpen:(NSMenu *)menu
{
    
    [[DataLayer sharedInstance] accountListWithCompletion:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          
            if(self.serverDetails.submenu.itemArray.count>0) {
                NSMenuItem *template =[self.serverDetails.submenu.itemArray[0] copy];
                [self.serverDetails.submenu removeAllItems ];
                for(NSDictionary *account in result)
                {
                    
                    NSNumber *accountId =[account objectForKey:@"account_id"];
                    xmpp* xmppAccount= [[MLXMPPManager sharedInstance] getConnectedAccountForID:[NSString stringWithFormat:@"%@", accountId ]];
                    if(xmppAccount) {
                        NSMenuItem *item =[template copy];
                        
                        item.title=xmppAccount.server;
                        item.tag=1000+accountId.integerValue;
                        
                        [self.serverDetails.submenu addItem:item];
                    }
                }
            }
        });
        
    }];
    
    
}




@end
