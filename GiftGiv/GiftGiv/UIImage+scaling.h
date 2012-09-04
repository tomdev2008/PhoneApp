//
//  UIImage+scaling.h
//  GiftGiv
//
//  Created by Srinivas G on 04/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (scaling)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

- (UIImage *)scaleImageToSizeMaxSize:(CGSize)newSize;

- (UIImage *)getThumbnailImage:(int)size ;

- (UIImage *)CreateThumbnailImageFromData:(int)imageSize;

@end
