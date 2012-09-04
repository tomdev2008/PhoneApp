//
//  UIImage+scaling.m
//  GiftGiv
//
//  Created by Srinivas G on 04/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "UIImage+scaling.h"
#include <ImageIO/ImageIO.h>

@implementation UIImage (scaling)

//Method used to resize a image by maintaining aspect ratio
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
	//UIImage *sourceImage = srcImage;
	UIImage *newImage = nil;
	
	CGSize imageSize = self.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor < heightFactor) 
			scaleFactor = widthFactor;
        else
			scaleFactor = heightFactor;
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
		
        if (widthFactor < heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor > heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
	}
	
	//NSLog(@"scaled width..%f,scaledheight %f",scaledWidth,scaledHeight);
    
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = CGPointZero;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
    
	[self drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//if(newImage == nil) 
		//NSLog(@"could not scale image");
	
	/*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

	[UIImagePNGRepresentation(self) writeToFile:[documentsDirectory stringByAppendingPathComponent:@"originalImage.png"] atomically:YES];
	[UIImagePNGRepresentation(newImage) writeToFile:[documentsDirectory stringByAppendingPathComponent:@"resizedImage.png"] atomically:YES];
	*/
	return newImage ;
}

//Method used to resize a image
- (UIImage *)scaleImageToSizeMaxSize:(CGSize)newSize
{
	// Create a graphics image context
	//UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
    UIGraphicsBeginImageContext(newSize);
	// Tell the old image to draw in this new context, with the desired
	[self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	// End the context
	UIGraphicsEndImageContext();
	// Return the new image.
	return newImage;
}

-(UIImage *)getThumbnailImage:(int)size {
    // Assuming source is a CGImageSourceRef
    UIImage *newImage=nil;
    
    CGImageSourceRef source=CGImageSourceCreateWithData((CFDataRef)UIImagePNGRepresentation(self),
                                                        NULL);
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                           (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                           (id) [NSNumber numberWithInt:size],(id)kCGImageSourceThumbnailMaxPixelSize,nil];
    
    CGImageRef imageRef=CGImageSourceCreateThumbnailAtIndex(source,0,(CFDictionaryRef)options);
    if(imageRef)
        newImage=[UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CFRelease(source);

    
    return newImage;
}


-(UIImage *)CreateThumbnailImageFromData:(int)imageSize
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)UIImagePNGRepresentation(self),
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return nil;
    }
    UIImage *thumbNailImage=[UIImage imageWithCGImage:myThumbnailImage];
    CFRelease(myThumbnailImage);
    return thumbNailImage;
}



@end
