//
//  SendSMSRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendSMSRequest;

@protocol SendSMSReqDelegate

-(void) responseForSendSMS:(NSMutableString*)response;
-(void) requestFailed;

@end
@interface SendSMSRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *receivedResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <SendSMSReqDelegate> sendSMSDelegate;

//parsed the request which as parameter
-(void)makeReqToSendSMS:(NSMutableURLRequest *)request;

@end
