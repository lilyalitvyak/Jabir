//
//  AppDelegate.h
//  Jabir-OSX
//
//  Created by Anurodh Pokharel on 6/9/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DDLogMacros.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import "DDTTYLogger.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (nonatomic , weak) NSWindowController* mainWindowController;
@property (nonatomic, strong)  DDFileLogger *fileLogger;

@property (nonatomic , weak) IBOutlet NSMenuItem *serverDetails;



@end

