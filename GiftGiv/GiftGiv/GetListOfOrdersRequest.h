//
//  GetListOfOrdersRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderObject.h"
#import "ImageAllocationObject.h"

@class GetListOfOrdersRequest;

@protocol GetListOfOrdersDelegate

-(void) receivedListOfOrder:(NSMutableArray*)listOfOrders;
-(void) requestFailed;

@end
@interface GetListOfOrdersRequest : NSObject<NSXMLParserDelegate>
{
    OrderObject *order;
    
    NSURLConnection *theConnection;
    
	NSMutableArray *listOfOrders;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GetListOfOrdersDelegate> listOfOrdersDelegate;

//parsed the request which as parameter
-(void)getListOfOrdersRequest:(NSMutableURLRequest *)request;

@end
