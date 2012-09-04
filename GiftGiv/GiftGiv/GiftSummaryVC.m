//
//  GiftSummaryVC.m
//  GiftGiv
//
//  Created by Srinivas G on 01/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftSummaryVC.h"

#define RETURN_URL @"http://ReturnURL"
#define CANCEL_URL @"http://CancelURL"

@implementation GiftSummaryVC
@synthesize giftSummaryScroll;
@synthesize profilePic;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize giftImg;
@synthesize giftNameLbl;
@synthesize giftPriceLbl;
@synthesize addressLbl;
@synthesize mailGiftToLbl;
@synthesize personalMsgLbl;
@synthesize recipientAddressHeadLbl;
@synthesize paymentBtnLbl;
@synthesize paymentBtn;
@synthesize disclosureLbl;
@synthesize giftSummaryDict;
@synthesize msgHeadLbl;


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
    
    giftSummaryScroll.frame=CGRectMake(0, 44, 320, 416);
    [self.view addSubview:giftSummaryScroll];
    
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
    
    profileNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"];
    
    
    [self loadImage:FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]) forAnObject:profilePic];
    
    [self loadImage:[giftSummaryDict objectForKey:@"GiftImgUrl"] forAnObject:giftImg];
    
    
   
    
    profileNameLbl.text=[giftSummaryDict objectForKey:@"RecipientName"];
    eventNameLbl.text=[giftSummaryDict objectForKey:@"EventName"];
    
    personalMsgLbl.text=[giftSummaryDict objectForKey:@"PersonalMessage"];
    if([giftSummaryDict objectForKey:@"RecipientAddress"]){
        addressLbl.text=[giftSummaryDict objectForKey:@"RecipientAddress"];
        mailGiftToLbl.text=@"Mail Gift to:";
    }
    else if([giftSummaryDict objectForKey:@"RecipientPhoneNum"]){
        addressLbl.text=[giftSummaryDict objectForKey:@"RecipientPhoneNum"];
        mailGiftToLbl.text=@"Address request sent to:";
    }
    else if([giftSummaryDict objectForKey:@"RecipientMailID"]){
        addressLbl.text=[giftSummaryDict objectForKey:@"RecipientMailID"];
        mailGiftToLbl.text=@"Address request sent to:";
    }
    
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(57, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    if(personalMsgLbl.text==nil || [personalMsgLbl.text isEqualToString:@""]){
        msgHeadLbl.hidden=YES;
        
    }
    else
        msgHeadLbl.hidden=NO;
    
    
    
    
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [personalMsgLbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    personalMsgLbl.frame=CGRectMake(personalMsgLbl.frame.origin.x, personalMsgLbl.frame.origin.y, 280.0, labelSize.height);
    
    recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, personalMsgLbl.frame.origin.y+personalMsgLbl.frame.size.height+5, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    disclosureLbl.frame=CGRectMake(disclosureLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, disclosureLbl.frame.size.width, disclosureLbl.frame.size.height);
    
    paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+17, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
    paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+10, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    
    giftSummaryScroll.contentSize=CGSizeMake(320, paymentBtn.frame.origin.y+paymentBtn.frame.size.height+10);
    
}

-(void)loadImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    NSLog(@"%@",imgURL);
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
        UIImage *giftImage = [UIImage imageWithData:data];
        
        if(giftImage==nil){
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                if([targetImgView isEqual:profilePic])
                    profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                
            });
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                if(![targetImgView isEqual:profilePic])
                {
                    if(giftImage.size.width<125 || giftImage.size.height<125){
                        targetImgView.frame= CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y+(giftImage.size.height)/4, giftImage.size.width, giftImage.size.height);
                        targetImgView.image=giftImage;
                    }
                    else{
                       UIImage *targetedImage= [giftImage imageByScalingProportionallyToSize:CGSizeMake(125, 125)];
                        targetImgView.frame=CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y, targetedImage.size.width, targetedImage.size.height);
                        targetImgView.image=targetedImage;
                        
                        [self performSelector:@selector(reloadGiftDetails)];
                        
                       
                    }
                }
                else
                    targetImgView.image=giftImage;
                
                              
                
                                 
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
-(void)reloadGiftDetails{
    giftNameLbl.text=[giftSummaryDict objectForKey:@"GiftName"];
    giftPriceLbl.text=[giftSummaryDict objectForKey:@"GiftPrice"];
    
    giftNameLbl.frame=CGRectMake(giftNameLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2-21, giftNameLbl.frame.size.width, giftNameLbl.frame.size.height);
    giftPriceLbl.frame=CGRectMake(giftPriceLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2, giftPriceLbl.frame.size.width, giftPriceLbl.frame.size.height);
    
    if(msgHeadLbl.hidden){
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    else{
        msgHeadLbl.frame=CGRectMake(msgHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, msgHeadLbl.frame.size.width, msgHeadLbl.frame.size.height);
         personalMsgLbl.frame=CGRectMake(personalMsgLbl.frame.origin.x, msgHeadLbl.frame.origin.y+msgHeadLbl.frame.size.height+2, personalMsgLbl.frame.size.width, personalMsgLbl.frame.size.height);
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, personalMsgLbl.frame.origin.y+personalMsgLbl.frame.size.height+5, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
        
    
    
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    disclosureLbl.frame=CGRectMake(disclosureLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, disclosureLbl.frame.size.width, disclosureLbl.frame.size.height);
    
    
    if(disclosureLbl.frame.size.height+disclosureLbl.frame.origin.y>=376){
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+17, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+10, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    else{
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, 381, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, 374, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    
    
    giftSummaryScroll.contentSize=CGSizeMake(320, paymentBtn.frame.origin.y+paymentBtn.frame.size.height+10);
    
    
    
    
}
- (IBAction)backToRecipientForm:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark DeviceReferenceTokenDelegate methods

//This method is called when a device reference token has been successfully fetched.
- (void)receivedDeviceReferenceToken:(NSString *)token {
	//store the token for later use
	[ECNetworkHandler sharedInstance].deviceReferenceToken = token;
	
	//carry on to the review page
	//[self reviewOrder:nil];
    
    [self performSelector:@selector(paymentActionCalledWhenDeviceInitailized)];
}

//This method is called when a device reference token could not be fetched.
- (void)couldNotFetchDeviceReferenceToken {
	//optionally check the errorMessage property to see what the problem was
	NSLog(@"DEVICE REFERENCE TOKEN ERROR: %@", [PayPal getPayPalInst].errorMessage);
	
	//clear any previously-stored token
	[ECNetworkHandler sharedInstance].deviceReferenceToken = @"";
	
    
    [self performSelector:@selector(paymentActionCalledWhenDeviceInitailized)];
}
- (IBAction)paymentBtnAction:(id)sender {
    
    [self showProgressHUD:self.view withMsg:nil];
    [[PayPal getPayPalInst] fetchDeviceReferenceTokenWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX withDelegate:self];
    
    
}
-(void)paymentActionCalledWhenDeviceInitailized{
    //In this example, we do the Express Checkout calls completely on the device.  This is not recommended because
	//it requires the merchant API credentials to be stored in the app on the device, and this is a security risk.
	[ECNetworkHandler sharedInstance].username = MERCHANT_USERNAME;
	[ECNetworkHandler sharedInstance].password = MERCHANT_PASSWORD;
	[ECNetworkHandler sharedInstance].signature = MERCHANT_SIGNATURE;
	[ECNetworkHandler sharedInstance].userAction = ECUSERACTION_COMMIT; //user completes payment on paypal site
	
	SetExpressCheckoutRequestDetails *sreq = [[[SetExpressCheckoutRequestDetails alloc] init] autorelease];
	PaymentDetails *paymentDetails = [[[PaymentDetails alloc] init] autorelease];
	[sreq addPaymentDetails:paymentDetails];
    sreq.NoShipping = DO_NOT_DISPLAY_SHIPPING;
	
	sreq.ReturnURL = RETURN_URL;
	sreq.CancelURL = CANCEL_URL;
    
    paymentDetails.OrderTotal = [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
	
    PaymentDetailsItem *paymentDetailsItem = [[[PaymentDetailsItem alloc] init] autorelease];
    paymentDetailsItem.Name = [giftSummaryDict objectForKey:@"GiftName"];
    paymentDetailsItem.Amount = [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    [paymentDetails addPaymentDetailsItem:paymentDetailsItem];
	
	//Call setExpressCheckout.  The response will be handled below in the expressCheckoutResponseReceived: method.
	[[ECNetworkHandler sharedInstance] setExpressCheckoutWithRequest:sreq withDelegate:self];
}
- (void)expressCheckoutResponseReceived:(NSObject *)response {
	if ([response isKindOfClass:[NSError class]]) {
        //If we get back an error, display an alert.
        AlertWithMessageAndDelegate(@"Payment failed", [(NSError *)response localizedDescription], nil);
		
		
	} else if ([response isKindOfClass:[NSString class]]) { //got back token
		//The response from setExpressCheckout is an Express Checkout token.  The ECNetworkHandler class stores
		//this token for us, so we do not have to pass it back in.  Redirect to PayPal's login page.
		[self.navigationController pushViewController:[[[WebViewController alloc] initWithURL:[ECNetworkHandler sharedInstance].redirectURL returnURL:RETURN_URL cancelURL:CANCEL_URL giftItem:giftSummaryDict]autorelease] animated:TRUE];
	}
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
    [self setGiftSummaryScroll:nil];
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftImg:nil];
    [self setGiftNameLbl:nil];
    [self setGiftPriceLbl:nil];
    [self setPersonalMsgLbl:nil];
    [self setRecipientAddressHeadLbl:nil];
    [self setMailGiftToLbl:nil];
    [self setAddressLbl:nil];
    [self setDisclosureLbl:nil];
    [self setPaymentBtn:nil];
    [self setPaymentBtnLbl:nil];
    [self setMsgHeadLbl:nil];
    
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
    [giftSummaryScroll release];
    [profilePic release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftImg release];
    [giftNameLbl release];
    [giftPriceLbl release];
    [personalMsgLbl release];
    [recipientAddressHeadLbl release];
    [mailGiftToLbl release];
    [addressLbl release];
    [disclosureLbl release];
    [paymentBtn release];
    [paymentBtnLbl release];
    [giftSummaryDict release];
    
    [msgHeadLbl release];
    [super dealloc];
}
@end
