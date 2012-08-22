//
//  GiftItemsRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 22/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftItemObject.h"

@class GiftItemsRequest;

@protocol GiftItemsRequestDelegate

-(void) responseForGiftItems:(NSMutableArray*)listOfGifts;
-(void) requestFailed;

@end
@interface GiftItemsRequest : NSObject<NSXMLParserDelegate>
{
    GiftItemObject *giftItem;
    
    NSURLConnection *theConnection;
    
	NSMutableArray *listOfGiftItems;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GiftItemsRequestDelegate> giftItemsDelegate;

//parsed the request which as parameter
-(void)makeGiftItemsRequest:(NSMutableURLRequest *)request;

@end
