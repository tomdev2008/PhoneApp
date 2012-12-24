//
//  Gift_GreetingCardDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "Gift_GreetingCardDetailsVC.h"

@implementation Gift_GreetingCardDetailsVC
@synthesize detailsBgView;
@synthesize giftDetailsContentScroll;
@synthesize profilePic;
@synthesize profileNameLbl;
@synthesize innerViewForGreetDetails;
@synthesize giftDetailsLbl;
@synthesize backGreetingImg;
@synthesize dodBgView;
@synthesize dodPicker;
@synthesize eventNameLbl;
@synthesize frontGreetingImg;
@synthesize frontLbl;
@synthesize backLbl;
@synthesize greetingNameLbl;
@synthesize flowerImgView;
@synthesize greetingPrice;
@synthesize msgInputAccessoryView;
@synthesize personalMsgTxt;
@synthesize isGreetingCard;
@synthesize giftItemInfo;
@synthesize dateLabel;
@synthesize shippingCostLbl;
@synthesize zoomDoneBtn;
@synthesize giftTitleInZoomScreen;


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
    fb_giftgiv_detailsScreen=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_detailsScreen.fbGiftGivDelegate=self;
    if(isGreetingCard){
        flowerImgView.hidden=YES;
        frontLbl.hidden=NO;
        backLbl.hidden=NO;
        frontGreetingImg.hidden=NO;
        backGreetingImg.hidden=NO;
        [self loadGiftImage:[[giftItemInfo objectForKey:@"GiftItem"] giftImageUrl] forAnObject:frontGreetingImg];
        [self loadGiftImage:[[giftItemInfo objectForKey:@"GiftItem"] giftImageBackSideUrl] forAnObject:backGreetingImg];
        detailsBgView.frame=CGRectMake(0, 589, 320, 300);
        
    }
    else{
        frontLbl.hidden=YES;
        backLbl.hidden=YES;
        frontGreetingImg.hidden=YES;
        backGreetingImg.hidden=YES;
        flowerImgView.hidden=NO;
        [self loadGiftImage:[[giftItemInfo objectForKey:@"GiftItem"] giftImageUrl] forAnObject:flowerImgView];
        detailsBgView.frame=CGRectMake(0, 355, 320, 300);
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
        
        
        profileNameLbl.text=[[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] uppercaseString];
        
        NSString *profilePicId;
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"]){
            profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"];
        }
        else{
            profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"];
        }
        
        NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",profilePicId]];
        NSFileManager *fm=[NSFileManager defaultManager];
        if([fm fileExistsAtPath:filePath]){
            profilePic.image=[UIImage imageWithContentsOfFile:filePath];
        }
        else{
            profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
        }
    }
     // If there is no event selected, we should not show the header part, and make sure to occupy the entire screen with the rest of UI elements
    else{
        
        if(!frontGreetingImg.hidden){
            frontGreetingImg.frame=CGRectMake(frontGreetingImg.frame.origin.x, frontGreetingImg.frame.origin.y-47, frontGreetingImg.frame.size.width, frontGreetingImg.frame.size.height);
            frontLbl.frame=CGRectMake(frontLbl.frame.origin.x, frontLbl.frame.origin.y-47, frontLbl.frame.size.width, frontLbl.frame.size.height);
            
        }
        if(!backGreetingImg.hidden){
            backGreetingImg.frame=CGRectMake(backGreetingImg.frame.origin.x, backGreetingImg.frame.origin.y-47, backGreetingImg.frame.size.width, frontGreetingImg.frame.size.height);
            backLbl.frame=CGRectMake(backLbl.frame.origin.x, backLbl.frame.origin.y-47, backLbl.frame.size.width, backLbl.frame.size.height);
        }
        if(!flowerImgView.hidden){
            flowerImgView.frame=CGRectMake(flowerImgView.frame.origin.x, flowerImgView.frame.origin.y-47, flowerImgView.frame.size.width, flowerImgView.frame.size.height);
            backLbl.frame=CGRectMake(backLbl.frame.origin.x, backLbl.frame.origin.y-47, backLbl.frame.size.width, backLbl.frame.size.height);
        }
            
        
        detailsBgView.frame=CGRectMake(detailsBgView.frame.origin.x, detailsBgView.frame.origin.y-47, detailsBgView.frame.size.width, detailsBgView.frame.size.height);
    }
    
    
    UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomInOutForCards:)];
    tapRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    greetingNameLbl.text=[[giftItemInfo objectForKey:@"GiftItem"] giftTitle];
    if(![[[giftItemInfo objectForKey:@"GiftItem"] giftPrice] isEqualToString:@""]){
        greetingPrice.text=[NSString stringWithFormat:@"$%@",[[giftItemInfo objectForKey:@"GiftItem"] giftPrice]];
        shippingCostLbl.text=@"(shipping costs and sales tax, if applicable, included)";
    }
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize giftPriceLbl_maxsize = CGSizeMake(greetingPrice.frame.size.width, greetingPrice.frame.size.height);
    CGSize giftPriceLbl_new_size=[greetingPrice.text sizeWithFont:greetingPrice.font constrainedToSize:giftPriceLbl_maxsize lineBreakMode:UILineBreakModeTailTruncation];
    greetingPrice.frame=CGRectMake(greetingPrice.frame.origin.x, greetingPrice.frame.origin.y, giftPriceLbl_new_size.width, greetingPrice.frame.size.height);
    
    
    shippingCostLbl.frame= CGRectMake(greetingPrice.frame.origin.x+3+greetingPrice.frame.size.width, shippingCostLbl.frame.origin.y, shippingCostLbl.frame.size.width, shippingCostLbl.frame.size.height);
   
   
    giftDetailsContentScroll.frame=CGRectMake(0, 44, 320,416);
      
    [self.view addSubview:giftDetailsContentScroll];
    
    UIFont *detailsTextFont = [UIFont fontWithName:@"Helvetica" size:11.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSMutableAttributedString *giftDescription=[NSMutableAttributedString attributedStringWithString:[[giftItemInfo objectForKey:@"GiftItem"] giftDetails]];
    [giftDescription setTextAlignment:kCTTextAlignmentJustified lineBreakMode:kCTLineBreakByWordWrapping];
    CGSize labelSize = [[giftDescription string] sizeWithFont:detailsTextFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect targetFrame=CGRectMake(20, shippingCostLbl.frame.origin.y+shippingCostLbl.frame.size.height, labelSize.width, labelSize.height);
    
    if([[giftDescription string] length]){
        targetFrame.origin.y+=10;
        targetFrame.size.height+=20;
    }
    giftDetailsLbl.frame=targetFrame;
      
    //giftDetailsLbl.textAlignment=UITextAlignmentJustify;
    giftDetailsLbl.attributedText=giftDescription;//[giftDescription string];
        
    innerViewForGreetDetails.frame=CGRectMake(0, giftDetailsLbl.frame.origin.y+giftDetailsLbl.frame.size.height+5, 320, 234);
    CGRect detailsBgFrame=detailsBgView.frame;
    detailsBgFrame.size.height=innerViewForGreetDetails.frame.origin.y+innerViewForGreetDetails.frame.size.height;
    detailsBgView.frame=detailsBgFrame;
    [giftDetailsContentScroll setContentSize:CGSizeMake(320, detailsBgView.frame.origin.y+detailsBgView.frame.size.height)];
        
    /*if(isGreetingCard)
        [giftDetailsContentScroll setContentSize:CGSizeMake(320, 889)];
    else
        [giftDetailsContentScroll setContentSize:CGSizeMake(320, 655)];*/
    personalMsgTxt.inputAccessoryView=msgInputAccessoryView;
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    if([giftItemInfo objectForKey:@"PersonalMessage"]){
        personalMsgTxt.text=[giftItemInfo objectForKey:@"PersonalMessage"];
    }
    [personalMsgTxt.layer setCornerRadius:6.0];
    [personalMsgTxt.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [personalMsgTxt.layer setBorderWidth:1.0];
    
    [dateLabel.layer setCornerRadius:6.0];
    [dateLabel.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [dateLabel.layer setBorderWidth:1.0];
    
    
    monthsArray=[[NSMutableArray alloc]init];
    daysArray=[[NSMutableArray alloc]init];
   
   
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    int month=[components month];
    int day=[components day];
    
    for(int i=0;i<12;i++){
        if(month>12)
            month=1;
        [monthsArray addObject:[NSString stringWithFormat:@"%d",month]];
        month++;
    }
    for(int i=0;i<31;i++){
        if(day>31)
            day=1;
        [daysArray addObject:[NSString stringWithFormat:@"%d",day]];
        day++;
    }
    if([giftItemInfo objectForKey:@"DateOfDelivery"]){
        
        NSArray *dateArrayComponents=[[giftItemInfo objectForKey:@"DateOfDelivery"] componentsSeparatedByString:@"-"];
        if([components day]==[[dateArrayComponents objectAtIndex:2] integerValue] && [components month]==[[dateArrayComponents objectAtIndex:1] integerValue]){
            dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];
        }
        else
            dateLabel.text=[NSString stringWithFormat:@"   %@ %@",[self getMonthName:[[dateArrayComponents objectAtIndex:1]intValue]],[dateArrayComponents objectAtIndex:2]];
        
        [daysArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isEqualToString:[dateArrayComponents objectAtIndex:2]]){
                [dodPicker selectRow:idx inComponent:1 animated:NO];
            }
        }];
        [monthsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isEqualToString:[dateArrayComponents objectAtIndex:1]]){
                [dodPicker selectRow:idx inComponent:0 animated:NO];
            }
        }];
    }
    else
        dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];

    giftTitleInZoomScreen.text=[[giftItemInfo objectForKey:@"GiftItem"] giftTitle];
    
    [zoomDoneBtn.layer setBorderColor:[[UIColor blackColor]CGColor]];
    [zoomDoneBtn.layer setBorderWidth:1.0];
    [zoomDoneBtn.layer setCornerRadius:5.0];

}
-(NSString *)getMonthName:(int)monthNum{
    switch (monthNum) {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
    }
    return nil;
}
-(void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    
    __block NSString *tempImageURL=imgURL;
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        if([targetImgView isEqual:profilePic]){
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"]){
                tempImageURL=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"];
            }
            else
                tempImageURL=FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]);
        }
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempImageURL]];
        UIImage *giftImg = [UIImage imageWithData:data];
        
        if(giftImg==nil){
            if([targetImgView isEqual:profilePic]){
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                    
                });
            }
            
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                targetImgView.image=giftImg;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}

