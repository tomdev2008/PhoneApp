//
//  EventObject.m
//  GiftGiv
//
//  Created by Srinivas G on 30/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

@synthesize userId;
@synthesize fb_FriendId;
@synthesize fb_EventId;
@synthesize fb_Name;
@synthesize fb_Picture;
@synthesize eventType;
@synthesize eventName;
@synthesize eventdate;
@synthesize isEventFromQuery;


-(void)dealloc{
     [userId release];
     [fb_FriendId release];
     [fb_EventId release];
     [fb_Name release];
     [fb_Picture release];
     [eventType release];
     [eventName release];
     [eventdate release];
     [isEventFromQuery release];
    
    [super dealloc];
}
@end
