//
//  SignInVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckNetwork.h"
#import "ApplicationHelpers.h"
#import "Facebook_GiftGiv.h"
#import "HomeScreenVC.h"
#import "MBProgressHUD.h"
#import "AddUserRequest.h"
#import "CoomonRequestCreationObject.h"
#import "LinkedIn_GiftGiv.h"

@interface SignInVC : UIViewController<Facebook_GiftGivDelegate,MBProgressHUDDelegate,AddUserRequestDelegate,LinkedIn_GiftGivDelegate>
{
    MBProgressHUD *HUD;
    Facebook_GiftGiv *fb_giftgiv;
    //LinkedIn_GiftGiv *lnkIn_giftgiv;
}

- (IBAction)logInAction:(id)sender;
- (IBAction)termsAction:(id)sender;

- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void)stopHUD;

@end
