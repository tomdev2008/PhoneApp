//
//  SendThoughfulMessageEmailReq.h
//  GiftGiv
//
//  Created by Srinivas G on 12/28/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendThoughfulMessageEmailReq;

@protocol SendThoughfulMessageEmailReqDelegate

-(void) responseForSendThoughtful:(NSMutableString*)responseCode;
-(void) requestFailed;

@end
@interface SendThoughfulMessageEmailReq : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *responseStatus;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <SendThoughfulMessageEmailReqDelegate> sendThoughtfulMsgEmailReqDel;

//parsed the request which as parameter
-(void)makeReqToSendThoughtful:(NSMutableURLRequest *)request;
@end