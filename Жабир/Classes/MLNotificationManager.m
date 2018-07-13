//
//  MLNotificationManager.m
//  Jabir
//
//  Created by Anurodh Pokharel on 7/20/13.
//
//

#import "MLNotificationManager.h"
@import UserNotifications;



static const int ddLogLevel = DDLogLevelVerbose;

@implementation MLNotificationManager

+ (MLNotificationManager* )sharedInstance
{
    static dispatch_once_t once;
    static MLNotificationManager* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[MLNotificationManager alloc] init] ;
    });
    return sharedInstance;
}

-(id) init
{
    self=[super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessage:) name:kJabirNewMessageNotice object:nil];
    return self;
}

#pragma mark message signals

-(void) handleNewMessage:(NSNotification *)notification
{
    DDLogVerbose(@"notificaiton manager got new message notice %@", notification.userInfo);
    if ([[notification.userInfo objectForKey:@"showAlert"] boolValue]) {
    dispatch_async(dispatch_get_main_queue(),
                  ^{
                     NSString* acctString =[NSString stringWithFormat:@"%ld", (long)[[notification.userInfo objectForKey:@"accountNo"] integerValue]];  
                      NSString* fullName =[[DataLayer sharedInstance] fullName:[notification.userInfo objectForKey:@"from"] forAccount:acctString];
                      
                      NSString* nameToShow=[notification.userInfo objectForKey:@"from"];
                      if([fullName length]>0) nameToShow=fullName;
                      
                      if(([UIApplication sharedApplication].applicationState==UIApplicationStateBackground)
                         || ([UIApplication sharedApplication].applicationState==UIApplicationStateInactive ))
                      {
                          //present notification
                          
                          NSDate* theDate=[NSDate dateWithTimeIntervalSinceNow:0]; //immediate fire
                          
                          UIApplication* app = [UIApplication sharedApplication];
                          NSArray*    oldNotifications = [app scheduledLocalNotifications];
                          
                          // Clear out the old notification before scheduling a new one.
                          if ([oldNotifications count] > 0)
                              [app cancelAllLocalNotifications];
                          
                          // Create a new notification
                          UILocalNotification* alarm = [[UILocalNotification alloc] init];
                          if (alarm)
                          {
                              //scehdule info
                              alarm.fireDate = theDate;
                              alarm.timeZone = [NSTimeZone defaultTimeZone];
                              alarm.repeatInterval = 0;
                              alarm.category=@"Reply";
                              
                              
                              if([[NSUserDefaults standardUserDefaults] boolForKey:@"MessagePreview"])
                                  alarm.alertBody = [NSString stringWithFormat: @"%@: %@", nameToShow, [notification.userInfo objectForKey:@"messageText"]];
                              else
                                  alarm.alertBody =  nameToShow;
                              
                              if( [[NSUserDefaults standardUserDefaults] boolForKey:@"Sound"]==true)
                              {
                                  alarm.soundName=UILocalNotificationDefaultSoundName; 
                              }
                              
                              alarm.userInfo=notification.userInfo;
                              [app scheduleLocalNotification:alarm];
                              
                              DDLogVerbose(@"Scheduled local message alert "); 
                              
                          }
                          
   
                      }
                      else
                   {
                      
                       if(!([[notification.userInfo objectForKey:@"from"] isEqualToString:self.currentContact]) &&
                          !([[notification.userInfo objectForKey:@"to"] isEqualToString:self.currentContact] ) )
                        //  &&![[notification.userInfo objectForKey:@"from"] isEqualToString:@"Info"]
                          
                       {
                       
                          
                           if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
                               
                               UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                               content.title =[notification.userInfo objectForKey:@"from"];
                               content.body =[notification.userInfo objectForKey:@"messageText"];
                               content.sound = [UNNotificationSound defaultSound];
                               content.userInfo= notification.userInfo;
                               
                               UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:[NSUUID alloc].UUIDString
                                                                                                     content:content trigger:nil];
                               
                               UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                               
                               [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                   
                               }];
                               
                               
                           } else  {
                               
                               
                               SlidingMessageViewController* slidingView= [[SlidingMessageViewController alloc] correctSliderWithTitle:nameToShow message:[notification.userInfo objectForKey:@"messageText"] user:[notification.userInfo objectForKey:@"from"] account:[notification.userInfo objectForKey:@"accountNo"] ];
                               
                               [self.window addSubview:slidingView.view];
                               
                               [slidingView showMsg];
                           }
                           
                       }
                       
                   }
                      
                  });
    }
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
