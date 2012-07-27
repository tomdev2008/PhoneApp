//
//  SignInVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CheckNetwork.h"
#import "FacebookShare.h"
#import "HomeScreenVC.h"
#import "ApplicationHelpers.h"

@interface SignInVC : UIViewController<FacebookShareDelegate>

@property (retain, nonatomic) IBOutlet UIButton *logInBtn;

- (IBAction)logInAction:(id)sender;

@end
