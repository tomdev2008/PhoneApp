//
//  Facebook_GiftGiv.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SBJSON.h"
extern NSString *const FBSessionStateChangedNotification;
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
-(void)executePhotoMultiquery:(NSMutableArray*)jsonrequestArray;
-(void)executeStatusedMultiquery:(NSMutableArray*)jsonrequestArray;
@end

@interface Facebook_GiftGiv : NSObject
{
    //Facebook *facebook;
    
    int currentAPICall;
    
        
    NSMutableArray *birthdaySearchStrings;
    NSMutableArray *anniversarySearchStrings;
    NSMutableArray *newJobSearchStrings;
    NSMutableArray *congratsSearchStrings;
    
    NSMutableArray *fbRequestsArray;
    FBRequest *getDetailedEventReq;
    FBRequest *getFriendsListReq;
    FBRequest *getFBBirthdaysReq;

    int numberOfStatusPhotoQueriesMade,currentQueryNum;
    
}
@property (nonatomic, retain) NSMutableArray *fbRequestsArray;
@property (nonatomic, retain) FBSession *facebook;
@property (nonatomic, assign) id <Facebook_GiftGivDelegate>fbGiftGivDelegate;

- (FBSession *)facebook;
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
//Get last day for the month
- (int)getLastDayOfMonth:(NSString *)dateStr;

-(void) makeQueryToGetListOfBirthdaysWithStartDate:(NSString* )startDate andEndDate:(NSString*)endDate;
//- (void)postStatusMessage;
@end
