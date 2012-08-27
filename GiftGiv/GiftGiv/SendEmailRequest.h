//
//  SendEmailRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendEmailRequest;

@protocol SendEmailRequestDelegate

-(void) responseForSendEmail:(NSMutableString*)response;
-(void) requestFailed;

@end
@interface SendEmailRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *receivedResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <SendEmailRequestDelegate> sendEmailDelegate;

//parsed the request which as parameter
-(void)makeReqToSendMail:(NSMutableURLRequest *)request;

@end
