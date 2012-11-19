//
//  Facebook_GiftGiv.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

typedef enum apiCall {
    kNOAPICall,
    kAPIGetUserDetails,
    kAPIGetBirthdayEvents,
    kAPIGetAllFriends,
    kAPIGetJSONForStatuses,
    
} apiCall;

@protocol Facebook_GiftGivDelegate <NSObject>

@optional

//facebook delegate methods

- (void)facebookLoggedIn;
- (void)facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)userDetails;
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays;

//Related to events
- (void)birthdayEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)newJobEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)anniversaryEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;
- (void)congratsEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails;

//Related to detailed event
- (void)receivedDetailedEventInfo:(NSMutableDictionary*)eventDetails;

- (void)facebookDidLoggedOut;
- (void)facebookDidRequestFailed;
- (void)facebookDidCancelledLogin;
@end

@interface Facebook_GiftGiv : NSObject
{
    //Facebook *facebook;
    
    int currentAPICall;
    
    //To have the requests
    NSMutableDictionary *friendUserIds;
    
    NSMutableArray *birthdaySearchStrings;
    NSMutableArray *anniversarySearchStrings;
    NSMutableArray *newJobSearchStrings;
    NSMutableArray *congratsSearchStrings;
    
    NSMutableArray *fbRequestsArray;
    FBRequest *getDetailedEventReq;
    FBRequest *getFriendsListReq;
    FBRequest *getFBBirthdaysReq;

    int responseCount;
}
@property (nonatomic, retain) NSMutableArray *fbRequestsArray;
@property (nonatomic, retain) FBSession *facebook;
@property (nonatomic, assign) id <Facebook_GiftGivDelegate>fbGiftGivDelegate;

- (FBSession *)facebook;
- (void)extendAccessTokenIfNeeded;
- (void)authorizeOurAppWithFacebook;
- (void)logoutOfFacebook;
- (void)apiFQLIMe;
- (void)listOfBirthdayEvents;
- (void)getAllFriendsWithTheirDetails;
- (void)getEventDetails:(NSString*)statusID;
- (NSString*)getNewDateForCurrentDateByAddingTimeIntervalInDays:(int)daysToAdd;
- (void) releaseFacebook;
- (BOOL)checkWhetherText:(NSString*)sourceText contains:(NSString*)searchedKeyword;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
@end
