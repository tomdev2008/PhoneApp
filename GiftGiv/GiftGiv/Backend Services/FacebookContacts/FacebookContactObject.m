//
//  FacebookContactObject.m
//  GiftGiv
//
//  Created by Abhishek Ganu on 12/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "FacebookContactObject.h"

@implementation FacebookContactObject
@synthesize userId,firstname,lastname,profilepicUrl,dob,location;

-(void)dealloc{
    [userId release];
    [firstname release];
    [lastname release];
    [profilepicUrl release];
    [dob release];
    [location release];
    [super dealloc];
}

@end
