//
//  GetCachesPathForTargetFile.m
//  GiftGiv
//
//  Created by Srinivas G on 27/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetCachesPathForTargetFile.h"

@implementation GetCachesPathForTargetFile


+ (NSString *)cachePathForProfilePicFileName:(NSString *)name{
    
    NSArray *cachesDirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesPath=[cachesDirList objectAtIndex:0];
   
    NSString *privateDocs = [cachesPath stringByAppendingPathComponent:@"EventProfilePictures"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    //If the directory not exists, it will create a directory (EventProfilePictures) in the caches folder

    if (![fileMgr fileExistsAtPath:privateDocs]) {
        
        NSError *error;
        [fileMgr createDirectoryAtPath:privateDocs withIntermediateDirectories:YES attributes:nil error:&error];
    
    }
    
    //If the parameter received as empty, it will return the folder (EventProfilePictures) otherwise, it will return the exact path for the file (image)
    if([name isEqualToString:@""])
        return privateDocs;
    
    return [privateDocs stringByAppendingPathComponent:name];
}
+ (NSString *)cachePathForGiftItemFileName:(NSString *)name{
    
    NSArray *cachesDirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesPath=[cachesDirList objectAtIndex:0];
    
    NSString *privateDocs = [cachesPath stringByAppendingPathComponent:@"GiftItemPictures"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    //If the directory not exists, it will create a directory (GiftItemPictures) in the caches folder
    if (![fileMgr fileExistsAtPath:privateDocs]) {
       
        NSError *error;
        [fileMgr createDirectoryAtPath:privateDocs withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    //If the parameter received as empty, it will return the folder (GiftItemPictures) otherwise, it will return the exact path for the file (image)
    
    if([name isEqualToString:@""])
        return privateDocs;
    
    return [privateDocs stringByAppendingPathComponent:name];
}
@end
