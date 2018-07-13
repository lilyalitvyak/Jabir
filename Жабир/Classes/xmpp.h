//
//  xmpp.h
//  Jabir
//
//  Created by Anurodh Pokharel on 6/29/13.
//
//

#import <Foundation/Foundation.h>
#import "MLXMLNode.h"
#import "EncodingTools.h"


#if TARGET_OS_IPHONE
#import "ContactsViewController.h"
#else
#import "MLContactsViewController.h"
#endif

#import "MLConstants.h"
#import "jingleCall.h"

// networking objects
#import <unistd.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import <nameser.h>
#import <dns_sd.h>

#ifndef T_SRV
#define T_SRV 33
#endif

#ifndef T_PTR
#define T_PTR 12
#endif

#ifndef T_A
#define T_A 1
#endif

#ifndef T_TXT
#define T_TXT 16
#endif

#define MAX_DOMAIN_LABEL 63
#define MAX_DOMAIN_NAME 255
#define MAX_CSTRING 2044

typedef union { unsigned char b[2]; unsigned short NotAnInteger; } Opaque16;

typedef struct { u_char c[ 64]; } domainlabel;
typedef struct { u_char c[256]; } domainname;


typedef struct
{
    uint16_t priority;
    uint16_t weight;
    uint16_t port;
    domainname target;
} srv_rdata;

typedef NS_ENUM (NSInteger, xmppState) {
    kStateLoggedOut =-1,
    kStateDisconnected , // has connected once
    kStateReconnecting ,
    kStateHasStream ,
    kStateLoggedIn ,
    kStateBound //is operating normally
};


extern NSString *const kXMPPError;
extern NSString *const kXMPPSuccess;
extern NSString *const kXMPPPresence;

@interface xmpp : NSObject <NSStreamDelegate>
{
    NSInputStream *_iStream;
    NSOutputStream *_oStream;
    NSMutableString* _inputBuffer;
    NSMutableArray* _outputQueue;
    
    NSArray* _stanzaTypes;
    
    BOOL _startTLSComplete;

    //does not reset at disconnect
    BOOL _loggedInOnce;
    BOOL _hasRequestedServerInfo;
    
    BOOL _brokenServerSSL;
}

-(void) connect;
-(void) disconnect;


/**
 send a message to a contact with xmpp id
 */
-(void) sendMessage:(NSString*) message toContact:(NSString*) contact isMUC:(BOOL) isMUC andMessageId:(NSString *) messageId;
/**
 crafts a whitepace ping and sends it
 */
-(void) sendWhiteSpacePing;

/**
 crafts a  ping and sends it
 */
-(void) sendPing;

/**
 Adds the stanza to the output Queue
 */
-(void) send:(MLXMLNode*) stanza;

/**
 removes a contact from the roster
 */
-(void) removeFromRoster:(NSString*) contact;

/**
 adds a new contact to the roster
 */
-(void) addToRoster:(NSString*) contact;

/**
 adds a new contact to the roster
 */
-(void) approveToRoster:(NSString*) contact;

/**
 sets up a background task to reconnect if needed. dEfault wait of 5s
 */
-(void) reconnect;

/**
 reconnect called with a specified wait. if never logged in then wait is 0. 
 */
-(void) reconnect:(NSInteger) scheduleWait;



#pragma mark set connection attributes
/**
sets the status message. makes xmpp call
 */
-(void) setStatusMessageText:(NSString*) message;

/**
sets away xmpp call.
 */
-(void) setAway:(BOOL) away;

/**
 sets visibility xmpp call.
 */
-(void) setVisible:(BOOL) visible;

/**
 sets priority. makes xmpp call. this is differnt from setting the property value itself.
 */
-(void) updatePriority:(NSInteger) priority;

/**
 request futher service detail
 */
-(void) getServiceDetails;

/**
 get list of rooms on conference server
 */
-(void) getConferenceRooms;

/**
 join a room on the conference server
 */
-(void) joinRoom:(NSString*) room withNick:(NSString*) nick andPassword:(NSString *)password;

/**
 leave specific room
 */
-(void) leaveRoom:(NSString*) room;

#pragma mark Jingle
/**
 Calls a contact
 */
-(void)call:(NSDictionary*) contact;

