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
#import "GetCachesPathForTargetFile.h"
#import "GiftItemsRequest.h"
#import "GiftOptionsVC.h"
#import "UIImage+ProportionalFill.h"

@interface SignInVC : UIViewController<Facebook_GiftGivDelegate,MBProgressHUDDelegate,AddUserRequestDelegate,GiftItemsRequestDelegate>
{
    MBProgressHUD *HUD;
    Facebook_GiftGiv *fb_giftgiv;
}
@property (retain, nonatomic) IBOutlet UILabel *orLabel;
@property (retain, nonatomic) IBOutlet UIButton *checkOutBtn;
@property (retain, nonatomic) IBOutlet UIButton *loginBtn;
@property (retain, nonatomic) IBOutlet UILabel *loginLbl;
@property (retain, nonatomic) IBOutlet UIImageView *giftgivLogo;

- (IBAction)logInAction:(id)sender;
- (IBAction)termsAction:(id)sender;
- (IBAction)showListOfGifts:(id)sender;

- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void)stopHUD;

@end
