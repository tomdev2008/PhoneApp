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

@interface SettingsVC : UIViewController<Facebook_GiftGivDelegate>

- (IBAction)backToHomeScreen:(id)sender;
- (IBAction)logoutFacebook:(id)sender;
- (IBAction)internalLinkActions:(id)sender;

@end