-(void)zoomInOutForCards:(UITapGestureRecognizer*)tapRecog{
    
    CGPoint tapLocation=[tapRecog locationInView:giftDetailsContentScroll];
     
    //zoom out
    if(zoomScrollView!=nil && [zoomScrollView superview]){
        if(CGRectContainsPoint(zoomScrollView.frame, tapLocation)){
            
            [zoomScrollView fullZoomToPoint:tapRecog];
            if(zoomDoneBtn.hidden){
                zoomDoneBtn.hidden=NO;
                giftTitleInZoomScreen.hidden=NO;
            }
            else{
                zoomDoneBtn.hidden=YES;
                giftTitleInZoomScreen.hidden=YES;
            }
            return;
        }
        
    }
    else{
        if(flowerImgView.hidden){
            if(CGRectContainsPoint(backGreetingImg.frame, tapLocation)){
                zoomScrollView=[[GfitZoomInView alloc]initWithFrame:[self.view bounds]];
                
                zoomScrollView.theContainerView.image=backGreetingImg.image;
               
                zoomScrollView.message=self;
                [self.view addSubview:zoomScrollView];
                
                zoomDoneBtn.frame=CGRectMake(240, 10, 70, 31);
                [self.view addSubview:zoomDoneBtn];
                
                if([[UIScreen mainScreen] bounds].size.height == 568){
                    giftTitleInZoomScreen.frame=CGRectMake(10, 480, 300, 41);
                }
                else
                    giftTitleInZoomScreen.frame=CGRectMake(10, 420, 300, 41);
                
                
                [self.view addSubview:giftTitleInZoomScreen];
                
                /*zoomDoneBtn.hidden=YES;
                zoomScrollView.hidden=YES;
                giftTitleInZoomScreen.hidden=YES;*/
                
                //[self animateZoominView:backGreetingImg shouldShow:YES];
            } 
            if(CGRectContainsPoint(frontGreetingImg.frame, tapLocation)){
                zoomScrollView=[[GfitZoomInView alloc]initWithFrame:[self.view bounds]];
                
                zoomScrollView.theContainerView.image=frontGreetingImg.image;
               
                zoomScrollView.message=self;
                [self.view addSubview:zoomScrollView];
                
                zoomDoneBtn.frame=CGRectMake(240, 30, 70, 31);
                [self.view addSubview:zoomDoneBtn];
                
                if([[UIScreen mainScreen] bounds].size.height == 568){
                    giftTitleInZoomScreen.frame=CGRectMake(10, 480, 300, 41);
                }
                else
                    giftTitleInZoomScreen.frame=CGRectMake(10, 420, 300, 41);
                
                //giftTitleInZoomScreen.frame=CGRectMake(10, 400, 300, 41);
                [self.view addSubview:giftTitleInZoomScreen];
                
                /*zoomDoneBtn.hidden=YES;
                //zoomScrollView.hidden=YES;
                giftTitleInZoomScreen.hidden=YES;
                */
            }
        }
        else{
            if(CGRectContainsPoint(flowerImgView.frame, tapLocation)){
                
                
                zoomScrollView=[[GfitZoomInView alloc]initWithFrame:[self.view bounds]];
                
                zoomScrollView.theContainerView.image=flowerImgView.image;
                
                zoomScrollView.message=self;
                [self.view addSubview:zoomScrollView];
                
                zoomDoneBtn.frame=CGRectMake(240, 30, 70, 31);
                [self.view addSubview:zoomDoneBtn];
                if([[UIScreen mainScreen] bounds].size.height == 568){
                    giftTitleInZoomScreen.frame=CGRectMake(10, 480, 300, 41);
                }
                else
                    giftTitleInZoomScreen.frame=CGRectMake(10, 420, 300, 41);
                //giftTitleInZoomScreen.frame=CGRectMake(10, 400, 300, 41);
                [self.view addSubview:giftTitleInZoomScreen];
               
                /*zoomDoneBtn.hidden=YES;
                //zoomScrollView.hidden=YES;
                giftTitleInZoomScreen.hidden=YES;*/
                
            } 
        }
        
    }
    
}
- (IBAction)sendOptionsScreenAction:(id)sender {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    int month=[components month];
    int year=[components year];
    
    
    int selectedMonth=[[monthsArray objectAtIndex:[dodPicker selectedRowInComponent:0]] intValue];
    int selectedDay=[[daysArray objectAtIndex:[dodPicker selectedRowInComponent:1]] intValue];
    if(selectedMonth<month)
        year++;
           
    [giftItemInfo setObject:[personalMsgTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
    [giftItemInfo setObject:[NSString stringWithFormat:@"%d-%d-%d",year,selectedMonth,selectedDay] forKey:@"DateOfDelivery"];
    
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        
        
        SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
        sendOptions.isSendElectronically=NO;
        NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
        [giftAndSenderInfo setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] forKey:@"RecipientName"];
        [giftAndSenderInfo setObject:eventNameLbl.text forKey:@"EventName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftId] forKey:@"GiftID"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftTitle] forKey:@"GiftName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftImageUrl] forKey:@"GiftImgUrl"];
        
        [giftAndSenderInfo setObject:greetingPrice.text forKey:@"GiftPrice"];
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"PersonalMessage"] forKey:@"PersonalMessage"];
        
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"DateOfDelivery"] forKey:@"DateOfDelivery"];
        
        sendOptions.sendingInfoDict=giftAndSenderInfo;
        [giftAndSenderInfo release];
        [self.navigationController pushViewController:sendOptions animated:YES];
        [sendOptions release];
    }
    //Show facebook login alert if the user is not yet logged in.
    else{
        
        NSString *fbAccessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
        NSDate *fbExpirationDateKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBExpirationDateKey"];
        
        //Load HomeScreen to show the list of events
        if ((fbAccessToken!=nil && [fbAccessToken length]) && (fbExpirationDateKey!=nil)) {
            Facebook_GiftGiv *fb_giftgiv=[[Facebook_GiftGiv alloc]init];
            [fb_giftgiv authorizeOurAppWithFacebook];
            
            [fb_giftgiv release];
            
            HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
            home.giftDetailsWhichWasSelected=giftItemInfo;
            [self.navigationController pushViewController:home animated:NO];
            [home release];
            
        }
        //Show an alert
        else{
            AlertWithMessageAndDelegateActionHandling(@"GiftGiv", @"Please login facebook to select an event of your loved ones", [NSArray arrayWithObjects:@"Cancel",@"Login", nil], self);
        }
        
        
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==1){
        
        [fb_giftgiv_detailsScreen authorizeOurAppWithFacebook];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    //giftDetailsContentScroll.userInteractionEnabled=NO;
    
    svos = giftDetailsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textView bounds];
	rc = [textView convertRect:rc toView:giftDetailsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[giftDetailsContentScroll setContentOffset:pt animated:YES];
}
- (IBAction)msgKeyboardDismissAction:(id)sender {
    [personalMsgTxt resignFirstResponder];
    [giftDetailsContentScroll setContentOffset:svos animated:YES];
    giftDetailsContentScroll.userInteractionEnabled=YES;
}

