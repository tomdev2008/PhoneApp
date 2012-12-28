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
    [_giftMsgTxtView setInputAccessoryView:_msgInputAccessoryView];
    
    _giftDetailsBgScroll.frame=CGRectMake(0, 44, 320,416);
    
    [_giftMsgTxtView.layer setCornerRadius:5.0];
    [_giftMsgTxtView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [_giftMsgTxtView.layer setBorderWidth:1.0];
    
    [_emailBgView.layer setCornerRadius:6.0];
    [_emailBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [_emailBgView.layer setBorderWidth:1.0];
    
    [_recipientsAddressLbl.layer setCornerRadius:6.0];
    [_recipientsAddressLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [_recipientsAddressLbl.layer setBorderWidth:1.0];
    
    //selectedSendOptionRow=0;
    [self.view addSubview:_giftDetailsBgScroll];
    
    listOfSendOptions=[[NSMutableArray alloc]initWithCapacity:2];
    
        
    [listOfSendOptions addObject:@"Post on Facebook"];
        
    [listOfSendOptions addObject:@"Recipient email address"];
    _recipientsAddressLbl.text=@"   Post on Facebook";
    
    if([giftItemInfo objectForKey:@"RecipientMailID"]){
        _emailTxtField.text=[giftItemInfo objectForKey:@"RecipientMailID"];
        [self refreshTheFormForOption:2];
       
    }
    else{
        [self refreshTheFormForOption:1];
    }
    
    
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
    _giftNameLabel.text=[[giftItemInfo objectForKey:@"GiftItem"] giftTitle];
    if([giftItemInfo objectForKey:@"EditableGiftDescription"])
        [self updateTheScreenRespectiveToMessageText:[giftItemInfo objectForKey:@"EditableGiftDescription"]];
    else
        [self updateTheScreenRespectiveToMessageText:[[giftItemInfo objectForKey:@"GiftItem"] giftDetails]];
   
   
   
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[_profileNameLbl.text sizeWithFont:_profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    _profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(_profileNameLbl.frame.origin.x+_profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [_eventNameLbl.text sizeWithFont:_eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    _eventNameLbl.frame= CGRectMake(_profileNameLbl.frame.origin.x+3+_profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
        
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
    if([giftItemInfo objectForKey:@"DateOfDelivery"]){
        
        NSArray *dateArrayComponents=[[giftItemInfo objectForKey:@"DateOfDelivery"] componentsSeparatedByString:@"-"];
        if([components day]==[[dateArrayComponents objectAtIndex:2] integerValue] && [components month]==[[dateArrayComponents objectAtIndex:1] integerValue]){
            _dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];
        }
        else
            _dateLabel.text=[NSString stringWithFormat:@"   %@ %@",[self getMonthName:[[dateArrayComponents objectAtIndex:1]intValue]],[dateArrayComponents objectAtIndex:2]];
        
        [daysArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isEqualToString:[dateArrayComponents objectAtIndex:2]]){
                [_dodPicker selectRow:idx inComponent:1 animated:NO];
            }
        }];
        [monthsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isEqualToString:[dateArrayComponents objectAtIndex:1]]){
                [_dodPicker selectRow:idx inComponent:0 animated:NO];
            }
        }];
    }
    else
        _dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];
         
    
}
-(void)updateTheScreenRespectiveToMessageText:(NSString*)targetText{
        
    
    UIFont *detailsTextFont = [UIFont fontWithName:@"Helvetica" size:13.0];
    CGSize constraintSize = CGSizeMake(280.0f, 65);
    /*NSMutableAttributedString *giftDescription=[NSMutableAttributedString attributedStringWithString:targetText];
    [giftDescription setTextAlignment:kCTTextAlignmentJustified lineBreakMode:UILineBreakModeWordWrap];*/
    CGSize labelSize = [targetText sizeWithFont:detailsTextFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeTailTruncation];
    
    CGRect targetFrame=CGRectMake(20, 20, labelSize.width, labelSize.height);
    
    if([targetText length]){
        targetFrame.origin.y+=10;
        targetFrame.size.height+=20;
    }
    _giftDetailsLbl.frame=targetFrame;
    
    _giftDetailsLbl.text=targetText;
    
    _txtEditBtn.frame=CGRectMake(_txtEditBtn.frame.origin.x, _giftDetailsLbl.frame.origin.y+_giftDetailsLbl.frame.size.height, _txtEditBtn.frame.size.width, _txtEditBtn.frame.size.height);
    
    _innerViewForGiftItemDetails.frame=CGRectMake(0, _txtEditBtn.frame.origin.y+_txtEditBtn.frame.size.height+5, 320, _innerViewForGiftItemDetails.frame.size.height);
    CGRect detailsBgFrame=_detailsBgView.frame;
    detailsBgFrame.size.height=_innerViewForGiftItemDetails.frame.origin.y+_innerViewForGiftItemDetails.frame.size.height;
    _detailsBgView.frame=detailsBgFrame;
    _giftDetailsBgScroll.contentSize=CGSizeMake(320, _detailsBgView.frame.origin.y+_innerViewForGiftItemDetails.frame.origin.y+ _confirmBtnLbl.frame.origin.y+_confirmBtnLbl.frame.size.height+10);
    //[_giftDetailsBgScroll setContentSize:CGSizeMake(320, _detailsBgView.frame.origin.y+_detailsBgView.frame.size.height)];
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
/*-(void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    
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
*/
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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    int month=[components month];
    int year=[components year];
    
    
    int selectedMonth=[[monthsArray objectAtIndex:[_dodPicker selectedRowInComponent:0]] intValue];
    int selectedDay=[[daysArray objectAtIndex:[_dodPicker selectedRowInComponent:1]] intValue];
    if(selectedMonth<month)
        year++;
    
    [giftItemInfo setObject:[NSString stringWithFormat:@"%d-%d-%d",year,selectedMonth,selectedDay] forKey:@"DateOfDelivery"];
    [giftItemInfo setObject:[_giftDetailsLbl.attributedText string] forKey:@"EditableGiftDescription"];
    if([_recipientemailContentView superview]){
        
        if(![_emailTxtField.text isEqualToString:@""])
            [giftItemInfo setObject:_emailTxtField.text forKey:@"RecipientMailID"];
        
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        
        if([_recipientemailContentView superview]){
            if(![_emailTxtField.text isEqualToString:@""]){
                if(![self validateMail:_emailTxtField.text]){
                    AlertWithMessageAndDelegate(@"GiftGiv", @"Invalid email address", nil);
                    return;
                }
            }
            else{
                AlertWithMessageAndDelegate(@"GiftGiv", @"Please provide recipient's email address", nil);
                return;
            }
        }
                
        GiftSummaryVC *giftSummary=[[GiftSummaryVC alloc]initWithNibName:@"GiftSummaryVC" bundle:nil];
        
        NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
        [giftAndSenderInfo setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] forKey:@"RecipientName"];
        [giftAndSenderInfo setObject:_eventNameLbl.text forKey:@"EventName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftId] forKey:@"GiftID"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftTitle] forKey:@"GiftName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"]giftImageUrl] forKey:@"GiftImgUrl"];
        if([_recipientemailContentView superview]){
            [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"RecipientMailID"] forKey:@"RecipientMailID"];
            
        }
        else{
            [giftAndSenderInfo setObject:@"Yes" forKey:@"WallPost"];
        }
        [giftAndSenderInfo setObject:@"" forKey:@"GiftPrice"];
        [giftAndSenderInfo setObject:@"" forKey:@"PersonalMessage"];
       
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"DateOfDelivery"] forKey:@"DateOfDelivery"];
       
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"EditableGiftDescription"] forKey:@"EditableGiftDescription"];
        [giftAndSenderInfo setObject:[NSNumber numberWithBool:YES] forKey:@"IsElectronicSending"];
        giftSummary.giftSummaryDict=giftAndSenderInfo;
        
        [giftAndSenderInfo release];
        [self.navigationController pushViewController:giftSummary animated:YES];
        [giftSummary release];
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
            AlertWithMessageAndDelegateActionHandling(@"GiftGiv", @"Login facebook and select an event to celebrate", [NSArray arrayWithObjects:@"Cancel",@"Login", nil], self);
        }
        
        
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==1){
        
        [fb_giftgiv_detailsScreen authorizeOurAppWithFacebook];
    }
}
#pragma mark - PickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if([pickerView isEqual:_addressMailSMSPicker])
        return 1;
    else
        return 2;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual:_addressMailSMSPicker])
        return [listOfSendOptions count];
    else{
        if(component==0)
            return 12;
        else
            return 31;
    }
	
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if(![pickerView isEqual:_addressMailSMSPicker]){
        if(component==0){
            return 200;
        }
        else
            return 100;
    }
    return 300;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if([pickerView isEqual:_addressMailSMSPicker]){
        
        if (view == nil)
        {
            view = [[[UIView alloc] init] autorelease];
            UILabel *priceLabel=[[UILabel alloc]init];
            [priceLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            [priceLabel setBackgroundColor:[UIColor clearColor]];
            [priceLabel setFrame:CGRectMake(30, 0, 280, 30)];
            [priceLabel setTag:999];
            UILabel *checkMarkLbl=[[UILabel alloc]init];
            [checkMarkLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            [checkMarkLbl setTag:888];
            [checkMarkLbl setBackgroundColor:[UIColor clearColor]];
            [checkMarkLbl setFrame:CGRectMake(5, 0, 30, 30)];
            [checkMarkLbl setTextColor:[UIColor colorWithRed:0.274 green:0.51 blue:0.71 alpha:1.0]];
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressOptionSelectedByPicker:)];
            [tapGesture setNumberOfTapsRequired:1];
            [view addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            [view addSubview:checkMarkLbl];
            [view addSubview:priceLabel];
            
            [priceLabel release];
            [checkMarkLbl release];
            
            
        }
        view.tag=row;
        if(row==selectedSendOptionRow){
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor colorWithRed:0.274 green:0.51 blue:0.71 alpha:1.0]];
            
        }
        else{
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor blackColor]];
        }
        
        [(UILabel*)[view viewWithTag:999] setText:[NSString stringWithFormat:@"  %@",[listOfSendOptions objectAtIndex:row]]];
        
        for(UIView *subview in [view subviews]){
            if([subview isKindOfClass:[UILabel class]]){
                if([(UILabel*)subview viewWithTag:888]){
                    if(row==selectedSendOptionRow)
                        [(UILabel*)subview setText:@"✓"];
                    else
                        [(UILabel*)subview setText:@""];
                }
                
            }
            
        }
        
        return view;
        
    }
    
    else if([pickerView isEqual:_dodPicker]){
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
- (IBAction)giftMsgEditActions:(id)sender {
    [_giftMsgTxtView resignFirstResponder];
    [_giftMsgEditScreen removeFromSuperview];
    if([sender tag]==2){
        
         [self updateTheScreenRespectiveToMessageText:_giftMsgTxtView.text];
    }
}

- (IBAction)editActionForTheMessage:(id)sender {
    _giftMsgEditScreen.frame=CGRectMake(0, 0, 320, [[UIScreen mainScreen]bounds].size.height-20);
    
    _giftMsgTxtView.text=[_giftDetailsLbl.attributedText string];
    [_giftMsgTxtView becomeFirstResponder];
    [self.view addSubview:_giftMsgEditScreen];
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
#pragma mark -
-(void)refreshTheFormForOption:(int)optionIndex{
    
    if([giftItemInfo objectForKey:@"RecipientMailID"])
        [giftItemInfo removeObjectForKey:@"RecipientMailID"];
    if([giftItemInfo objectForKey:@"WallPost"])
        [giftItemInfo removeObjectForKey:@"WallPost"];
    if([_wallPostDescription superview])
        [_wallPostDescription removeFromSuperview];
    
    switch (optionIndex) {
         //wall post
        case 1:
            if([_recipientemailContentView superview])
                [_recipientemailContentView removeFromSuperview];
            if(![_wallPostDescription superview]){
                
                _wallPostDescription.frame=CGRectMake(23, _recipientsAddressLbl.frame.origin.y+_recipientsAddressLbl.frame.size.height+5, _wallPostDescription.frame.size.width, _wallPostDescription.frame.size.height);
                [_innerViewForGiftItemDetails addSubview:_wallPostDescription];
            }
            CGRect confirmBtnFrame_wall=_confirmBtn.frame;
            confirmBtnFrame_wall.origin.y=_wallPostDescription.frame.origin.y+_wallPostDescription.frame.size.height+9;
            _confirmBtn.frame=confirmBtnFrame_wall;
            
            CGRect confirmLblFrame_wall=_confirmBtnLbl.frame;
            confirmLblFrame_wall.origin.y=_wallPostDescription.frame.origin.y+_wallPostDescription.frame.size.height+15;
            _confirmBtnLbl.frame=confirmLblFrame_wall;
           
            
            break;
                        
            //email
        case 2:
            if([_wallPostDescription superview])
                [_wallPostDescription removeFromSuperview];
            if(![_recipientemailContentView superview]){
                _recipientemailContentView.frame=CGRectMake(23, _recipientsAddressLbl.frame.origin.y+_recipientsAddressLbl.frame.size.height+5, _recipientemailContentView.frame.size.width, _recipientemailContentView.frame.size.height);
               
                [_innerViewForGiftItemDetails addSubview:_recipientemailContentView];
            }
            
            
            CGRect confirmBtnFrame_email=_confirmBtn.frame;
            confirmBtnFrame_email.origin.y=_recipientemailContentView.frame.origin.y+_recipientemailContentView.frame.size.height+9;
            _confirmBtn.frame=confirmBtnFrame_email;
            
            CGRect confirmLblFrame_email=_confirmBtnLbl.frame;
            confirmLblFrame_email.origin.y=_recipientemailContentView.frame.origin.y+_recipientemailContentView.frame.size.height+15;
            _confirmBtnLbl.frame=confirmLblFrame_email;
            
            break;
            
            
    }
    _giftDetailsBgScroll.contentSize=CGSizeMake(320, _detailsBgView.frame.origin.y+_innerViewForGiftItemDetails.frame.origin.y+ _confirmBtnLbl.frame.origin.y+_confirmBtnLbl.frame.size.height+10);
}
#pragma mark - mail validation

//Regular expression for mail id
-(BOOL)validateMail:(NSString *)email {
	
	NSString* emailRegex=@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - TextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    svos = _giftDetailsBgScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textField  bounds];
	rc = [textField  convertRect:rc toView:_giftDetailsBgScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[_giftDetailsBgScroll setContentOffset:pt animated:YES];
    //sendOptionsContentScroll.userInteractionEnabled=NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField isEqual:_emailTxtField]){
		_emailTxtField.text=[_emailTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![_emailTxtField.text isEqualToString:@""]){
            if(![self validateMail:_emailTxtField.text]){
                //emailTxtFld.textColor=[UIColor redColor];
                AlertWithMessageAndDelegate(@"GiftGiv", @"Invalid email address", nil);
            }
        }
        
	}
    [_giftDetailsBgScroll setContentOffset:svos animated:YES];
    _giftDetailsBgScroll.userInteractionEnabled=YES;
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)addressEmailSMSSelDoneAction:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [_addressEmailSMSSelPickerBgView.layer addAnimation:animation forKey:@"animation"];
    _addressEmailSMSSelPickerBgView.hidden=YES;
    
    _giftDetailsBgScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [_giftDetailsBgScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:YES];
        }
    }
    
    
    _recipientsAddressLbl.text=[NSString stringWithFormat:@"   %@",[listOfSendOptions objectAtIndex:selectedSendOptionRow]];
    
    
    
    switch (selectedSendOptionRow) {
            
        case 0:
            
            [self refreshTheFormForOption:1];
            
            break;
            
        case 1:
            [self refreshTheFormForOption:2];
            
            break;
            
    }
    
    [_giftDetailsBgScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
    
    
}

