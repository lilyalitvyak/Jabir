//
//  UIImage+ColorMask.h
//  Monal
//
//  Created by Vladimir Vaskin on 09.07.2018.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ColorMask)

+ (UIImage *) image:(UIImage *)image withMaskColor:(UIColor *)color;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode highQuality:(BOOL) yerOrNo;

@end

NS_ASSUME_NONNULL_END