- (IBAction)backToListOfGiftsAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) viewWillDisappear:(BOOL)animated{
    if([dodBgView superview])
        [dodBgView removeFromSuperview];
}
#pragma mark -
- (IBAction)showDatePicker:(id)sender{
    for(UIView *subview in [giftDetailsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    //giftDetailsContentScroll.userInteractionEnabled=NO;
    svos = giftDetailsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [dateLabel bounds];
	rc = [dateLabel convertRect:rc toView:giftDetailsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=45;
	[giftDetailsContentScroll setContentOffset:pt animated:YES];
    if(dodBgView.hidden)
        dodBgView.hidden=NO;
    if(![dodBgView superview]){
        CGRect origFrame=dodBgView.frame;//CGRectMake(0, 220, 320, 260);
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        dodBgView.frame=origFrame;
        [self.view.window addSubview:dodBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [dodBgView.layer addAnimation:animation forKey:@"animation"];
    
    
}
#pragma mark -
- (void)viewDidUnload
{
    [self setDateLabel:nil];
    [self setGiftDetailsContentScroll:nil];
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setFrontGreetingImg:nil];
    [self setBackGreetingImg:nil];
    [self setFrontLbl:nil];
    [self setBackLbl:nil];
    [self setGreetingNameLbl:nil];
    [self setGreetingPrice:nil];
    [self setPersonalMsgTxt:nil];
    [self setMsgInputAccessoryView:nil];
    [self setFlowerImgView:nil];
    [self setDetailsBgView:nil];
    [self setDodBgView:nil];
    [self setDodPicker:nil];
    [self setGiftDetailsLbl:nil];
    [self setInnerViewForGreetDetails:nil];
    [self setShippingCostLbl:nil];
    [self setGiftTitleInZoomScreen:nil];
    [self setZoomDoneBtn:nil];
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
    [monthsArray release];
    [daysArray release];
    [dateLabel release];
    [giftItemInfo release];
    [giftDetailsContentScroll release];
    [profilePic release];
    [profileNameLbl release];
    [eventNameLbl release];
    [frontGreetingImg release];
    [backGreetingImg release];
    [frontLbl release];
    [backLbl release];
    [greetingNameLbl release];
    [greetingPrice release];
    [personalMsgTxt release];
    [msgInputAccessoryView release];
    [flowerImgView release];
    [detailsBgView release];
    [dodBgView release];
    [dodPicker release];
    [giftDetailsLbl release];
    [innerViewForGreetDetails release];
    [shippingCostLbl release];
    [giftTitleInZoomScreen release];
    [zoomDoneBtn release];
    [fb_giftgiv_detailsScreen release];
    [super dealloc];
}

- (IBAction)dodPickerAction:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [dodBgView.layer addAnimation:animation forKey:@"animation"];
    dodBgView.hidden=YES;
    [giftDetailsContentScroll setContentOffset:svos animated:YES];
    giftDetailsContentScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [giftDetailsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:YES];
        }
    }
    
    switch ([sender tag]) {
            //Cancel
        case 1:
            
            break;
            //Done
        case 2:
        {
            NSString *monthNum=[monthsArray objectAtIndex:[dodPicker selectedRowInComponent:0]];
            NSString *dayNum=[daysArray objectAtIndex:[dodPicker selectedRowInComponent:1]];
            NSString *dateLblString=[NSString stringWithFormat:@"   %@ %@",[self getMonthName:[monthNum intValue]],dayNum];
            if([dodPicker selectedRowInComponent:0]==0 && [dodPicker selectedRowInComponent:1]==0)
                dateLblString=[dateLblString stringByAppendingString:@" (Immediately)"];
            dateLabel.text=dateLblString;
        }
            
            break;
    }
    
}
#pragma mark - PickerViewDatasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(component==0)
        return 12;
    else
        return 31;
        
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if(component==0){
        return 200;
    }
    else
        return 100;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if([pickerView isEqual:dodPicker]){
        if(component==0){
            if (view == nil)
            {
                view = [[[UIView alloc] init] autorelease];
                UILabel *monthLabel=[[UILabel alloc]init];
                [monthLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
                [monthLabel setBackgroundColor:[UIColor clearColor]];
                [monthLabel setFrame:CGRectMake(40, 0, 180, 44)];
                [monthLabel setTag:777];
                [monthLabel setTextColor:[UIColor blackColor]];
                [view addSubview:monthLabel];
                
                [monthLabel release];
            }
            [(UILabel*)[view viewWithTag:777] setText:[self getMonthName:[[monthsArray objectAtIndex:row]intValue]]];
        }
        else{
            if (view == nil)
            {
                view = [[[UIView alloc] init] autorelease];
                UILabel *dayLabel=[[UILabel alloc]init];
                [dayLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
                [dayLabel setBackgroundColor:[UIColor clearColor]];
                [dayLabel setFrame:CGRectMake(40, 0, 100, 44)];
                [dayLabel setTag:111];
                [view addSubview:dayLabel];
                
                [dayLabel release];
            }
            [(UILabel*)[view viewWithTag:111] setText:[daysArray objectAtIndex:row]];
        }
        
        return view;
    }
    return nil;
}
#pragma mark -
- (IBAction)zoomDoneAction:(id)sender {
    zoomDoneBtn.hidden=YES;
    giftTitleInZoomScreen.hidden=YES;
    zoomScrollView.hidden=YES;
    if(zoomScrollView!=nil){
        [zoomScrollView removeFromSuperview];
        [zoomDoneBtn removeFromSuperview];
        [giftTitleInZoomScreen removeFromSuperview];
        [zoomScrollView release];
        zoomScrollView=nil;
    }
        
}
- (void)contentView:(GfitZoomInView *)contentView touchesBegan:(NSSet *)touches{
    if(zoomDoneBtn.hidden){
        zoomDoneBtn.hidden=NO;
        giftTitleInZoomScreen.hidden=NO;
    }
    else{
        zoomDoneBtn.hidden=YES;
        giftTitleInZoomScreen.hidden=YES;
    }
    
}
#pragma mark - Facebook giftgiv delegates
- (void)facebookLoggedIn{
    
    HomeScreenVC *home=[[HomeScreenVC alloc]initWithNibName:@"HomeScreenVC" bundle:nil];
    home.giftDetailsWhichWasSelected=giftItemInfo;
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
    
    //AlertWithMessageAndDelegate(@"Oops", @"facebook request failed", nil);
}
- (void)facebookDidCancelledLogin{
    
    
}

#pragma mark - Add User Request delegate
-(void) responseForAddUser:(NSMutableDictionary*)response{
    //GGLog(@"add user..%@,%@",response,[[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]);
    GGLog(@"Received gift giv user...%@",[response objectForKey:@"GiftGivUser"]);
    if([response objectForKey:@"GiftGivUser"]){
        
        [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"GiftGivUser"] forKey:@"MyGiftGivUserId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftGivUserIDReceived" object:nil];
    }
        
}
-(void) requestFailed{
    //AlertWithMessageAndDelegate(@"GiftGiv", @"Request has failed. Please try again later", nil);

}
@end
