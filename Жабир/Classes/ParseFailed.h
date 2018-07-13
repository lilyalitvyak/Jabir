//
//  ParseFailed.h
//  Jabir
//
//  Created by Thilo Molitor on 4/19/17.
//  Copyright (c) 2017 Jabir.im. All rights reserved.
//

#import "XMPPParser.h"

@interface ParseFailed : XMPPParser
/**
 last handled value
 */
@property (nonatomic, strong, readonly) NSNumber *h;


@end
