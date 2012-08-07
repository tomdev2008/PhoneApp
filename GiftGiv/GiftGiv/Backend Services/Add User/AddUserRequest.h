//
//  AddUserRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 07/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddUserRequest;

@protocol AddUserRequestDelegate

-(void) responseForAddUser:(NSMutableString*)response;
-(void) requestFailed;

@end
@interface AddUserRequest : NSObject<NSXMLParserDelegate>
{
    id <AddUserRequestDelegate> delegate;
	
	NSMutableString *receivedResponse;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <AddUserRequestDelegate> addUserDelegate;

//parsed the request which as parameter
-(void)addUserServiceRequest:(NSMutableURLRequest *)request;
@end
