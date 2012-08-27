//
//  AddOrderRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddOrderRequest;

@protocol AddOrderReqDelegate

-(void) responseForAddOrder:(NSMutableString*)orderCode;
-(void) requestFailed;

@end
@interface AddOrderRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *orderResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <AddOrderReqDelegate> addorderDelegate;

//parsed the request which as parameter
-(void)makeReqToAddOrder:(NSMutableURLRequest *)request;

@end


