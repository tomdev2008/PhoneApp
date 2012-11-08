//
//  GetCachesPathForTargetFile.h
//  GiftGiv
//
//  Created by Srinivas G on 27/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

/* This class is useful to get/create a folder in the cache folder of the application */

#import <Foundation/Foundation.h>

@interface GetCachesPathForTargetFile : NSObject

//Cache path for user's profile picture
+ (NSString *)cachePathForProfilePicFileName:(NSString *)name;

//Cache path for gift item's thumbnails
+ (NSString *)cachePathForGiftItemFileName:(NSString *)name;

@end
