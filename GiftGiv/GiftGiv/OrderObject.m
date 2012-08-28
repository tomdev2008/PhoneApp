//
//  OrderObject.m
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "OrderObject.h"

@implementation OrderObject

@synthesize orderId;
@synthesize profilePictureUrl;
@synthesize recipientName;
@synthesize recipientId;
@synthesize status;
@synthesize orderUpdatedDate;
@synthesize userMessage;
@synthesize addressLine1;
@synthesize addressLine2;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize itemId;
@synthesize price;
@synthesize dateofCreation;
@synthesize phone;
@synthesize email;
@synthesize profilePicImg;

-(void)dealloc{
    [orderId release];
    [profilePictureUrl release];
    [recipientName release];
    [recipientId release];
    [status release];
    [orderUpdatedDate release];
    [userMessage release];
    [addressLine1 release];
    [addressLine2 release];
    [city release];
    [state release];
    [zip release];
    [itemId release];
    [price release];
    [dateofCreation release];
    [phone release];
    [email release];
    [profilePicImg release];
    [super dealloc];
}

@end
