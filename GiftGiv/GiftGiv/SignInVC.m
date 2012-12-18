//
//  SignInVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SignInVC.h"

@implementation SignInVC
@synthesize loginBtn,loginLbl,giftgivLogo;

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
    
    if([[UIScreen mainScreen] bounds].size.height == 568){
        loginBtn.frame=CGRectMake(loginBtn.frame.origin.x, loginBtn.frame.origin.y+25, loginBtn.frame.size.width, loginBtn.frame.size.height);
        loginLbl.frame=CGRectMake(loginLbl.frame.origin.x, loginLbl.frame.origin.y+25, loginLbl.frame.size.width, loginLbl.frame.size.height);
        giftgivLogo.frame=CGRectMake(giftgivLogo.frame.origin.x, giftgivLogo.frame.origin.y+25, giftgivLogo.frame.size.width, giftgivLogo.frame.size.height);
        _orLabel.frame=CGRectMake(_orLabel.frame.origin.x, _orLabel.frame.origin.y+25, _orLabel.frame.size.width, _orLabel.frame.size.height);
        _checkOutBtn.frame=CGRectMake(_checkOutBtn.frame.origin.x, _checkOutBtn.frame.origin.y+25, _checkOutBtn.frame.size.width, _checkOutBtn.frame.size.height);
    }
       
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
                
                NSString *urlStr=[[[listOfGifts objectAtIndex:i]objectForKey:@"GiftDetails"] giftImageUrl];
                
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                UIImage *thumbnail = [UIImage imageWithData:data];
                
                
                int GCDValue=[self getTheGCDFirstNum:thumbnail.size.width secondNum:thumbnail.size.height];
                int aspectRatioX=thumbnail.size.width/GCDValue;
                int aspectRatioY=thumbnail.size.height/GCDValue;
                
                float newWidth;
                float newHeight;
                //120-20==> such that it will give 10px white space around the thumbnail in the teal colored box
                if(thumbnail.size.width>thumbnail.size.height){
                    newWidth=120-20;
                    newHeight=((120-20)*aspectRatioY)/aspectRatioX;
                    
                }
                else if(thumbnail.size.width<thumbnail.size.height){
                    newWidth=((120-20)*aspectRatioX)/aspectRatioY;
                    newHeight=120-20;
                    
                }
                else{
                    newWidth=120-20;
                    newHeight=120-20;
                    
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

- (IBAction)showListOfGifts:(id)sender {
    GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
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
    GGLog(@"Received gift giv user...%@",[response objectForKey:@"GiftGivUser"]);
    if([response objectForKey:@"GiftGivUser"]){
        
        [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"GiftGivUser"] forKey:@"MyGiftGivUserId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftGivUserIDReceived" object:nil];
    }
   
    [self stopHUD];
    
    
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
    
    [self setGiftgivLogo:nil];
    [self setLoginLbl:nil];
    [self setLoginBtn:nil];
    [self setCheckOutBtn:nil];
    [self setOrLabel:nil];
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
    [giftgivLogo release];
    [loginLbl release];
    [loginBtn release];
    [_checkOutBtn release];
    [_orLabel release];
    [super dealloc];
}

@end
