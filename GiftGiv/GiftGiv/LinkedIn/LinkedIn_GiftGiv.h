//
//  LinkedIn_GiftGiv.h
//  GiftGiv
//

//  Created by Srinivas G on 20/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDLinkedInEngineDelegate.h"
#import "RDLinkedInAuthorizationControllerDelegate.h"

@protocol LinkedIn_GiftGivDelegate <NSObject>

@optional
- (void)linkedInLoggedIn;
- (void)linkedInLoggedInWithUserDetails:(NSMutableDictionary*)userDetails;

- (void)linkedInDidLoggedOut;
- (void)linkedInDidRequestFailed;
- (void)linkedInDidCancelledLogin;
- (void)receivedLinkedInNewEvent:(NSMutableDictionary*)result;
- (void)receivedCommentsForAnUpdate:(id)comments;
- (void)receivedLikesForAnUpdate:(int)likesCount;
@end


@interface LinkedIn_GiftGiv : NSObject<RDLinkedInEngineDelegate, RDLinkedInAuthorizationControllerDelegate>{
     NSMutableArray *networkUpdates;
    int currentConnectionNum,totalConnectionsCount;
}
@property (nonatomic, assign) id <LinkedIn_GiftGivDelegate>lnkInGiftGivDelegate;

//+ (LinkedIn_GiftGiv *)sharedSingleton;
- (BOOL) isLinkedInAuthorized;
- (void)logInFromView:(id)viwController;
- (void)getMyNetworkUpdatesWithType:(NSString*)type;
- (void)logOut;
- (void)getMemberProfile:(NSString*)memberId;
- (void)getListOfCommentsForTheUpdate:(NSString *)updateKey;
- (void)getLikesForAnUpdat:(NSString*)updateKey;
@end
