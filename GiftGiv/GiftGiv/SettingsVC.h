//
//  SettingsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook_GiftGiv.h"
#import "CheckNetwork.h"
#import "ApplicationHelpers.h"
#import "LinkedIn_GiftGiv.h"
#import "MBProgressHUD.h"
#import "GetCachesPathForTargetFile.h"
#import "CoomonRequestCreationObject.h"
#import "ValidationOfTheTokenRequest.h"

@interface SettingsVC : UIViewController<Facebook_GiftGivDelegate,LinkedIn_GiftGivDelegate,MBProgressHUDDelegate,ValidationOfTheTokenRequestDelegate>
{
    Facebook_GiftGiv *fb_giftgiv_settings;
    LinkedIn_GiftGiv *lnkd_giftgiv_settings;
    MBProgressHUD *HUD;
    BOOL invalidateTokenStatusDone;
}
@property BOOL showAboutUs;
@property (retain, nonatomic) IBOutlet UIScrollView *settinsScroll;
- (IBAction)backToHomeScreen:(id)sender;
- (IBAction)syncActions:(id)sender;
- (IBAction)internalLinkActions:(id)sender;
#pragma mark - progress hud
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void)stopHUD;
#pragma mark -
@end
