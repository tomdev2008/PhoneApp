//
//  GetDetailedGiftItemObject.h
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetDetailedGiftItemObject : NSObject
@property (retain,nonatomic)NSString *giftId;
@property (retain,nonatomic)NSString *giftTitle;
@property (retain,nonatomic)NSString *giftDetails;
@property (retain,nonatomic)NSString *giftImageUrl;
@property (retain,nonatomic)NSString *giftImageBackSideUrl;
@property (retain,nonatomic)NSString *giftThumbnailUrl;
@property (retain,nonatomic)NSString *giftCategoryId;


@end
