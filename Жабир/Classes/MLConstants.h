//
//  MLConstants.h
//  Jabir
//
//  Created by Anurodh Pokharel on 7/13/13.
//
//

#import <Foundation/Foundation.h>
#import "DDLogMacros.h"

//used in OSX only really
#define kJabirWindowVisible @"kJabirWindowVisible"

#define kJabirNewMessageNotice @"kMLNewMessageNotice"
#define kJabirSentMessageNotice @"kMLSentMessageNotice"
#define kJabirSendFailedMessageNotice @"kJabirSendFailedMessageNotice"

#define kJabirMessageReceivedNotice @"kJabirMessageReceivedNotice"

#define kJabirContactOnlineNotice @"kMLContactOnlineNotice"
#define kJabirContactOfflineNotice @"kMLContactOfflineNotice"
#define kMLHasRoomsNotice @"kMLHasRoomsNotice"
#define kMLHasConnectedNotice @"kMLHasConnectedNotice"

#define kJabirCallStartedNotice @"kJabirCallStartedNotice"
#define kJabirCallRequestNotice @"kJabirCallRequestNotice"

#define kJabirAccountStatusChanged @"kJabirAccountStatusChanged"

#define kJabirContactRefresh @"kJabirContactRefresh"
#define kJabirRefreshContacts @"kJabirRefreshContacts"

#define kDelivered @"delivered"
#define kReceived @"received"

//contact cells
#define kusernameKey @"username"
#define kfullNameKey @"fullName"
#define kaccountNoKey @"accountNo"
#define kstateKey @"state"
#define kstatusKey @"status"

//info cells
#define kaccountNameKey @"accountName"
#define kinfoTypeKey @"type"
#define kinfoStatusKey @"status"

// MUC settings
#define kMaxHistoryMessages 20

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#if TARGET_OS_IPHONE
/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#else
#endif


#ifndef DEBUG
#define DEBUG 1
#endif
