//
//  GetCachesPathForTargetFile.h
//  GiftGiv
//
//  Created by Srinivas G on 27/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetCachesPathForTargetFile : NSObject

+ (NSString *)cachePathForFileName:(NSString *)name;
+ (NSString *)cachePathForGiftItemFileName:(NSString *)name;
@end
