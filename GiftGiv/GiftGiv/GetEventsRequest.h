//
//  GetEventsRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 30/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventObject.h"

@class GetEventsRequest;

@protocol GetEventsDelegate

-(void) receivedAllEvents:(NSMutableArray*)allEvents;
-(void) requestFailed;

@end
@interface GetEventsRequest : NSObject<NSXMLParserDelegate>
{
    EventObject *event;
    
    NSURLConnection *theConnection;
    
	NSMutableArray *listOfEvents;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GetEventsDelegate> eventsDelegate;

//parsed the request which as parameter
-(void)getListOfEvents:(NSMutableURLRequest *)request;

@end

