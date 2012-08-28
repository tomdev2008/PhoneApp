//
//  OrderObject.h
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderObject : NSObject

@property (retain,nonatomic) NSMutableString *orderId;
@property (retain,nonatomic) NSMutableString *profilePictureUrl;
@property (retain,nonatomic) NSMutableString *recipientName;
@property (retain,nonatomic) NSMutableString *recipientId;
@property (retain,nonatomic) NSMutableString *status;
@property (retain,nonatomic) NSMutableString *orderUpdatedDate;
@property (retain,nonatomic) NSMutableString *userMessage;
@property (retain,nonatomic) NSMutableString *addressLine1;
@property (retain,nonatomic) NSMutableString *addressLine2;
@property (retain,nonatomic) NSMutableString *city;
@property (retain,nonatomic) NSMutableString *state;
@property (retain,nonatomic) NSMutableString *zip;
@property (retain,nonatomic) NSMutableString *itemId;
@property (retain,nonatomic) NSMutableString *price;
@property (retain,nonatomic) NSMutableString *dateofCreation;
@property (retain,nonatomic) NSMutableString *phone;
@property (retain,nonatomic) NSMutableString *email;
@property (retain,nonatomic) UIImage *profilePicImg;
@end
