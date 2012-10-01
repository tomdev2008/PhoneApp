//
//  Facebook_GiftGiv.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "Facebook.h"
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
- (void)facebookLoggedIn;
- (void)facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)userDetails;
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays;

- (void)birthdayEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)newJobEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)anniversaryEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)congratsEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)receivedDetailedEventInfo:(NSMutableDictionary*)eventDetails;

- (void)facebookDidLoggedOut;
- (void)facebookDidRequestFailed;
- (void)facebookDidCancelledLogin;
@end

@interface Facebook_GiftGiv : NSObject <FBSessionDelegate,FBRequestDelegate>
{
    Facebook *facebook;
    
    int currentAPICall;
    NSMutableDictionary *friendUserIds;
    
    NSMutableArray *birthdaySearchStrings;
    NSMutableArray *anniversarySearchStrings;
    NSMutableArray *newJobSearchStrings;
    NSMutableArray *congratsSearchStrings;
    
    NSMutableArray *fbRequestsArray;
    FBRequest *getDetailedEventReq;
    //NSOperationQueue *fbOperationQueue;
}
@property (nonatomic, retain) NSMutableArray *fbRequestsArray;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) id <Facebook_GiftGivDelegate>fbGiftGivDelegate;

//+ (Facebook_GiftGiv *)sharedSingleton;
- (Facebook *)facebook;
- (void)extendAccessTokenIfNeeded;
- (void)authorizeOurAppWithFacebook;
- (void)logoutOfFacebook;
- (void)apiFQLIMe;
- (void)listOfBirthdayEvents;
- (void)getAllFriendsWithTheirDetails;
- (void)getEventDetails:(NSString*)statusID;
- (NSString*)getNewDateForCurrentDateByAddingTimeIntervalInDays:(int)daysToAdd;
- (void) releaseFacebook;

@end