- (IBAction)addressEmailSMSNavigatorAction:(id)sender {
    
    switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
            //previous
        case 0:
            
            if(selectedSendOptionRow>0){
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:1];
                selectedSendOptionRow--;
            }
            
            if(selectedSendOptionRow==0){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:0];
            }
            
            break;
            //next
        case 1:
            if(selectedSendOptionRow<[listOfSendOptions count]-1){
                selectedSendOptionRow++;
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:0];
                
            }
            
            if(selectedSendOptionRow==[listOfSendOptions count]-1){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:1];
            }
            
            break;
            
            
    }
    [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [_addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    [_addressMailSMSPicker reloadComponent:0];
    
}
#pragma mark -
-(void)addressOptionSelectedByPicker:(UITapGestureRecognizer*)sender{
    
    selectedSendOptionRow=[sender.view tag];
    [_addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    
    [_addressMailSMSPicker reloadComponent:0];
    
    if(selectedSendOptionRow>0 && selectedSendOptionRow<[listOfSendOptions count]-1){
        [_addEmailSMSSegment setEnabled:YES forSegmentAtIndex:0];
        [_addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
        
    }
    
    else if(selectedSendOptionRow==0){
        [_addEmailSMSSegment setEnabled:NO forSegmentAtIndex:0];
        [_addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
    }
    else if(selectedSendOptionRow==[listOfSendOptions count]-1){
        [_addEmailSMSSegment setEnabled:YES forSegmentAtIndex:0];
        [_addEmailSMSSegment setEnabled:NO forSegmentAtIndex:1];
    }
    
}

- (IBAction)recipientAddressAction:(id)sender {
    
    
    for(UIView *subview in [_giftDetailsBgScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    _giftDetailsBgScroll.userInteractionEnabled=NO;
    svos = _giftDetailsBgScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [_recipientsAddressLbl bounds];
	rc = [_recipientsAddressLbl convertRect:rc toView:_giftDetailsBgScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=15;
	[_giftDetailsBgScroll setContentOffset:pt animated:YES];
    if(_addressEmailSMSSelPickerBgView.hidden)
        _addressEmailSMSSelPickerBgView.hidden=NO;
    if(![_addressEmailSMSSelPickerBgView superview]){
        CGRect origFrame=_addressEmailSMSSelPickerBgView.frame;
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        _addressEmailSMSSelPickerBgView.frame=origFrame;
        [self.view.window addSubview:_addressEmailSMSSelPickerBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [_addressEmailSMSSelPickerBgView.layer addAnimation:animation forKey:@"animation"];
    [_addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    if(selectedSendOptionRow==0){
        [_addEmailSMSSegment setEnabled:NO forSegmentAtIndex:0];
        [_addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
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
   
    [_giftDetailsLbl release];
    [_innerViewForGiftItemDetails release];
    [_dateLabel release];
    
    [_dodBgView release];
    [_dodPicker release];
    [_msgInputAccessoryView release];
    [giftItemInfo release];
    [fb_giftgiv_detailsScreen release];
    [_detailsBgView release];
    [_giftMsgEditScreen release];
    [_giftMsgTxtView release];
    [_wallPostDescription release];
    [_emailBgView release];
    [_emailTxtField release];
    [_recipientsAddressLbl release];
    [_addEmailSMSSegment release];
    [_confirmBtnLbl release];
    [_confirmBtn release];
    [listOfSendOptions release];
    [_addEmailSMSSegment release];
    [_addressMailSMSPicker release];
    [_addressEmailSMSSelPickerBgView release];
    [_recipientemailContentView release];
    
    [_txtEditBtn release];
    [_giftNameLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftDetailsBgScroll:nil];
   
    [self setGiftDetailsLbl:nil];
    [self setInnerViewForGiftItemDetails:nil];
    [self setDateLabel:nil];
    
    [self setDodBgView:nil];
    [self setDodPicker:nil];
    [self setMsgInputAccessoryView:nil];
    [self setDetailsBgView:nil];
    [self setGiftMsgEditScreen:nil];
    [self setGiftMsgTxtView:nil];
    [self setAddressEmailSMSSelPickerBgView:nil];
    [self setAddressMailSMSPicker:nil];
    [self setRecipientemailContentView:nil];
    [self setWallPostDescription:nil];
    [self setEmailBgView:nil];
    [self setEmailTxtField:nil];
    [self setRecipientsAddressLbl:nil];

    [self setAddEmailSMSSegment:nil];
    [self setConfirmBtnLbl:nil];
    [self setConfirmBtn:nil];
    [self setAddEmailSMSSegment:nil];
    [self setTxtEditBtn:nil];
    [self setGiftNameLabel:nil];
    [super viewDidUnload];
}

@end
