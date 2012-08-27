//
//  UserDetailsObject.m
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "UserDetailsObject.h"

@implementation UserDetailsObject

@synthesize userId;
@synthesize userfbId;
@synthesize firstname;
@synthesize lastname;
@synthesize picUrl;
@synthesize userDOB;
@synthesize userEmail;

-(void)dealloc{
    [userId release];
    [userfbId release];
    [firstname release];
    [lastname release];
    [picUrl release];
    [userDOB release];
    [userEmail release];
    [super dealloc];
    
}
@end
