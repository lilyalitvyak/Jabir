//
//  XMPPIQ.h
//  Jabir
//
//  Created by Anurodh Pokharel on 6/30/13.
//
//

#import "MLXMLNode.h"

#define kiqGetType @"get"
#define kiqSetType @"set"
#define kiqResultType @"result"
#define kiqErrorType @"error"

@interface XMPPIQ : MLXMLNode

-(id) initWithId:(NSString*) sessionid andType:(NSString*) iqType;
-(id) initWithType:(NSString*) iqType;

-(void) setPushEnableWithNode:(NSString *)node andSecret:(NSString *)secret;
-(void) setPushDisableWithNode:(NSString *)node;

/**
 login with legacy authentication. only as fallback.
 */
-(void) setAuthWithUserName:(NSString *)username resource:(NSString *) resource andPassword:(NSString *) password;

/**
 Makes an iq to bind with a resouce. Passing nil will set no resource.
 */
-(void) setBindWithResource:(NSString*) resource;

/**
 set to attribute
 */
-(void) setiqTo:(NSString*) to;

/**
 makes iq of ping type
 */
-(void) setPing;

/**
 makes iq for mam query since a date and time for jid. If no date is provided, will query all. If no jid is provided it will query all
 */
-(void) setMAMQueryFromStart:(NSDate *) startDate toDate:(NSDate *) endDate  andJid:(NSString *)jid;

#pragma mark disco
/**
 makes a disco info response for the server.
 @param the param passed is the xmpp node attribute that came in with the iq get
 */
-(void) setDiscoInfoWithFeaturesAndNode:(NSString*) node;

/**
 sets up a disco info query node
 */
-(void) setDiscoInfoNode;

/**
 sets up a disco info query node
 */
-(void) setDiscoItemNode;

#pragma mark legacy authentication
/**
 legacy autnetication. only used as a fallback
 */
-(void) getAuthwithUserName:(NSString *)username;

#pragma mark roster
/**
gets vcard info 
 */
-(void) getVcardTo:(NSString*) to;

/**
removes a contact from the roster
 */
-(void) setRemoveFromRoster:(NSString*) jid;

/**
 Requests a full roster from the server. A null version will not set the ver attribute
 */
-(void) setRosterRequest:(NSString *) version;

/**
 makes iq  with version element
 */
-(void) setVersion;

/**
 sends last seconds as 0 since if we are responding we arent away. Migth want to add a timer for away in the future. 
 */
-(void) setLast;


/**
 sets up an iq that requests a http upload slot
 */
-(void) httpUploadforFile:(NSString *) file ofSize:(NSNumber *) filesize andContentType:(NSString *) contentType;


#pragma mark MUC
/**
 create instant room
 */
-(void) setInstantRoom;

#pragma mark Jingle


/**
 Dictionary info has initiator, responder, sid, ownip, localport1, localport2
 */
-(void) setJingleInitiateTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info;
/**
 Dictionary info has initiator, responder, sid, ownip, localport1, localport2
 */
-(void) setJingleAcceptTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info;
/**
 Dictionary info has initiator, responder, sid
 */
-(void) setJingleDeclineTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info;
/**
 Dictionary info has initiator, responder, sid, ownip
 */
-(void) setJingleTerminateTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info;

/**
 features string for hashing
 */
+(NSString *) featuresString;

@end
