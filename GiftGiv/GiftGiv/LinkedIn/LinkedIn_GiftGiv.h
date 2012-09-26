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
//- (void)receivedNetworkConnections:(NSMutableDictionary*)connections;
@end


@interface LinkedIn_GiftGiv : NSObject<RDLinkedInEngineDelegate, RDLinkedInAuthorizationControllerDelegate>{
     NSMutableArray *listOfConnections;
    int currentConnectionNum,totalConnectionsCount;
}
@property (nonatomic, assign) id <LinkedIn_GiftGivDelegate>lnkInGiftGivDelegate;

+ (LinkedIn_GiftGiv *)sharedSingleton;
- (BOOL) isLinkedInAuthorized;
- (void)logInFromView:(id)viwController;
- (void)getNetworkConnections;
- (void)logOut;
- (void)getMemberProfile:(NSString*)memberId;
@end
