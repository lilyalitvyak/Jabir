//
//  UIColor+Theme.m
//  Monal
//
//  Created by Anurodh Pokharel on 4/1/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+(UIColor *) monalGreen {
    UIColor *monalGreen = UIColorFromRGB(0x009688);
    return monalGreen;
}

+(UIColor *) monaldarkGreen {
    UIColor *monaldarkGreen =[UIColor colorWithRed:20.0/255 green:138.0/255 blue:103.0/255 alpha:1.0f];
    return monaldarkGreen;
}

@end
