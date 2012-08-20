//
//  SettingsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SettingsVC.h"

@implementation SettingsVC


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
- (IBAction)backToHomeScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutFacebook:(id)sender {
    if([[[Facebook_GiftGiv sharedSingleton] facebook] isSessionValid]){
        if([CheckNetwork connectedToNetwork]){
            [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
            [[Facebook_GiftGiv sharedSingleton]logoutOfFacebook];
        }
        else{
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network settings", nil);
        }
    }
    else{
        AlertWithMessageAndDelegate(@"GiftGiv", @"You are already logged out from facebook", nil); 
    }
    
}
#pragma mark - Facebook Logout delegate
- (void)facebookDidLoggedOut{
    //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"FBAccessTokenKey"];
    [[[Facebook_GiftGiv sharedSingleton]facebook]setAccessToken:nil];
    [[Facebook_GiftGiv sharedSingleton]releaseFacebook];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark -
- (IBAction)internalLinkActions:(id)sender {
    switch ([sender tag]) {
            //mail
        case 1:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://srinivasgadda@teleparadigm.com"]];
            break;
            //phone
        case 2:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://(888)123-4567"]];
            break;
            //terms
        case 3:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/terms.html"]];
            break;
            //policy
        case 4:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/"]];
            break;
            
            
    }
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
