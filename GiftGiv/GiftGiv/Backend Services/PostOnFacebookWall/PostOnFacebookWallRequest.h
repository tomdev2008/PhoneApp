//
//  PostOnFacebookWallRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 12/28/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PostOnFacebookWallRequest;

@protocol PostOnFacebookWallReqDelegate

-(void) responseForPosting:(NSMutableString*)responseCode;
-(void) requestFailed;

@end
@interface PostOnFacebookWallRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *postOnWallResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <PostOnFacebookWallReqDelegate> postOnFacebookReqDelegate;

//parsed the request which as parameter
-(void)makeReqToPostOnWall:(NSMutableURLRequest *)request;
@end