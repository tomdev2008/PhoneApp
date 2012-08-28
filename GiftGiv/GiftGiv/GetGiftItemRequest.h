//
//  GetGiftItemRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetDetailedGiftItemObject.h"

@class GetGiftItemRequest;

@protocol GetGiftItemDelegate

-(void) receivedGiftItem:(GetDetailedGiftItemObject*)giftDetails;
-(void) requestFailed;

@end
@interface GetGiftItemRequest : NSObject<NSXMLParserDelegate>
{
    GetDetailedGiftItemObject *giftItem;
    
    NSURLConnection *theConnection;
    
	//NSMutableArray *listOfOrders;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GetGiftItemDelegate> giftItemDelegate;

//parsed the request which as parameter
-(void)makeGiftItemRequest:(NSMutableURLRequest *)request;

@end
