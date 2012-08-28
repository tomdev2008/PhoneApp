//
//  GetDetailedGiftItemObject.m
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetDetailedGiftItemObject.h"

@implementation GetDetailedGiftItemObject
@synthesize giftId;
@synthesize giftTitle;
@synthesize giftDetails;
@synthesize giftImageUrl;
@synthesize giftImageBackSideUrl;
@synthesize giftThumbnailUrl;
@synthesize giftCategoryId;

-(void)dealloc{
    [giftId release];
    [giftTitle release];
    [giftDetails release];
    [giftImageUrl release];
    [giftImageBackSideUrl release];
    [giftThumbnailUrl release];
    [giftCategoryId release];
        
    [super dealloc];
}
@end
