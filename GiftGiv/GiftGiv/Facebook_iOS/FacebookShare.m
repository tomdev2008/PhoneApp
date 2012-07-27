//
//  FacebookShare.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "FacebookShare.h"
#import "Constants.h"

@interface FacebookShare()

- (void)showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;

@end



@implementation FacebookShare 

@synthesize facebook,fbShareDelegate;

static FacebookShare *sharedInstance = nil;
NSMutableDictionary *tempParams;
BOOL canReceiveDataFromFacebook;

#pragma mark FacebookShare class methods
+ (FacebookShare *)sharedSingleton
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
        
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[FacebookShare alloc] init];
        }
        canReceiveDataFromFacebook=NO;
        return sharedInstance;// FacebookShare singleton
    } 
}

- (Facebook *)facebook{
    if (!facebook) {
        facebook = [[Facebook alloc] initWithAppId:KFacebookAppId andDelegate:sharedInstance];
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
        NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
        if (fbAccessToken && fbExpirationDateKey) {
            self.facebook.accessToken = fbAccessToken;
            self.facebook.expirationDate = fbExpirationDateKey;
            //NSLog(@"AccessToken= %@ \n ExpirationDate= %@", facebook.accessToken, facebook.expirationDate);
        }
    }
    return facebook;
}
#pragma mark -
#pragma mark Login helper

-(void)authorizeOurAppToShareContentToFacebook{
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
    NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
    
    if (fbAccessToken && fbExpirationDateKey)
    {
        self.facebook.accessToken = fbAccessToken;
        self.facebook.expirationDate = fbExpirationDateKey;
    }
    
    if (![facebook isSessionValid]) {
        [self.facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"friends_status",@"friends_photos",@"friends_birthday",nil]];
        
    }
}

-(void)logoutOfFacebook{
    [[self facebook] logout];
}
-(void)extendAccessTokenIfNeeded
{
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    [[self facebook] extendAccessTokenIfNeeded];
}
#pragma mark -
#pragma mark Share helper

/*
 * Graph API: Get the user's basic information, picking the name and picture fields.
 */
- (void)apiUpdateStatus:(NSMutableDictionary *)params withRequestDelegate:(id)requestedObject{

    if (params) tempParams=params;

    if ([[self facebook] isSessionValid]) {
        
        if ([requestedObject view]){
            [self showProgressHUD:[requestedObject view] withMsg:NSLocalizedString(@"PostingToWall", @"")];
        }
        else if(HUD && [HUD superview]) {
            HUD.labelText=NSLocalizedString(@"PostingToWall", @"");
        }
        [[self facebook] requestWithGraphPath:@"me/feed"
                                    andParams:tempParams
                                andHttpMethod:@"POST"
                                  andDelegate:self];
        canReceiveDataFromFacebook=NO;
    }
    else {
        if (params){
            [self showProgressHUD:[requestedObject view] withMsg:@""];
            [[[UIAlertView alloc]initWithTitle:@"GiftGiv" message:NSLocalizedString(@"ConnectToFacebook", @"") delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
        }
    }
}

/*
 * Dialog: Feed for the user
 */
- (void)apiDialogFeedUser:(NSMutableDictionary *)params inView:(UIView*)viw
{
    if (params) tempParams=params;

    if ([[self facebook] isSessionValid]) {
        if (viw){
            [self showProgressHUD:viw withMsg:NSLocalizedString(@"PostingToWall", @"")];
        }
        else if(HUD && [HUD superview]) {
            HUD.labelText=NSLocalizedString(@"PostingToWall", @"");
        }
        
        [[self facebook] dialog:@"feed"
                      andParams:tempParams
                    andDelegate:self];
        
        canReceiveDataFromFacebook=NO;
    }
    else {
        if (params){
            [self showProgressHUD:viw withMsg:@""];
            [[[UIAlertView alloc]initWithTitle:@"GiftGiv" message:NSLocalizedString(@"ConnectToFacebook", @"") delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
        }
    }
        
}
#pragma mark -
#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self authorizeOurAppToShareContentToFacebook];
        canReceiveDataFromFacebook=YES;
    }
    else {
        [self performSelector:@selector(stopHUD)];
        canReceiveDataFromFacebook=NO;
    }
}
#pragma mark - Facebook Delegate methodes
/**
 * Called when the user successfully logged in.
 */

- (void)fbDidLogin {
    [self storeAuthData:[self.facebook accessToken] expiresAt:[self.facebook expirationDate]];
    [fbShareDelegate facebookDidLoggedIn];
    
    if (canReceiveDataFromFacebook) {
        //[self apiUpdateStatus:nil withRequestDelegate:nil];
        [self apiDialogFeedUser:nil inView:nil];
    }
}
/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
    NSLog(@"fbDidNotLogin");
    if (HUD) {
        [HUD setHidden:YES];
    }
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{
    [self storeAuthData:accessToken expiresAt:expiresAt];
}
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
/**
 * Called when the user logged out.
 */
- (void)fbDidLogout{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated{
    [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"FacebookSessionExpired", @"") message:NSLocalizedString(@"YourSessionExpired", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self fbDidLogout];
}

#pragma mark - 
#pragma mark FBRequestDelegate methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error=%@",error);
    
    //HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Crossmark.png"]];
	//HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"FailedToLoad", @"");
    
    [self performSelector:@selector(stopHUD) withObject:nil afterDelay:2.0f];
    
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"Facebook uploading completed successfully, \nresult=%@",result);
    
    //HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	//HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"Loading", @"");
    
    [self performSelector:@selector(stopHUD) withObject:nil afterDelay:2.0f];
}

#pragma mark -
#pragma mark ProgressHUD methods

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
@end
