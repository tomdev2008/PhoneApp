//
//  FreeGiftItemDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 12/11/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "FreeGiftItemDetailsVC.h"

@interface FreeGiftItemDetailsVC ()

@end

@implementation FreeGiftItemDetailsVC

@synthesize giftItemInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fb_giftgiv_detailsScreen=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_detailsScreen.fbGiftGivDelegate=self;
    
    // Do any additional setup after loading the view from its nib.
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        _eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
        
        
        _profileNameLbl.text=[[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] uppercaseString];
        
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
            _profilePic.image=[UIImage imageWithContentsOfFile:filePath];
        }
        else{
            _profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
        }
    }
     // If there is no event selected, we should not show the header part, and make sure to occupy the entire screen with the rest of UI elements
    else{
        _detailsBgView.frame=CGRectMake(_detailsBgView.frame.origin.x, _detailsBgView.frame.origin.y-47, _detailsBgView.frame.size.width, _detailsBgView.frame.size.height);
    }
    
    [self loadGiftImage:[giftItemInfo giftImageUrl] forAnObject:_giftItemImg];
    
    
    UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomInOutForCards:)];
    tapRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    _giftNameLbl.text=[giftItemInfo giftTitle];
    _giftDetailsBgScroll.frame=CGRectMake(0, 44, 320,416);
    [self.view addSubview:_giftDetailsBgScroll];
    UIFont *detailsTextFont = [UIFont fontWithName:@"Helvetica" size:11.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSMutableAttributedString *giftDescription=[NSMutableAttributedString attributedStringWithString:[giftItemInfo giftDetails]];
    [giftDescription setTextAlignment:kCTTextAlignmentJustified lineBreakMode:kCTLineBreakByWordWrapping];
    CGSize labelSize = [[giftDescription string] sizeWithFont:detailsTextFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect targetFrame=CGRectMake(20, _giftNameLbl.frame.origin.y+_giftNameLbl.frame.size.height, labelSize.width, labelSize.height);
    
    if([[giftDescription string] length]){
        targetFrame.origin.y+=10;
        targetFrame.size.height+=20;
    }
    _giftDetailsLbl.frame=targetFrame;
    
    _giftDetailsLbl.attributedText=giftDescription;
    
    _innerViewForGiftItemDetails.frame=CGRectMake(0, _giftDetailsLbl.frame.origin.y+_giftDetailsLbl.frame.size.height+5, 320, 234);
    CGRect detailsBgFrame=_detailsBgView.frame;
    detailsBgFrame.size.height=_innerViewForGiftItemDetails.frame.origin.y+_innerViewForGiftItemDetails.frame.size.height;
    _detailsBgView.frame=detailsBgFrame;
    [_giftDetailsBgScroll setContentSize:CGSizeMake(320, _detailsBgView.frame.origin.y+_detailsBgView.frame.size.height)];
   
    _personalMsgTxt.inputAccessoryView=_msgInputAccessoryView;
    
   
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[_profileNameLbl.text sizeWithFont:_profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    _profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(_profileNameLbl.frame.origin.x+_profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [_eventNameLbl.text sizeWithFont:_eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    _eventNameLbl.frame= CGRectMake(_profileNameLbl.frame.origin.x+3+_profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    [_personalMsgTxt.layer setCornerRadius:6.0];
    [_personalMsgTxt.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [_personalMsgTxt.layer setBorderWidth:1.0];
    
    [_dateLabel.layer setCornerRadius:6.0];
    [_dateLabel.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [_dateLabel.layer setBorderWidth:1.0];
    
    
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
    _dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];
    
    _giftTitleInZoomScreen.text=[giftItemInfo giftTitle];
    
    [_zoomDoneBtn.layer setBorderColor:[[UIColor blackColor]CGColor]];
    [_zoomDoneBtn.layer setBorderWidth:1.0];
    [_zoomDoneBtn.layer setCornerRadius:5.0];
     
    
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
        
        if([targetImgView isEqual:_profilePic]){
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"]){
                tempImageURL=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"];
            }
            else
                tempImageURL=FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]);
        }
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempImageURL]];
        UIImage *giftImg = [UIImage imageWithData:data];
        
        if(giftImg==nil){
            if([targetImgView isEqual:_profilePic]){
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    _profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
                    
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
    
    CGPoint tapLocation=[tapRecog locationInView:_giftDetailsBgScroll];
    
    //zoom out
    if(zoomScrollView!=nil && [zoomScrollView superview]){
        if(CGRectContainsPoint(zoomScrollView.frame, tapLocation)){
            
            [zoomScrollView fullZoomToPoint:tapRecog];
            if(_zoomDoneBtn.hidden){
                _zoomDoneBtn.hidden=NO;
                _giftTitleInZoomScreen.hidden=NO;
            }
            else{
                _zoomDoneBtn.hidden=YES;
                _giftTitleInZoomScreen.hidden=YES;
            }
            return;
        }
        
    }
    else{
        if(CGRectContainsPoint(_giftItemImg.frame, tapLocation)){
            zoomScrollView=[[GfitZoomInView alloc]initWithFrame:[self.view bounds]];
            
            zoomScrollView.theContainerView.image=_giftItemImg.image;
            
            zoomScrollView.message=self;
            [self.view addSubview:zoomScrollView];
            
            _zoomDoneBtn.frame=CGRectMake(240, 30, 70, 31);
            [self.view addSubview:_zoomDoneBtn];
            
            if([[UIScreen mainScreen] bounds].size.height == 568){
                _giftTitleInZoomScreen.frame=CGRectMake(10, 480, 300, 41);
            }
            else
                _giftTitleInZoomScreen.frame=CGRectMake(10, 420, 300, 41);
            
            //giftTitleInZoomScreen.frame=CGRectMake(10, 400, 300, 41);
            [self.view addSubview:_giftTitleInZoomScreen];
            
            /*zoomDoneBtn.hidden=YES;
             //zoomScrollView.hidden=YES;
             giftTitleInZoomScreen.hidden=YES;
             */
        }
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showDatePicker:(id)sender {
    for(UIView *subview in [_giftDetailsBgScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    //giftDetailsContentScroll.userInteractionEnabled=NO;
    svos = _giftDetailsBgScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [_dateLabel bounds];
	rc = [_dateLabel convertRect:rc toView:_giftDetailsBgScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=45;
	[_giftDetailsBgScroll setContentOffset:pt animated:YES];
    if(_dodBgView.hidden)
        _dodBgView.hidden=NO;
    if(![_dodBgView superview]){
        CGRect origFrame=_dodBgView.frame;//CGRectMake(0, 220, 320, 260);
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        _dodBgView.frame=origFrame;
        [self.view.window addSubview:_dodBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [_dodBgView.layer addAnimation:animation forKey:@"animation"];
}

- (IBAction)backToGiftsList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendOptionsScreenAction:(id)sender {
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        int month=[components month];
        int year=[components year];
        
        
        int selectedMonth=[[monthsArray objectAtIndex:[_dodPicker selectedRowInComponent:0]] intValue];
        int selectedDay=[[daysArray objectAtIndex:[_dodPicker selectedRowInComponent:1]] intValue];
        if(selectedMonth<month)
            year++;
        
        SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
        sendOptions.isSendElectronically=NO;
        NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
        [giftAndSenderInfo setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] forKey:@"RecipientName"];
        [giftAndSenderInfo setObject:_eventNameLbl.text forKey:@"EventName"];
        [giftAndSenderInfo setObject:[giftItemInfo giftId] forKey:@"GiftID"];
        [giftAndSenderInfo setObject:[giftItemInfo giftTitle] forKey:@"GiftName"];
        [giftAndSenderInfo setObject:[giftItemInfo giftImageUrl] forKey:@"GiftImgUrl"];
        
        [giftAndSenderInfo setObject:@"" forKey:@"GiftPrice"];
        [giftAndSenderInfo setObject:[_personalMsgTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
        
        [giftAndSenderInfo setObject:[NSString stringWithFormat:@"%d-%d-%d",year,selectedMonth,selectedDay] forKey:@"DateOfDelivery"];
        
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
    if([pickerView isEqual:_dodPicker]){
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
- (IBAction)zoomDoneAction:(id)sender {
    _zoomDoneBtn.hidden=YES;
    _giftTitleInZoomScreen.hidden=YES;
    zoomScrollView.hidden=YES;
    if(zoomScrollView!=nil){
        [zoomScrollView removeFromSuperview];
        [_zoomDoneBtn removeFromSuperview];
        [_giftTitleInZoomScreen removeFromSuperview];
        [zoomScrollView release];
        zoomScrollView=nil;
    }
}
- (void)contentView:(GfitZoomInView *)contentView touchesBegan:(NSSet *)touches{
    if(_zoomDoneBtn.hidden){
        _zoomDoneBtn.hidden=NO;
        _giftTitleInZoomScreen.hidden=NO;
    }
    else{
        _zoomDoneBtn.hidden=YES;
        _giftTitleInZoomScreen.hidden=YES;
    }
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    //giftDetailsContentScroll.userInteractionEnabled=NO;
    
    svos = _giftDetailsBgScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textView bounds];
	rc = [textView convertRect:rc toView:_giftDetailsBgScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[_giftDetailsBgScroll setContentOffset:pt animated:YES];
}
- (IBAction)msgKeyboardDismissAction:(id)sender {
    [_personalMsgTxt resignFirstResponder];
    [_giftDetailsBgScroll setContentOffset:svos animated:YES];
    _giftDetailsBgScroll.userInteractionEnabled=YES;
}
- (IBAction)dodPickerAction:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [_dodBgView.layer addAnimation:animation forKey:@"animation"];
    _dodBgView.hidden=YES;
    [_giftDetailsBgScroll setContentOffset:svos animated:YES];
    _giftDetailsBgScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [_giftDetailsBgScroll subviews]){
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
            NSString *monthNum=[monthsArray objectAtIndex:[_dodPicker selectedRowInComponent:0]];
            NSString *dayNum=[daysArray objectAtIndex:[_dodPicker selectedRowInComponent:1]];
            NSString *dateLblString=[NSString stringWithFormat:@"   %@ %@",[self getMonthName:[monthNum intValue]],dayNum];
            if([_dodPicker selectedRowInComponent:0]==0 && [_dodPicker selectedRowInComponent:1]==0)
                dateLblString=[dateLblString stringByAppendingString:@" (Immediately)"];
            _dateLabel.text=dateLblString;
        }
            
            break;
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
#pragma mark -
- (void)dealloc {
    [_profilePic release];
    [_profileNameLbl release];
    [_eventNameLbl release];
    [_giftDetailsBgScroll release];
    [_giftItemImg release];
    [_giftNameLbl release];
    [_giftDetailsLbl release];
    [_innerViewForGiftItemDetails release];
    [_dateLabel release];
    [_personalMsgTxt release];
    [_zoomDoneBtn release];
    [_giftTitleInZoomScreen release];
    [_dodBgView release];
    [_dodPicker release];
    [_msgInputAccessoryView release];
    [giftItemInfo release];
    [fb_giftgiv_detailsScreen release];
    [_detailsBgView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftDetailsBgScroll:nil];
    [self setGiftItemImg:nil];
    [self setGiftNameLbl:nil];
    [self setGiftDetailsLbl:nil];
    [self setInnerViewForGiftItemDetails:nil];
    [self setDateLabel:nil];
    [self setPersonalMsgTxt:nil];
    [self setZoomDoneBtn:nil];
    [self setGiftTitleInZoomScreen:nil];
    [self setDodBgView:nil];
    [self setDodPicker:nil];
    [self setMsgInputAccessoryView:nil];
    [self setDetailsBgView:nil];
    [super viewDidUnload];
}


@end
