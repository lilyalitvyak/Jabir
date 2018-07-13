//
//  XMPPMessage.m
//  Jabir
//
//  Created by Anurodh Pokharel on 7/13/13.
//
//

#import "XMPPMessage.h"

@implementation XMPPMessage

 NSString* const kMessageChatType=@"chat";
 NSString* const kMessageGroupChatType=@"groupchat";
 NSString* const kMessageErrorType=@"error";
 NSString* const kMessageNormalType =@"normal";

-(id) init
{
    self= [super init];
    self.element=@"message";
    return self;
}

-(void) setXmppId:(NSString*) idval
{
    [self.attributes setObject:idval forKey:@"id"];
}

-(NSString *) xmppId
{
    return  [self.attributes objectForKey:@"id"];
}

-(void) setBody:(NSString*) messageBody
{
    MLXMLNode* body =[[MLXMLNode alloc] init];
    body.element=@"body";
    body.data=messageBody;
    [self.children addObject:body];
}

-(void) setReceipt:(NSString*) messageId
{
    MLXMLNode* received =[[MLXMLNode alloc] init];
    received.element=@"received";
    [received.attributes setValue:@"urn:xmpp:receipts" forKey:@"xmlns"];
    [received.attributes setValue:messageId forKey:@"id"];
    [self.children addObject:received];
}


@end
