//
//  AddNormalUserv_2_Request.h
//  GiftGiv
//
//  Created by Srinivas G on 12/12/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddNormalUserv_2_Request;

@protocol AddNormalUserv_2_RequestDelegate

-(void) responseForAddNormalUserv2:(NSMutableString*)userId;
-(void) requestFailed;

@end
@interface AddNormalUserv_2_Request : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *addUserResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <AddNormalUserv_2_RequestDelegate> addNormalUserDelegate;

//parsed the request which as parameter
-(void)makeReqToAddNormalUserv2:(NSMutableURLRequest *)request;

@end
