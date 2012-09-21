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
    
    fb_giftgiv_settings=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_settings.fbGiftGivDelegate=self;
    
}
- (IBAction)backToHomeScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutFacebook:(id)sender {
    if([[fb_giftgiv_settings facebook] isSessionValid]){
        if([CheckNetwork connectedToNetwork]){
            
            [fb_giftgiv_settings logoutOfFacebook];
        }
        else{
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network settings", nil);
        }
    }
    /*else{
        AlertWithMessageAndDelegate(@"GiftGiv", @"You are already logged out from facebook", nil); 
    }*/
    
    else if([[LinkedIn_GiftGiv sharedSingleton] isLinkedInAuthorized]){
        [[LinkedIn_GiftGiv sharedSingleton] logOut];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
       
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LinkedInAccessToken"];
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyGiftGivUserId"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
#pragma mark - Facebook Logout delegate
- (void)facebookDidLoggedOut{
    NSLog(@"seetings facebook log out..");
    //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"FBAccessTokenKey"];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyGiftGivUserId"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark -
- (IBAction)internalLinkActions:(id)sender {
    switch ([sender tag]) {
            //mail
        case 1:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://contactemail@giftgiv.com"]];
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
    
    [[fb_giftgiv_settings facebook]setAccessToken:nil];
    [fb_giftgiv_settings releaseFacebook];
    
    fb_giftgiv_settings.fbGiftGivDelegate=nil;
    [fb_giftgiv_settings release];
    
    [super dealloc];
}

@end
