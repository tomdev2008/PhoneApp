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
#import "FacebookShare.h"
#import "HomeScreenVC.h"

@interface SignInVC : UIViewController<FacebookShareDelegate>


- (IBAction)logInAction:(id)sender;
- (IBAction)termsAction:(id)sender;

@end
