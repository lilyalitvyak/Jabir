//
//  ParseFailed.m
//  Jabir
//
//  Created by Thilo Molitor on 4/19/17.
//  Copyright (c) 2017 Jabir.im. All rights reserved.
//

#import "ParseFailed.h"

@implementation ParseFailed

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _messageBuffer=nil;
    
    //    if([[attributeDict objectForKey:@"xmlns"] isEqualToString:@"urn:xmpp:sm:3"])
    //    {
    //
    //    }
    
    _h=[NSNumber numberWithInteger:[(NSString*)[attributeDict objectForKey:@"h"] integerValue]];
    
}

@end
