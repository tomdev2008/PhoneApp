//
//  SettingsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SettingsVC.h"

@implementation SettingsVC
@synthesize settinsScroll;


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
    settinsScroll.contentSize=CGSizeMake(320, 468);
    
    [(UIButton*)[settinsScroll viewWithTag:11] setUserInteractionEnabled:NO];
    [(UIButton*)[settinsScroll viewWithTag:11] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    if([[LinkedIn_GiftGiv sharedSingleton] isLinkedInAuthorized]){
        [(UIButton*)[settinsScroll viewWithTag:12] setUserInteractionEnabled:NO];
        [(UIButton*)[settinsScroll viewWithTag:12] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
}
- (IBAction)backToHomeScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    if(![[LinkedIn_GiftGiv sharedSingleton] isLinkedInAuthorized]){
         [self stopHUD];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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

- (IBAction)syncActions:(id)sender {
    
    switch ([sender tag]) {
            //facebook
        case 11:
            
            break;
            //linkedin
        case 12:
        {
            [[LinkedIn_GiftGiv sharedSingleton] logInFromView:self];
            [[LinkedIn_GiftGiv sharedSingleton] setLnkInGiftGivDelegate:self];
        }
            break;
            //logout all accounts
        case 13:
        {
            [self showProgressHUD:self.view withMsg:nil];
            if([[fb_giftgiv_settings facebook] isSessionValid]){
                if([CheckNetwork connectedToNetwork]){
                    
                    [fb_giftgiv_settings logoutOfFacebook];
                }
                else{
                    [self stopHUD];
                    AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network settings", nil);
                }
            }
            /*else{
             AlertWithMessageAndDelegate(@"GiftGiv", @"You are already logged out from facebook", nil); 
             }*/
            
            if([[LinkedIn_GiftGiv sharedSingleton] isLinkedInAuthorized]){
                
                [[LinkedIn_GiftGiv sharedSingleton] logOut];
                [[LinkedIn_GiftGiv sharedSingleton] setLnkInGiftGivDelegate:self];
                [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
                
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LinkedInAccessToken"];
                
                if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
                if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
                }
               
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"MyLinkedInDetails"];
                
            }
        }
            break;

    }
}
#pragma mark -
#pragma mark -LinkedIn
- (void)linkedInLoggedIn{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)linkedInLoggedInWithUserDetails:(NSMutableDictionary*)userDetails{
    NSLog(@"profile received.....%@",userDetails);
      
    
    [[NSUserDefaults standardUserDefaults]setObject:userDetails forKey:@"MyLinkedInDetails"];
    
    
    if([CheckNetwork connectedToNetwork]){
        //[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInAccessToken"];
        
    }
    
}

- (void)linkedInDidLoggedOut{
    if(![[fb_giftgiv_settings facebook] isSessionValid]){
        NSLog(@"linkedin logout");
        [self stopHUD];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)linkedInDidRequestFailed{
    
}
- (void)linkedInDidCancelledLogin{
    
}
#pragma mark - ProgressHUD methods

- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr  
{
	HUD = [[MBProgressHUD alloc] initWithView:targetView];
	
	// Add HUD to screen
	[targetView addSubview:HUD];
	
	// Regisete for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	HUD.labelText=titleStr;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD show:YES];
	
}
- (void)stopHUD{
    if (![HUD isHidden]) {
        [HUD setHidden:YES];
    }
}
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD=nil;
}

#pragma mark -
- (void)viewDidUnload
{
    
    [self setSettinsScroll:nil];
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
    
    [settinsScroll release];
    [super dealloc];
}

@end
