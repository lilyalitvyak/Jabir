//
//  MLDisabledScrollView.m
//  Jabir
//
//  Created by Anurodh Pokharel on 8/10/15.
//  Copyright (c) 2015 Jabir.im. All rights reserved.
//

#import "MLDisabledScrollView.h"

@implementation MLDisabledScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    [[self nextResponder] scrollWheel:theEvent];
}

@end
