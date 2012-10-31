//
//  FacebookContactsReq.h
//  GiftGiv
//
//  Created by Srinivas G on 12/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookContactObject.h"

@class FacebookContactsReq;

@protocol FacebookContactsReqDelegate

-(void) receivedContacts:(NSMutableArray*)response;
-(void) requestFailed;

@end
@interface FacebookContactsReq : NSObject<NSXMLParserDelegate>
{
  	FacebookContactObject *fbContact;
    NSURLConnection *theConnection;
    
	NSMutableArray *receivedResponse;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <FacebookContactsReqDelegate> fbContactsDelegate;

//parsed the request which as parameter
-(void)getFBContactsForRequest:(NSMutableURLRequest *)request;
@end
