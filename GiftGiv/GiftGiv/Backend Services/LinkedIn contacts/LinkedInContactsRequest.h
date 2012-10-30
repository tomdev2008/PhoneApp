//
//  LinkedInContactsRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 10/30/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LinkedInContactsRequest;

@protocol LinkedInContactsReqDelegate

-(void) receivedLnContacts:(NSMutableArray*)response;
-(void) requestFailed;

@end
@interface LinkedInContactsRequest : NSObject<NSXMLParserDelegate>
{
  	//FacebookContactObject *lnContact;
    NSURLConnection *theConnection;
    
	NSMutableArray *receivedResponse;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <LinkedInContactsReqDelegate> lnContactsDelegate;

//parsed the request which as parameter
-(void)getLnContactsForRequest:(NSMutableURLRequest *)request;
@end

