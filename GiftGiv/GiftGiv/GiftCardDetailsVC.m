//
//  GiftCardDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 27/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftCardDetailsVC.h"

@implementation GiftCardDetailsVC
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize profilePic;
@synthesize messageInputAccessoryView;
@synthesize giftDetailsScroll;
@synthesize personalMsgTxtView;
@synthesize sendMediaLbl;
@synthesize giftPriceLbl;
@synthesize priceSelectedLbl;
@synthesize giftImg;
@synthesize giftNameLbl;
@synthesize priceRangePickerBgView;
@synthesize giftOptionsListBgView;
@synthesize giftDetails;
@synthesize electronicPhysicSelNavigator;
@synthesize electronicPhysPicker;
@synthesize electrnicalPhysicalBgView;
@synthesize priceListArray;
@synthesize giftItemInfo;
@synthesize prevNextSegmentControl;
@synthesize pricePicker;
@synthesize dodBgView;
@synthesize dodPicker;
@synthesize dateLabel;


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
-(void) viewWillDisappear:(BOOL)animated{
    if([electrnicalPhysicalBgView superview])
        [electrnicalPhysicalBgView removeFromSuperview];
    if([dodBgView superview])
        [dodBgView removeFromSuperview];
    [super viewWillDisappear:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    electronicPhysicalList=[[NSMutableArray alloc]initWithObjects:@"Electronically",@"Physically", nil];
    
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
    
    profileNameLbl.text=[[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] uppercaseString];
    
    NSString *profilePicId;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"]){
        profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"];
    }
    else{
        profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"];
    }
    
    NSString *filePath = [GetCachesPathForTargetFile cachePathForFileName:[NSString stringWithFormat:@"%@.png",profilePicId]];
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath]){
        profilePic.image=[UIImage imageWithContentsOfFile:filePath];
    }
    else{
        profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
    }
    [self performSelector:@selector(loadGiftImage)];
    
    giftDetailsScroll.frame=CGRectMake(0, 44, 320,416);
    [self.view addSubview:giftDetailsScroll];
    
    
    personalMsgTxtView.inputAccessoryView=messageInputAccessoryView;
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    NSArray *tempPrices=[[giftItemInfo giftPrice] componentsSeparatedByString:@";"];
    
    priceListArray =[[NSMutableArray alloc]initWithArray:tempPrices];
    
    
    [priceSelectedLbl.layer setCornerRadius:6.0];
    [priceSelectedLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [priceSelectedLbl.layer setBorderWidth:1.0];
    
    [sendMediaLbl.layer setCornerRadius:6.0];
    [sendMediaLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [sendMediaLbl.layer setBorderWidth:1.0];
    
    [personalMsgTxtView.layer setCornerRadius:6.0];
    [personalMsgTxtView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [personalMsgTxtView.layer setBorderWidth:1.0];
    
    
    giftNameLbl.text=[giftItemInfo giftTitle];
    UIFont *detailsTextFont = [UIFont fontWithName:@"Helvetica" size:11.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSMutableAttributedString *giftDescription=[NSMutableAttributedString attributedStringWithString:[giftItemInfo giftDetails]];
    [giftDescription setTextAlignment:kCTTextAlignmentJustified lineBreakMode:kCTLineBreakByWordWrapping];
    CGSize labelSize = [[giftDescription string]sizeWithFont:detailsTextFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect targetFrame=CGRectMake(20, giftPriceLbl.frame.origin.y+giftPriceLbl.frame.size.height, labelSize.width, labelSize.height);
    
    if([[giftDescription string] length]){
        targetFrame.origin.y+=10;
        targetFrame.size.height+=20;
    }
    giftDetails.frame=targetFrame;
    //if(currentiOSVersion<6.0)
        
    //else
      //  [giftDetails setTextAlignment:NSTextAlignmentJustified];
    //[giftDetails setTextAlignment:(NSTextAlignment)]
    giftDetails.attributedText=giftDescription;//[giftDescription string];
        
    giftOptionsListBgView.frame=CGRectMake(0, giftDetails.frame.origin.y+giftDetails.frame.size.height, 320, 373);
    
    [giftDetailsScroll setContentSize:CGSizeMake(320, giftOptionsListBgView.frame.origin.y+giftOptionsListBgView.frame.size.height)];
    
    NSArray *priceArray=[[giftItemInfo giftPrice] componentsSeparatedByString:@";"];
    
    if([priceArray count]>1){
        ;
        giftPriceLbl.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray objectAtIndex:0],[priceArray objectAtIndex:[priceArray count]-1]];
        priceSelectedLbl.text=[NSString stringWithFormat:@"   $%@",[priceArray objectAtIndex:0]];
    }
    else{
        giftPriceLbl.text=[NSString stringWithFormat:@"$%@",[giftItemInfo giftPrice]];
        priceSelectedLbl.text=[NSString stringWithFormat:@"   $%@",[giftItemInfo giftPrice]];
    }
    
    
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
    dateLabel.text=[NSString stringWithFormat:@"   %@ %@ (Immediately)",[self getMonthName:[[monthsArray objectAtIndex:0]intValue]],[daysArray objectAtIndex:0]];
    
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
-(void)loadGiftImage{
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSString *urlStr=[giftItemInfo giftImageUrl];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                giftImg.image=thumbnail;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
- (IBAction)backToListOfGifts:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)messageKeyBoardAction:(id)sender {
    [personalMsgTxtView resignFirstResponder];
    [giftDetailsScroll setContentOffset:svos animated:YES];
    giftDetailsScroll.userInteractionEnabled=YES;
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
    }
}
- (IBAction)priceSelectionAction:(id)sender {
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
    }
    giftDetailsScroll.userInteractionEnabled=NO;
    svos = giftDetailsScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [giftPriceLbl bounds];
	rc = [giftPriceLbl convertRect:rc toView:giftDetailsScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y+=10;
	[giftDetailsScroll setContentOffset:pt animated:YES];
    if(priceRangePickerBgView.hidden)
        priceRangePickerBgView.hidden=NO;
    if(![priceRangePickerBgView superview]){
        priceRangePickerBgView.frame=CGRectMake(0, 220, 320, 260);
        [self.view.window addSubview:priceRangePickerBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [priceRangePickerBgView.layer addAnimation:animation forKey:@"animation"];
    [pricePicker selectRow:selectedPriceRow inComponent:0 animated:YES];
    if(selectedPriceRow==0){
        [prevNextSegmentControl setEnabled:NO forSegmentAtIndex:0];
        [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:1];
    }
    
}
- (IBAction)sendMediaAction:(id)sender {
    
    /*UIActionSheet *mediaActions=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Electronically",@"Physically", nil];
    [mediaActions showInView:self.view];
    [mediaActions release];
    [giftDetailsScroll setContentOffset:svos animated:YES];
	svos = giftDetailsScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [sendMediaLbl bounds];
	rc = [sendMediaLbl convertRect:rc toView:giftDetailsScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=25;
	[giftDetailsScroll setContentOffset:pt animated:YES];*/
    
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    giftDetailsScroll.userInteractionEnabled=NO;
    svos = giftDetailsScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [sendMediaLbl bounds];
	rc = [sendMediaLbl convertRect:rc toView:giftDetailsScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=25;
	[giftDetailsScroll setContentOffset:pt animated:YES];
    if(electrnicalPhysicalBgView.hidden)
        electrnicalPhysicalBgView.hidden=NO;
    if(![electrnicalPhysicalBgView superview]){
        electrnicalPhysicalBgView.frame=CGRectMake(0, 220, 320, 260);
        [self.view.window addSubview:electrnicalPhysicalBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [electrnicalPhysicalBgView.layer addAnimation:animation forKey:@"animation"];
    [electronicPhysPicker selectRow:selectedElectronicPhysicRow inComponent:0 animated:YES];
    if(selectedElectronicPhysicRow==0){
        [electronicPhysicSelNavigator setEnabled:NO forSegmentAtIndex:0];
        [electronicPhysicSelNavigator setEnabled:YES forSegmentAtIndex:1];
    }
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
    }
    giftDetailsScroll.userInteractionEnabled=NO;
    svos = giftDetailsScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textView bounds];
	rc = [textView convertRect:rc toView:giftDetailsScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[giftDetailsScroll setContentOffset:pt animated:YES];
}
- (IBAction)senderDetailsScreenAction:(id)sender {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    int month=[components month];
    int year=[components year];
    
    
    int selectedMonth=[[monthsArray objectAtIndex:[dodPicker selectedRowInComponent:0]] intValue];
    int selectedDay=[[daysArray objectAtIndex:[dodPicker selectedRowInComponent:1]] intValue];
    if(selectedMonth<month)
        year++;
    SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
    if([[sendMediaLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"Electronically"]){
        sendOptions.isSendElectronically=YES;
    }
    else
        sendOptions.isSendElectronically=NO;
    NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
    [giftAndSenderInfo setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] forKey:@"RecipientName"];
    [giftAndSenderInfo setObject:eventNameLbl.text forKey:@"EventName"];
    [giftAndSenderInfo setObject:[giftItemInfo giftId] forKey:@"GiftID"];
    [giftAndSenderInfo setObject:[giftItemInfo giftTitle] forKey:@"GiftName"];
    [giftAndSenderInfo setObject:[giftItemInfo giftImageUrl] forKey:@"GiftImgUrl"];
    [giftAndSenderInfo setObject:[priceSelectedLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]forKey:@"GiftPrice"];
    [giftAndSenderInfo setObject:[personalMsgTxtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
    [giftAndSenderInfo setObject:[NSString stringWithFormat:@"%d-%d-%d",year,selectedMonth,selectedDay] forKey:@"DateOfDelivery"];
    
    sendOptions.sendingInfoDict=giftAndSenderInfo;
    [giftAndSenderInfo release];
    [self.navigationController pushViewController:sendOptions animated:YES];
    [sendOptions release];
}
/*#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
            //Electronically
        case 0:
            sendMediaLbl.text=@"   Electronically";
            break;
            //Physically
        case 1:
            sendMediaLbl.text=@"   Physically";
            break;
    }
    [giftDetailsScroll setContentOffset:svos animated:YES];
    giftDetailsScroll.userInteractionEnabled=YES;
}
#pragma mark -*/
- (IBAction)previousNextPriceSegmentAction:(id)sender {
    
    switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
            //previous
        case 0:
            
            if(selectedPriceRow>0){
                [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:1];
                selectedPriceRow--;                
            }
            
            if(selectedPriceRow==0){
                [prevNextSegmentControl setEnabled:NO forSegmentAtIndex:0];
            }
            
            break;
            //next
        case 1:
            if(selectedPriceRow<[priceListArray count]-1){
                selectedPriceRow++;
                [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:0];
                
            }
            
            if(selectedPriceRow==[priceListArray count]-1){
                [prevNextSegmentControl setEnabled:NO forSegmentAtIndex:1];
            }
            
            break;
            
            
    }
    [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [pricePicker selectRow:selectedPriceRow inComponent:0 animated:YES];
    [pricePicker reloadComponent:0];
}
- (IBAction)priceSelectionButtonActions:(id)sender {
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [priceRangePickerBgView.layer addAnimation:animation forKey:@"animation"];
    priceRangePickerBgView.hidden=YES;
    [giftDetailsScroll setContentOffset:svos animated:YES];
    giftDetailsScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
    }
    
    
    priceSelectedLbl.text=[NSString stringWithFormat:@"   $%@",[priceListArray objectAtIndex:selectedPriceRow]];
    
}
#pragma mark - PickerViewDatasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if([pickerView isEqual:dodPicker])
        return 2;
    else
        return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual:pricePicker])
	    return [priceListArray count];
    
    else if ([pickerView isEqual:dodPicker]){
        if(component==0)
            return 12;
        else
            return 31;
    }
    else
        return [electronicPhysicalList count];
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if([pickerView isEqual:dodPicker]){
        if(component==0){
            return 200;
        }
        else
            return 100;
    }
    
    return 300;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
    
    //customized view for the picker with check mark as selection
    if([pickerView isEqual:pricePicker]){
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
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(priceSelectedByPicker:)];
            [tapGesture setNumberOfTapsRequired:1];
            [view addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            [view addSubview:checkMarkLbl];
            [view addSubview:priceLabel];
            
            [priceLabel release];
            [checkMarkLbl release];
            
            
        }
        view.tag=row;
        if(row==selectedPriceRow){
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor colorWithRed:0.274 green:0.51 blue:0.71 alpha:1.0]];
            
        }
        else{
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor blackColor]];        
        }
        
        [(UILabel*)[view viewWithTag:999] setText:[NSString stringWithFormat:@"  $%@",[priceListArray objectAtIndex:row]]];
        
        for(UIView *subview in [view subviews]){
            if([subview isKindOfClass:[UILabel class]]){
                if([(UILabel*)subview viewWithTag:888]){
                    if(row==selectedPriceRow)
                        [(UILabel*)subview setText:@"✓"];
                    else
                        [(UILabel*)subview setText:@""];
                }
                
            }
            
        }
        
        return view;
    }
	else if([pickerView isEqual:electronicPhysPicker]){
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
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(electronicPhySelectionByPicker:)];
            [tapGesture setNumberOfTapsRequired:1];
            [view addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            [view addSubview:checkMarkLbl];
            [view addSubview:priceLabel];
            
            [priceLabel release];
            [checkMarkLbl release];
            
            
        }
        view.tag=row;
        if(row==selectedElectronicPhysicRow){
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor colorWithRed:0.274 green:0.51 blue:0.71 alpha:1.0]];
            
        }
        else{
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor blackColor]];        
        }
        
        [(UILabel*)[view viewWithTag:999] setText:[NSString stringWithFormat:@"  %@",[electronicPhysicalList objectAtIndex:row]]];
        
        for(UIView *subview in [view subviews]){
            if([subview isKindOfClass:[UILabel class]]){
                if([(UILabel*)subview viewWithTag:888]){
                    if(row==selectedElectronicPhysicRow)
                        [(UILabel*)subview setText:@"✓"];
                    else
                        [(UILabel*)subview setText:@""];
                }
                
            }
            
        }
        
        return view;
    }
    else if([pickerView isEqual:dodPicker]){
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
-(void)electronicPhySelectionByPicker:(UITapGestureRecognizer*)sender{
    
    selectedElectronicPhysicRow=[sender.view tag];
    [electronicPhysPicker selectRow:selectedElectronicPhysicRow inComponent:0 animated:YES];
    
    [electronicPhysPicker reloadComponent:0];
    
    if(selectedElectronicPhysicRow>0 && selectedElectronicPhysicRow<[electronicPhysicalList count]-1){
        [electronicPhysicSelNavigator setEnabled:YES forSegmentAtIndex:0];
        [electronicPhysicSelNavigator setEnabled:YES forSegmentAtIndex:1];
        
    }
    
    else if(selectedElectronicPhysicRow==0){
        [electronicPhysicSelNavigator setEnabled:NO forSegmentAtIndex:0];
        [electronicPhysicSelNavigator setEnabled:YES forSegmentAtIndex:1];
    }
    else if(selectedElectronicPhysicRow==[electronicPhysicalList count]-1){
        [electronicPhysicSelNavigator setEnabled:YES forSegmentAtIndex:0];
        [electronicPhysicSelNavigator setEnabled:NO forSegmentAtIndex:1];
    }
    
}
-(void)priceSelectedByPicker:(UITapGestureRecognizer*)sender{
    //NSLog(@"%d",[sender.view tag]);
    
    selectedPriceRow=[sender.view tag];
    [pricePicker selectRow:selectedPriceRow inComponent:0 animated:YES];
    
    [pricePicker reloadComponent:0];
    if(selectedPriceRow>0 && selectedPriceRow<[priceListArray count]-1){
        [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:0];
        [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:1];
        
    }
    
    else if(selectedPriceRow==0){
        [prevNextSegmentControl setEnabled:NO forSegmentAtIndex:0];
        [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:1];
    }
    else if(selectedPriceRow==[priceListArray count]-1){
        [prevNextSegmentControl setEnabled:YES forSegmentAtIndex:0];
        [prevNextSegmentControl setEnabled:NO forSegmentAtIndex:1];
    }
}

#pragma mark -
- (void)viewDidUnload
{
    [self setDateLabel:nil];
    [self setDodBgView:nil];
    [self setDodPicker:nil];
    [self setGiftDetailsScroll:nil];
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setMessageInputAccessoryView:nil];
    [self setGiftImg:nil];
    [self setGiftNameLbl:nil];
    [self setGiftPriceLbl:nil];
    [self setPriceSelectedLbl:nil];
    [self setSendMediaLbl:nil];
    [self setPersonalMsgTxtView:nil];
    [self setPriceRangePickerBgView:nil];
    [self setPricePicker:nil];
    
    [self setPrevNextSegmentControl:nil];
    [self setElectrnicalPhysicalBgView:nil];
    [self setElectronicPhysPicker:nil];
    [self setElectronicPhysicSelNavigator:nil];
    [self setGiftDetails:nil];
    [self setGiftOptionsListBgView:nil];
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
    [dodBgView release];
    [dodPicker release];
    [electronicPhysicalList release];
    [giftItemInfo release];
    [giftDetailsScroll release];
    [profilePic release];
    [profileNameLbl release];
    [eventNameLbl release];
    [messageInputAccessoryView release];
    [giftImg release];
    [giftNameLbl release];
    [giftPriceLbl release];
    [priceSelectedLbl release];
    [sendMediaLbl release];
    [personalMsgTxtView release];
    [priceRangePickerBgView release];
    [pricePicker release];
    [priceListArray release];
    [prevNextSegmentControl release];
    [electrnicalPhysicalBgView release];
    [electronicPhysPicker release];
    [electronicPhysicSelNavigator release];
    [giftDetails release];
    [giftOptionsListBgView release];
    [super dealloc];
}

