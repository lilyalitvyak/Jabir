//
//  NSString+SqlLIte.h
//  Jabir
//
//  Created by Anurodh Pokharel on 9/4/14.
//  Copyright (c) 2014 Jabir.im. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SqlLite)

/**
 escapes single quotes for sqlilite
 */
-(NSString *) escapeForSql;
@end
