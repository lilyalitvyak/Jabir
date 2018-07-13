//
//  ParseA.h
//  Jabir
//
//  Created by Anurodh Pokharel on 2/2/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import "XMPPParser.h"

@interface ParseA : XMPPParser

/**
last handled value
 */
@property (nonatomic, strong, readonly) NSNumber *h;

@end
