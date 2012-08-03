//
//  FacebookShare.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "MBProgressHUD.h"
#import "ApplicationHelpers.h"

@protocol FacebookShareDelegate <NSObject>

@optional
- (void)facebookDidLoggedIn;
- (void)facebookDidLoggedOut;
@end

@interface FacebookShare : NSObject <FBSessionDelegate,FBRequestDelegate,FBDialogDelegate,MBProgressHUDDelegate>
{
    Facebook *facebook;
    
    MBProgressHUD *HUD;
    
    
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) id <FacebookShareDelegate>fbShareDelegate;

+ (FacebookShare *)sharedSingleton;
- (Facebook *)facebook;
- (void)extendAccessTokenIfNeeded;
- (void)authorizeOurAppToShareContentToFacebook;
- (void)logoutOfFacebook;
- (void)apiUpdateStatus:(NSMutableDictionary *)params withRequestDelegate:(id)requestedObject;
- (void)apiDialogFeedUser:(NSMutableDictionary *)params inView:(UIView*)viw;


@end
