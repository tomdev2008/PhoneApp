//
//  Facebook_GiftGiv.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "Facebook_GiftGiv.h"
#import "Constants.h"

@interface Facebook_GiftGiv()

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;

@end



@implementation Facebook_GiftGiv 

@synthesize facebook,fbGiftGivDelegate;

static Facebook_GiftGiv *sharedInstance = nil;

#pragma mark Facebook_GiftGiv class methods
+ (Facebook_GiftGiv *)sharedSingleton
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[Facebook_GiftGiv alloc] init];
        }
        
        return sharedInstance;// Facebook_GiftGiv singleton
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

-(void)authorizeOurAppWithFacebook{
    
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
        [self.facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"user_birthday",@"friends_status",@"friends_photos",@"friends_birthday",nil]]; //email to get user's mail address
        
        
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
#pragma mark - Facebook Delegate methodes
/**
 * Called when the user successfully logged in.
 */

- (void)fbDidLogin {
    [self storeAuthData:[self.facebook accessToken] expiresAt:[self.facebook expirationDate]];
    
    [self apiFQLIMe];
    
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
    NSLog(@"fbDidNotLogin");
    [fbGiftGivDelegate facebookDidCancelledLogin];
    
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
    //NSLog(@"%@",[defaults objectForKey:@"FBAccessTokenKey"]);
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
    [fbGiftGivDelegate facebookDidLoggedOut];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated{
    //[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"FacebookSessionExpired", @"") message:NSLocalizedString(@"YourSessionExpired", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    AlertWithMessageAndDelegate(NSLocalizedString(@"FacebookSessionExpired", @""), NSLocalizedString(@"YourSessionExpired", @""),nil);
    [self fbDidLogout];
}

#pragma mark - About User FQL

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid,first_name,last_name,birthday_date FROM user WHERE uid=me()", @"query",
                                   nil];
    currentAPICall=kAPIGetUserDetails;
    [facebook requestWithMethodName:@"fql.query"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}

#pragma mark FBRequestDelegate methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error=%@",error);
    [fbGiftGivDelegate facebookDidRequestFailed];
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    
    NSLog(@"Facebook uploading completed successfully, \nresult=%@",result);
    
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    
	switch (currentAPICall) {
        case kAPIGetUserDetails:
            [fbGiftGivDelegate facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)result];
            break;
            
    }
    
}


@end