- (IBAction)electronicPhysicNavigatorAction:(id)sender {
    switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
            //previous
        case 0:
            
            if(selectedElectronicPhysicRow>0){
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:1];
                selectedElectronicPhysicRow--;                
            }
            
            if(selectedElectronicPhysicRow==0){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:0];
            }
            
            break;
            //next
        case 1:
            if(selectedElectronicPhysicRow<[electronicPhysicalList count]-1){
                selectedElectronicPhysicRow++;
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:0];
                
            }
            
            if(selectedElectronicPhysicRow==[electronicPhysicalList count]-1){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:1];
            }
            
            break;
            
            
    }
    [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [electronicPhysPicker selectRow:selectedElectronicPhysicRow inComponent:0 animated:YES];
    [electronicPhysPicker reloadComponent:0];
}

- (IBAction)electronicPhysicSelDone:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [electrnicalPhysicalBgView.layer addAnimation:animation forKey:@"animation"];
    electrnicalPhysicalBgView.hidden=YES;
    [giftDetailsScroll setContentOffset:svos animated:YES];
    giftDetailsScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:YES];
        }
    }
    
    
    sendMediaLbl.text=[NSString stringWithFormat:@"   %@",[electronicPhysicalList objectAtIndex:selectedElectronicPhysicRow]];
    
    [giftDetailsScroll setContentOffset:svos animated:YES];
    
}
- (IBAction)showDatePicker:(id)sender{
    for(UIView *subview in [giftDetailsScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    giftDetailsScroll.userInteractionEnabled=NO;
    svos = giftDetailsScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [dateLabel bounds];
	rc = [dateLabel convertRect:rc toView:giftDetailsScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=45;
	[giftDetailsScroll setContentOffset:pt animated:YES];
    if(dodBgView.hidden)
        dodBgView.hidden=NO;
    if(![dodBgView superview]){
        dodBgView.frame=CGRectMake(0, 220, 320, 260);
        [self.view.window addSubview:dodBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [dodBgView.layer addAnimation:animation forKey:@"animation"];
    
    
}
- (IBAction)dodPickerAction:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [dodBgView.layer addAnimation:animation forKey:@"animation"];
    dodBgView.hidden=YES;
    [giftDetailsScroll setContentOffset:svos animated:YES];
    giftDetailsScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [giftDetailsScroll subviews]){
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
@end
