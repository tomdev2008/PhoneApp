//
//  Facebook_GiftGiv.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "ApplicationHelpers.h"

typedef enum apiCall {
    kNOAPICall,
    kAPIGetUserDetails,
    kAPIGetBirthdayEvents,
    kAPIGetAllFriends,
    kAPIGetJSONForStatuses,
} apiCall;



@protocol Facebook_GiftGivDelegate <NSObject>

@optional
- (void)facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)userDetails;
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays;

- (void)facebookDidLoggedOut;
- (void)facebookDidRequestFailed;
- (void)facebookDidCancelledLogin;
@end

@interface Facebook_GiftGiv : NSObject <FBSessionDelegate,FBRequestDelegate>
{
    Facebook *facebook;
    
    int currentAPICall;
    
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) id <Facebook_GiftGivDelegate>fbGiftGivDelegate;

+ (Facebook_GiftGiv *)sharedSingleton;
- (Facebook *)facebook;
- (void)extendAccessTokenIfNeeded;
- (void)authorizeOurAppWithFacebook;
- (void)logoutOfFacebook;
- (void)apiFQLIMe;
- (void)listOfBirthdayEvents;
- (void)getAllFriendsWithTheirDetails;

- (NSString*)getNewDateForCurrentDateByAddingTimeIntervalInDays:(int)daysToAdd;


@end
