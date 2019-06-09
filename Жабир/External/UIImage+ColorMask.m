//
//  UIImage+ColorMask.m
//  Jabir
//
//  Created by Lilya Litvyak on 09.07.2018.
//  Copyright © 2018 Jabir.im. All rights reserved.
//

#import "UIImage+ColorMask.h"

@implementation UIImage (ColorMask)


-(UIImage *) negativeImage

{
    
    UIGraphicsBeginImageContext(self.size);
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    
    UIImage *negativeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return negativeImage;
    
}

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode highQuality:(BOOL) yerOrNo
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    if (yerOrNo) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    }
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIImage *) imageWithWhiteBackground

{
    
    UIImage *negative = [self negativeImage];
    
    
    
    UIGraphicsBeginImageContext(negative.size);
    
    CGContextSetRGBFillColor (UIGraphicsGetCurrentContext(), 1, 1, 1, 1);
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = CGPointZero;
    
    thumbnailRect.size.width = negative.size.width;
    
    thumbnailRect.size.height = negative.size.height;
    
    
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, negative.size.height);
    
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), thumbnailRect);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), thumbnailRect, negative.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    return newImage;
    
}


+ (UIImage *) image:(UIImage *)image withMaskColor:(UIColor *)color

{
    
    UIImage *formattedImage = [image imageWithWhiteBackground];
    
    
    
    CGRect rect = {0, 0, formattedImage.size.width, formattedImage.size.height};
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [color setFill];
    
    UIRectFill(rect);
    
    UIImage *tempColor = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    CGImageRef maskRef = [formattedImage CGImage];
    
    CGImageRef maskcg = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                          
                                          CGImageGetHeight(maskRef),
                                          
                                          CGImageGetBitsPerComponent(maskRef),
                                          
                                          CGImageGetBitsPerPixel(maskRef),
                                          
                                          CGImageGetBytesPerRow(maskRef),
                                          
                                          CGImageGetDataProvider(maskRef), NULL, false);
    
    
    
    CGImageRef maskedcg = CGImageCreateWithMask([tempColor CGImage], maskcg);
    
    CGImageRelease(maskcg);
    
    UIImage *result = [UIImage imageWithCGImage:maskedcg];
    
    CGImageRelease(maskedcg);
    
    
    
    return result;
    
}

@end
