//
//  GetUserRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDetailsObject.h"

@class GetUserRequest;

@protocol GetUserReqDelegate

-(void) responseForGetuser:(UserDetailsObject*)userdetails;
-(void) requestFailed;

@end
@interface GetUserRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    UserDetailsObject *user;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GetUserReqDelegate> getuserDelegate;

//parsed the request which as parameter
-(void)makeRequestToGetUserId:(NSMutableURLRequest *)request;

@end
