//
//  SignInVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SignInVC.h"

@implementation SignInVC
@synthesize logInBtn;

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
    [logInBtn.layer setCornerRadius:5.0];
    //[logInBtn.layer setShadowColor:[[UIColor grayColor]CGColor]];
    /*CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = logInBtn.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor],(id)[[UIColor colorWithRed:0 green:0.5 blue:1 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0 green:0.66 blue:0.66 alpha:1.0] CGColor], nil];
    [logInBtn.layer insertSublayer:gradient atIndex:0];
    [logInBtn.layer setCornerRadius:6.0];*/
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)logInAction:(id)sender {
    
    if([CheckNetwork connectedToNetwork]){
        [[FacebookShare sharedSingleton]setFbShareDelegate:self];
        [[FacebookShare sharedSingleton]authorizeOurAppToShareContentToFacebook];
    }
    else{
        AlertWithMessageAndDelegate(@"Network Connectivity", @"Please check your network settings", nil);
    }
    
}
- (void)facebookDidLoggedIn{
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
    [[FacebookShare sharedSingleton]setFbShareDelegate:nil];
}
#pragma mark -
- (void)viewDidUnload
{
    [self setLogInBtn:nil];
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
    [logInBtn release];
    [super dealloc];
}

@end
