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
        [self showProgressHUD:self.view withMsg:nil];
        //authorize the application with facebook
        [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
        [[Facebook_GiftGiv sharedSingleton]authorizeOurAppWithFacebook];
        
    }
    
    else{
        
        AlertWithMessageAndDelegate(@"Network Connectivity", @"Please check your network settings", nil);
        
    }
    
}

- (IBAction)termsAction:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/terms.html"]];
}
#pragma mark - Facebook giftgiv delegates
- (void)facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)userDetails{
    //Add user in the database of giftgiv server
    
    //pic url: https://graph.facebook.com/1061420790/picture
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *tempDate=[dateformatter dateFromString:[userDetails objectForKey:@"birthday_date"]];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString=[dateformatter stringFromDate:tempDate];
    [dateformatter release];
    
    NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>%@</tem:fbId>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>https://graph.facebook.com/%@/picture</tem:profilePictureUrl>\n<tem:dob>%@</tem:dob>\n<tem:email></tem:email></tem:AddUser>",[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"first_name"],[userDetails objectForKey:@"last_name"],[userDetails objectForKey:@"uid"],dateString];
    
    NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
    //NSLog(@"%@",soapRequestString);
    NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddUser"];
    
    AddUserRequest *addUser=[[AddUserRequest alloc]init];
    [addUser setAddUserDelegate:self];
    [addUser addUserServiceRequest:theRequest];
    [addUser release];
    
}
- (void)facebookDidRequestFailed{
    [self stopHUD];
    //AlertWithMessageAndDelegate(@"Oops", @"facebook request failed", nil);
}
- (void)facebookDidCancelledLogin{
    [self stopHUD];
    
}
#pragma mark - Add User Request delegate
-(void) responseForAddUser:(NSMutableString*)response{
    if([response isEqualToString:@"true"]){
        NSLog(@"User added into DB");
    }
    else if([response isEqualToString:@"false"]){
        NSLog(@"User already exists");
    }
    [self stopHUD];
    
    //Once facebook logged in, will show Home/Events screen
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    [self.navigationController pushViewController:home animated:NO];
    [home release];
    [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    
}
-(void) requestFailed{
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed", nil);
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
    
    [super dealloc];
}

@end
