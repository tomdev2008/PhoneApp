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
    // Do any additional setup after loading the view from its nib.
    
    if([[[FacebookShare sharedSingleton] facebook] isSessionValid]){
         [self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:2.0];
    }
    else
        [self performSelector:@selector(loadSignInScreen) withObject:nil afterDelay:2.0];
}
-(void)loadHomeScreen{
    [loadingIndicator setHidden:YES];
    
    //Remove splashscreen by using Animation function EaseIn
	CATransition *revealTransition=[self getRevealAnimation];
	
	[self.navigationController.view.layer addAnimation:revealTransition forKey:nil];
    revealTransition=nil;
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
}
-(void)loadSignInScreen{
    [loadingIndicator setHidden:YES];
    
    //Remove splashscreen by using Animation function EaseIn
    /*CATransition *revealTransition=[self getRevealAnimation];
	
	[self.navigationController.view.layer addAnimation:revealTransition forKey:nil];
    revealTransition=nil;*/
    SignInVC *signIn=[[SignInVC alloc]initWithNibName:@"SignInVC" bundle:nil];
    [self.navigationController pushViewController:signIn animated:NO];
    [signIn release];
}

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