/**
Hangs up current call with contact
 */
-(void)hangup:(NSDictionary*) contact;

/**
Decline a call request
 */
-(void)declineCall:(NSDictionary*) contact;

/**
 accept call request
 */
-(void)acceptCall:(NSDictionary*) contact;


/*
 notifies the server client is in foreground
 */
-(void) setClientActive;

/*
 notifies the server client is in foreground
 */
-(void) setClientInactive;


/*
 HTTP upload
*/
 -(void) requestHTTPSlotWithParams:(NSDictionary *)params andCompletion:(void(^)(NSString *url,  NSError *error)) completion;

/*
 query message archive.
 */
-(void) setMAMQueryFromStart:(NSDate *) startDate toDate:(NSDate *) endDate  andJid:(NSString *)jid;

/**
 enable APNS push with provided tokens
 */
-(void) enablePush;

/**
 query a user's vcard
 */
-(void)getVCard:(NSString *) user;

FOUNDATION_EXPORT NSString *const kFileName;
FOUNDATION_EXPORT NSString *const kContentType;
FOUNDATION_EXPORT NSString *const kData;
FOUNDATION_EXPORT NSString *const kContact;
FOUNDATION_EXPORT NSString *const kCompletion;


#pragma  mark properties

@property (nonatomic,strong) NSString* pushNode;
@property (nonatomic,strong) NSString* pushSecret;

@property (nonatomic,readonly) NSString* fulluser; // combination of username@domain

// connection attributes
@property (nonatomic,strong) NSString* username;
@property (nonatomic,strong) NSString* domain;
@property (nonatomic,strong, readonly) NSString* jid;
@property (nonatomic,strong) NSString* password;
@property (nonatomic,strong) NSString* server;
@property (nonatomic,assign) NSInteger port;
@property (nonatomic,strong) NSString* resource;
@property (nonatomic,assign) BOOL SSL;
@property (nonatomic,assign) BOOL oldStyleSSL;
@property (nonatomic,assign) BOOL selfSigned;
@property (nonatomic,assign) BOOL oAuth;


@property (nonatomic,strong) jingleCall* call;

// state attributes
@property (nonatomic,assign) NSInteger priority;
@property (nonatomic,strong) NSString* statusMessage;
@property (nonatomic,assign) BOOL awayState;
@property (nonatomic,assign) BOOL visibleState;

@property (nonatomic,assign) BOOL hasShownAlert;

@property (nonatomic, strong) jingleCall *jingle;

// DB info
@property (nonatomic,strong) NSString* accountNo;

//we should have an enumerator for this
@property (nonatomic,assign) BOOL explicitLogout;
@property (nonatomic,assign,readonly) BOOL loginError;

@property (nonatomic, readonly) xmppState accountState;

// discovered properties
@property (nonatomic,strong)  NSMutableArray* discoveredServerList;
@property (nonatomic,strong)  NSMutableArray*  discoveredServices;
@property (nonatomic,strong)  NSString*  conferenceServer;
@property (nonatomic,strong)  NSArray*  roomList;
@property (nonatomic, strong) NSArray* rosterList;


@property (nonatomic,strong)  NSString*  uploadServer;
@property (nonatomic, readonly) BOOL supportsHTTPUpload;
// client state
@property (nonatomic, readonly) BOOL supportsClientState;

//message archive
@property (nonatomic, readonly) BOOL supportsMam0;

@property (nonatomic, readonly) BOOL supportsSM3;
@property (nonatomic, readonly) BOOL supportsPush;
@property (nonatomic, readonly) BOOL pushEnabled;
@property (nonatomic, readonly) BOOL usingCarbons2;
@property (nonatomic, readonly) BOOL supportsRosterVersion;

//calculated
@property (nonatomic,strong, readonly) NSString* versionHash;

#if TARGET_OS_IPHONE
@property (nonatomic,weak) ContactsViewController* contactsVC;
#else
@property (nonatomic,weak) MLContactsViewController* contactsVC;
#endif
//UI


@property (nonatomic,strong) NSDate* connectedTime;

extern NSString *const kId;
extern NSString *const kMessageId;
extern NSString *const kSendTimer;

/**
 An intentional disconnect to trigger APNS. does not close the stream. 
 */
-(void) disconnectToResume;

@end
