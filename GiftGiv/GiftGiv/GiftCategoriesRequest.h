//
//  GiftCategoriesRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 22/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftCategoryObject.h"

@class GiftCategoriesRequest;

@protocol GiftCategoriesRequestDelegate

-(void) responseForGiftCategories:(NSMutableArray*)response;
-(void) requestFailed;

@end
@interface GiftCategoriesRequest : NSObject<NSXMLParserDelegate>
{
    GiftCategoryObject *giftCategory;
    NSURLConnection *theConnection;
    
	NSMutableArray *listOfGiftCategories;
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <GiftCategoriesRequestDelegate> giftCatDelegate;

//parsed the request which as parameter
-(void)makeGiftCategoriesRequest:(NSMutableURLRequest *)request;

@end
