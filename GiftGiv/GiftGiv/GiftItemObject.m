//
//  GiftItemObject.m
//  GiftGiv
//
//  Created by Srinivas G on 22/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftItemObject.h"

@implementation GiftItemObject

@synthesize giftId;
@synthesize giftTitle;
@synthesize giftDetails;
@synthesize giftImageUrl;
@synthesize giftImageBackSideUrl;
@synthesize giftThumbnailUrl;
@synthesize giftCategoryId;
@synthesize giftPrice;
@synthesize giftImg;
@synthesize giftImgBackSide;
@synthesize giftThumbnail;



-(void)dealloc{
    [giftId release];
    [giftTitle release];
    [giftDetails release];
    [giftImageUrl release];
    [giftImageBackSideUrl release];
    [giftThumbnailUrl release];
    [giftCategoryId release];
    [giftPrice release];
    [giftImg release];
    [giftImgBackSide release];
    [giftThumbnail release];
    
    [super dealloc];
}

@end
