//
//  SignInVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SignInVC.h"

@implementation SignInVC

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
- (IBAction)logInAction:(id)sender {
    
    //Check whether network connection is available to login facebook account
    
    if([CheckNetwork connectedToNetwork]){
        
        //authorize the application with facebook
        [[FacebookShare sharedSingleton]setFbShareDelegate:self];
        [[FacebookShare sharedSingleton]authorizeOurAppToShareContentToFacebook];
        
    }
    
    else{
        
        AlertWithMessageAndDelegate(@"Network Connectivity", @"Please check your network settings", nil);
        
    }
    
}

- (IBAction)termsAction:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/terms.html"]];
}
#pragma mark - Facebook login Delegate
- (void)facebookDidLoggedIn{
    
    //Once facebook logged in, will show Home/Events screen
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
    [[FacebookShare sharedSingleton]setFbShareDelegate:nil];
}

#pragma mark -
- (void)viewDidUnload
{
    
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
    
    [super dealloc];
}

@end
