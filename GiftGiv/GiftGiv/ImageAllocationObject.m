//
//  ImageAllocationObject.m
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "ImageAllocationObject.h"


@implementation ImageAllocationObject

+(UIImage *) loadImageObjectName:(NSString*)imageName ofType:(NSString*)extensionType{
	
	UIImage *tempImg=[[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:extensionType]] autorelease];

	return tempImg;
}
@end
