//
//  SplashScreenVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HomeScreenVC.h"
#import "SignInVC.h"
#import "Facebook_GiftGiv.h"

@interface SplashScreenVC : UIViewController

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

// get the animation to reveal the screen
-(CATransition *) getRevealAnimation;

@end
