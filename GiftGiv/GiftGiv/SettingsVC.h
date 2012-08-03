//
//  SettingsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookShare.h"
#import "CheckNetwork.h"
#import "ApplicationHelpers.h"

@interface SettingsVC : UIViewController<FacebookShareDelegate>

- (IBAction)backToHomeScreen:(id)sender;
- (IBAction)logoutFacebook:(id)sender;
- (IBAction)internalLinkActions:(id)sender;

@end
