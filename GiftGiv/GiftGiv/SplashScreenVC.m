//
//  SplashScreenVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SplashScreenVC.h"

@implementation SplashScreenVC
@synthesize loadingIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    //Check whether facebook session is valid or not, Based on the availability load either splash screen or Home/Events screen
    
    Facebook_GiftGiv *fb_giftgiv=[[Facebook_GiftGiv alloc]init];
    
    //NSLog(@"facebook..%@",[[fb_giftgiv facebook] isSessionValid]);
    //NSLog(@"linkedin..%@",[[LinkedIn_GiftGiv sharedSingleton]isLinkedInAuthorized]);
    
    
    
    if([[fb_giftgiv facebook] isSessionValid] || [[LinkedIn_GiftGiv sharedSingleton]isLinkedInAuthorized]){
        [self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:2.0];
    }
    else
        [self performSelector:@selector(loadSignInScreen) withObject:nil afterDelay:2.0];
    
    [fb_giftgiv release];
    
    [super viewWillAppear:YES];
}
-(void)loadHomeScreen{
    //[loadingIndicator setHidden:YES];
    
    //Load Home/Events by using Animation function EaseIn for Splash screen
	CATransition *revealTransition=[self getRevealAnimation];
	
	[self.navigationController.view.layer addAnimation:revealTransition forKey:nil];
    revealTransition=nil;
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
}
-(void)loadSignInScreen{
    //[loadingIndicator setHidden:YES];
    
    //Load signIn screen
    SignInVC *signIn=[[SignInVC alloc]initWithNibName:@"SignInVC" bundle:nil];
    [self.navigationController pushViewController:signIn animated:NO];
    [signIn release];
}
#pragma mark - Transition

-(CATransition *) getRevealAnimation{
    
    CATransition *transition = [CATransition animation];
	transition.duration = 1.0;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	transition.type = @"kCATransitionReveal";
    return transition;
    
}

#pragma mark -
- (void)viewDidUnload
{
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [loadingIndicator release];
    [super dealloc];
}
@end
