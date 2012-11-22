//
//  AppDelegate.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashScreenVC.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController;

NSString *const FBSessionStateChangedNotification =
@"thegiftgiv.com:FBSessionStateChangedNotification"; //bundle identifier should place here for facebook automatic login.

/*The bundle identifier of your project.
In your FB a/c the filed named "iOS Bundle ID:" under head Native iOS App.
The notification string value in your AppDelegate.m
NSString *const FBSessionStateChangedNotification = @"yourbundleid:FBSessionStateChangedNotification";
*/
- (void)dealloc
{
    [_window release];
    [navController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    
   
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Override point for customization after application launch.
    
    SplashScreenVC *splash=[[SplashScreenVC alloc]initWithNibName:@"SplashScreenVC" bundle:nil];
    navController=[[UINavigationController alloc]initWithRootViewController:splash];
    navController.navigationBarHidden=YES;
    navController.navigationBar.tintColor=[UIColor colorWithRed:0 green:0.67 blue:0.66 alpha:1.0];
    [splash release];
    //[self.window addSubview:navController.view];
    self.window.rootViewController=navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
        
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"IsLoadingFromFacebook"];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if([[self.navController viewControllers] count]>1)
    {
        if([[[self.navController viewControllers] objectAtIndex:1] isKindOfClass:[HomeScreenVC class]]){
            [[[self.navController viewControllers] objectAtIndex:1]viewWillAppear:YES];
        }
        else if([[self.navController viewControllers] count]>2){
            if([[[self.navController viewControllers] objectAtIndex:2] isKindOfClass:[HomeScreenVC class]]){
                [[[self.navController viewControllers] objectAtIndex:2]viewWillAppear:YES];
            }
        }
         
    }
    
    
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    /*Facebook_GiftGiv *fb_gift=[[Facebook_GiftGiv alloc]init];
    [[fb_gift facebook] extendAccessTokenIfNeeded];
    [fb_gift release];*/
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSFileManager *fm=[NSFileManager defaultManager];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"])
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    [fm removeItemAtPath:[GetCachesPathForTargetFile cachePathForProfilePicFileName:@""] error:nil];
    [fm removeItemAtPath:[GetCachesPathForTargetFile cachePathForGiftItemFileName:@""] error:nil];
    [FBSession.activeSession close];
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

@end
