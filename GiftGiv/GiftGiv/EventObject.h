//
//  EventObject.h
//  GiftGiv
//
//  Created by Srinivas G on 30/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventObject : NSObject


@property (nonatomic,retain) NSMutableString *userId;
@property (nonatomic,retain) NSMutableString *fb_FriendId;
@property (nonatomic,retain) NSMutableString *fb_EventId;
@property (nonatomic,retain) NSMutableString *fb_Name;
@property (nonatomic,retain) NSMutableString *fb_Picture;
@property (nonatomic,retain) NSMutableString *eventType;
@property (nonatomic,retain) NSMutableString *eventName;
@property (nonatomic,retain) NSMutableString *eventdate;
@property (nonatomic,retain) NSMutableString *isEventFromQuery;


@end
