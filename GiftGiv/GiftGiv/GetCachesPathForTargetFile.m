//
//  GetCachesPathForTargetFile.m
//  GiftGiv
//
//  Created by Srinivas G on 27/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetCachesPathForTargetFile.h"

@implementation GetCachesPathForTargetFile

+ (NSString *)cachePathForFileName:(NSString *)name{
    NSArray *cachesDirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesPath=[cachesDirList objectAtIndex:0];
   
    NSString *privateDocs = [cachesPath stringByAppendingPathComponent:@"EventProfilePictures"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:privateDocs]) {
        //NSLog(@"Does not exist");
        NSError *error;
        [fileMgr createDirectoryAtPath:privateDocs withIntermediateDirectories:YES attributes:nil error:&error];
    
    }
    
    
    if([name isEqualToString:@""])
        return privateDocs;
    
    return [privateDocs stringByAppendingPathComponent:name];
}
@end
