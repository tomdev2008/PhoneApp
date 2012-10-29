//
//  AddUser_LinkedInRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 10/29/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AddUser_LinkedInRequest;

@protocol AddUser_LinkedInRequestDelegate

-(void) responseForLnAddUser:(NSMutableDictionary*)response;
-(void) requestFailed;

@end
@interface AddUser_LinkedInRequest : NSObject<NSXMLParserDelegate>
{
  	
    NSURLConnection *theConnection;
    
	NSMutableDictionary *receivedResponse;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <AddUser_LinkedInRequestDelegate> addLnUserDelegate;

//parsed the request which as parameter
-(void)addLnUserServiceRequest:(NSMutableURLRequest *)request;
@end
