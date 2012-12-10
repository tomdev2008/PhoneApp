//
//  AlertOrderEmailRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 12/10/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlertOrderEmailRequest;

@protocol AlertOrderEmailRequestDelegate

-(void) responseForAlertOrderEmail:(NSMutableString*)response;
-(void) requestFailed;

@end
@interface AlertOrderEmailRequest : NSObject<NSXMLParserDelegate>
{
    
    
    NSURLConnection *theConnection;
    
    NSMutableString *receivedResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <AlertOrderEmailRequestDelegate> alertOrderEmailDelegate;

//parsed the request which as parameter
-(void)makeReqToAlertOrderEmail:(NSMutableURLRequest *)request;

@end
