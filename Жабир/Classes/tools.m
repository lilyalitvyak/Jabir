
//  tools.m
//  SworIM
//
//  Created by Anurodh Pokharel on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "tools.h"
#import <CommonCrypto/CommonDigest.h>


@implementation tools

+ (float)degreesToRadians:(float)degrees{
	return degrees / 57.2958;
}


// Return a scaled down copy of the image.  

+(UIImage*)  resizedImage:(UIImage *)inImage withRect:(CGRect)thumbRect
{
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												thumbRect.size.width,		// width
												thumbRect.size.height,		// height
												CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												4 * thumbRect.size.width,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo
												);
	if(bitmap!=NULL)
	{
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, thumbRect, imageRef);
	
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
	}
	else
	{
		
		return inImage; // just return the same thing
	}
}



+ (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim {
	
	NSScanner *theScanner;
	NSString *text = nil;
	
	theScanner = [NSScanner scannerWithString:html];
	
	while ([theScanner isAtEnd] == NO) {
		
		// find start of tag
		[theScanner scanUpToString:@"<" intoString:NULL] ;                 
		// find end of tag         
		[theScanner scanUpToString:@">" intoString:&text] ;
		
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@" "];
		
	} // while //
	
	// trim off whitespace
	return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
	
}

+ (NSDateFormatter *)timeFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    return dateFormatter;
}

+ (NSDateFormatter *)dateTimeFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    }
    
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    }
    
    return dateFormatter;
}

+ (NSString*)timeOrDatetimeFromTimestamp:(NSInteger)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [[self class] timeOrDatetimeFromDate:date];
}

+ (NSString*)timeOrDatetimeFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSCalendar currentCalendar] isDate:date inSameDayAsDate:[NSDate date]] ?
    [[self class] timeFormatter] :
    [[self class] dateTimeFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)dateFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[self class] dateFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)timeFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[self class] timeFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)dateTimeFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[self class] dateTimeFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)md5FromStrings:(NSArray*)strings
{
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char output[outputLength];
    NSString *str = [strings componentsJoinedByString:@"-"];
    
    CC_MD5(str.UTF8String, (unsigned int)[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], output);
    NSMutableString* hash = [NSMutableString stringWithCapacity:outputLength * 2];
    for (unsigned int i = 0; i < outputLength; i++) {
        [hash appendFormat:@"%02x", output[i]];
        output[i] = 0;
    }
    
    return [hash copy];
}

+ (NSString *)notnull:(NSString*)string
{
    return string?string:@"";
}

@end
