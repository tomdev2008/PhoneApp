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
    fb_giftgiv=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv.fbGiftGivDelegate=self;
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(makeRequestToGetGiftItems)];
    [super viewWillAppear:YES];
}
-(void)makeRequestToGetGiftItems{
    
    if([CheckNetwork connectedToNetwork]){
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetGiftItemforPhone/>"];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        GGLog(@"GiftItems..%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetGiftItemforPhone"];
        
        GiftItemsRequest *giftItems=[[GiftItemsRequest alloc]init];
        [giftItems setGiftItemsDelegate:self];
        [giftItems makeGiftItemsRequest:theRequest];
        [giftItems release];
    }
    
    
}

#pragma mark - Gift Items
-(void) responseForGiftItems:(NSMutableArray*)listOfGifts{
    int giftItemsCount=[listOfGifts count];
    
    NSFileManager *fm=[NSFileManager defaultManager];
    dispatch_queue_t ImageLoader_Q;
    
    ImageLoader_Q=dispatch_queue_create("Gift thumbnail", NULL);
    for(int i=0;i<giftItemsCount;i++){
        NSString *filePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[listOfGifts objectAtIndex:i]objectForKey:@"GiftDetails"] giftId]]];
        if(![fm fileExistsAtPath:filePath]){
            
            dispatch_async(ImageLoader_Q, ^{
                
                NSString *urlStr=[[[listOfGifts objectAtIndex:i]objectForKey:@"GiftDetails"] giftThumbnailUrl];
                
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                UIImage *thumbnail = [UIImage imageWithData:data];
                
                
                int GCDValue=[self getTheGCDFirstNum:thumbnail.size.width secondNum:thumbnail.size.height];
                int aspectRatioX=thumbnail.size.width/GCDValue;
                int aspectRatioY=thumbnail.size.height/GCDValue;
                
                float newWidth;
                float newHeight;
                //125-40==> such that it will give 20px white space around the thumbnail in the teal colored box
                if(thumbnail.size.width>thumbnail.size.height){
                    newWidth=125-40;
                    newHeight=((125-40)*aspectRatioY)/aspectRatioX;
                    
                }
                else if(thumbnail.size.width<thumbnail.size.height){
                    newWidth=((125-40)*aspectRatioX)/aspectRatioY;
                    newHeight=125-40;
                    
                }
                else{
                    newWidth=125-40;
                    newHeight=125-40;
                    
                }
                UIImage *targetImg=[thumbnail imageByScalingProportionallyToSize:CGSizeMake(newWidth, newHeight)];
                
                
                if(targetImg!=nil) {
                    NSString *filePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[listOfGifts objectAtIndex:i]objectForKey:@"GiftDetails"] giftId]]]; //Add the file name
                    [UIImagePNGRepresentation(targetImg) writeToFile:filePath atomically:YES]; //Write the file
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                    });
                }
                
            });
            
        }
        
        
    }
    dispatch_release(ImageLoader_Q);
    
}
#pragma mark - GCD
-(int)getTheGCDFirstNum:(int)width secondNum:(int)height{
    
    //Once we get the greatest value, we should divide the numerator and denominator with greatest value to get aspect ratio
    
    int greatest = 1;
    
    // determine if width or height is larger
    int smaller = ( width < height ) ? width : height;
    
    // test all numbers up to smaller to see if
    // they are divisors of both width and height
    for ( int z = 2; z <= smaller; z++ )
        if ( ( width % z == 0 ) && ( height % z == 0 ) )
            greatest = z;
    
    return greatest;
    
    
}
#pragma mark -
- (IBAction)logInAction:(id)sender {
    
    //Check whether network connection is available to login facebook account
    
    if([CheckNetwork connectedToNetwork]){
        //[self showProgressHUD:self.view withMsg:nil];
        //authorize the application with facebook
        //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
        
        //Facebook
        if([sender tag]==1)
            [fb_giftgiv authorizeOurAppWithFacebook];

        
    }
    
    else{
        
        AlertWithMessageAndDelegate(@"Network Connectivity", @"Please check your network connection", nil);
        
    }
    
}

- (IBAction)termsAction:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/terms.html"]];
}
#pragma mark - Facebook giftgiv delegates
- (void)facebookLoggedIn{
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
}
- (void)facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)userDetails{
    //Add user in the database of giftgiv server
    [[NSUserDefaults standardUserDefaults]setObject:userDetails forKey:@"MyFBDetails"];
    //pic url: https://graph.facebook.com/1061420790/picture
    
    
    //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    
    
    if([CheckNetwork connectedToNetwork]){
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *tempDate=[dateformatter dateFromString:[userDetails objectForKey:@"birthday_date"]];
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString=[dateformatter stringFromDate:tempDate];
        [dateformatter release];
        
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddGiftGivUser>\n<tem:fbId>%@</tem:fbId>\n<tem:fbAccessToken>%@</tem:fbAccessToken>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>https://graph.facebook.com/%@/picture</tem:profilePictureUrl>\n<tem:dob>%@</tem:dob>\n<tem:email></tem:email></tem:AddGiftGivUser>",[userDetails objectForKey:@"uid"],[[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"],[userDetails objectForKey:@"first_name"],[userDetails objectForKey:@"last_name"],[userDetails objectForKey:@"uid"],dateString];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        GGLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddGiftGivUser"];
        
        AddUserRequest *addUser=[[AddUserRequest alloc]init];
        [addUser setAddUserDelegate:self];
        [addUser addUserServiceRequest:theRequest];
        [addUser release];
    }
    
    
}
- (void)facebookDidRequestFailed{
    [self stopHUD];
    //AlertWithMessageAndDelegate(@"Oops", @"facebook request failed", nil);
}
- (void)facebookDidCancelledLogin{
    [self stopHUD];
    
}

#pragma mark - Add User Request delegate
-(void) responseForAddUser:(NSMutableDictionary*)response{
    //GGLog(@"add user..%@,%@",response,[[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]);
    
    if([response objectForKey:@"GiftGivUser"]){
        
        [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"GiftGivUser"] forKey:@"MyGiftGivUserId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftGivUserIDReceived" object:nil];
    }
    //GGLog(@"gift giv..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
    [self stopHUD];
    
    //Once facebook logged in, will show Home/Events screen
    /*HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
    [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];*/
    
}
-(void) requestFailed{
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has failed. Please try again later", nil);
    [self stopHUD];
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
    [fb_giftgiv release];
    [super dealloc];
}

@end
