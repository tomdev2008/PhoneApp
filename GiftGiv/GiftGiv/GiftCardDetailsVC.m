//
//  GiftCardDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 27/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftCardDetailsVC.h"
#define kPSAnimationDuration 0.35f
#define kPSFullscreenAnimationBounce 20

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
    
    if([giftItemInfo valueForKey:@"IsSendElectronically"]){
        if([[giftItemInfo valueForKey:@"IsSendElectronically"] boolValue]){
            sendMediaLbl.text=[NSString stringWithFormat:@"   Electronically"];
            selectedElectronicPhysicRow=0;
        }
        else{
            sendMediaLbl.text=[NSString stringWithFormat:@"   Physically"];
            selectedElectronicPhysicRow=1;
        }
    }
    
    
    fb_giftgiv_detailsScreen=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_detailsScreen.fbGiftGivDelegate=self;
    
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
        CGRect giftImgRect=giftImg.frame;
        giftImgRect.origin.y=giftImg.frame.origin.y-47;
        giftImg.frame=giftImgRect;
        _detailsTxtLbl.frame=CGRectMake(_detailsTxtLbl.frame.origin.x, _detailsTxtLbl.frame.origin.y-47, _detailsTxtLbl.frame.size.width, _detailsTxtLbl.frame.size.height);
        giftNameLbl.frame=CGRectMake(giftNameLbl.frame.origin.x, giftNameLbl.frame.origin.y-47, giftNameLbl.frame.size.width, giftNameLbl.frame.size.height);
        giftPriceLbl.frame=CGRectMake(giftPriceLbl.frame.origin.x, giftPriceLbl.frame.origin.y-47, giftPriceLbl.frame.size.width, giftPriceLbl.frame.size.height);
        shippingCostLbl.frame=CGRectMake(shippingCostLbl.frame.origin.x, shippingCostLbl.frame.origin.y-47, shippingCostLbl.frame.size.width, shippingCostLbl.frame.size.height);
    }
    [self performSelector:@selector(loadGiftImage) withObject:nil afterDelay:0.001];
    
    giftDetailsScroll.frame=CGRectMake(0, 44, 320,416);
   
    
    [self.view addSubview:giftDetailsScroll];
    
    
    personalMsgTxtView.inputAccessoryView=messageInputAccessoryView;
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    NSArray *tempPrices=[[[giftItemInfo objectForKey:@"GiftItem"] giftPrice] componentsSeparatedByString:@";"];
    
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
    
    
    giftNameLbl.text=[[giftItemInfo objectForKey:@"GiftItem"] giftTitle];
    UIFont *detailsTextFont = [UIFont fontWithName:@"Helvetica" size:11.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSMutableAttributedString *giftDescription=[NSMutableAttributedString attributedStringWithString:[[giftItemInfo objectForKey:@"GiftItem"] giftDetails]];
    [giftDescription setTextAlignment:kCTTextAlignmentJustified lineBreakMode:kCTLineBreakByWordWrapping];
    CGSize labelSize = [[giftDescription string]sizeWithFont:detailsTextFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect targetFrame=CGRectMake(20, shippingCostLbl.frame.origin.y+shippingCostLbl.frame.size.height, labelSize.width, labelSize.height);
    
    if([[giftDescription string] length]){
        targetFrame.origin.y+=10;
        targetFrame.size.height+=20;
    }
    giftDetails.frame=targetFrame;
   
    giftDetails.attributedText=giftDescription;
        
    giftOptionsListBgView.frame=CGRectMake(0, giftDetails.frame.origin.y+giftDetails.frame.size.height+3, 320, 373);
    
    [giftDetailsScroll setContentSize:CGSizeMake(320, giftOptionsListBgView.frame.origin.y+giftOptionsListBgView.frame.size.height)];
    
    NSArray *priceArray=[[[giftItemInfo objectForKey:@"GiftItem"] giftPrice] componentsSeparatedByString:@";"];
    
    if([priceArray count]>1){
        ;
        giftPriceLbl.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray objectAtIndex:0],[priceArray objectAtIndex:[priceArray count]-1]];
        
        if([giftItemInfo objectForKey:@"GiftPrice"]){
            priceSelectedLbl.text=[NSString stringWithFormat:@"   %@",[giftItemInfo objectForKey:@"GiftPrice"]];
            NSString *selectedPriceVal=[[giftItemInfo objectForKey:@"GiftPrice"] stringByReplacingOccurrencesOfString:@"$" withString:@""];
            
            [priceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if([obj isEqualToString:selectedPriceVal]){
                    selectedPriceRow=idx;
                    
                }
            }];
            
        }
        else
            priceSelectedLbl.text=[NSString stringWithFormat:@"   $%@",[priceArray objectAtIndex:0]];
    }
    else{
        if(![[[giftItemInfo objectForKey:@"GiftItem"] giftPrice] isEqualToString:@""]){
            giftPriceLbl.text=[NSString stringWithFormat:@"$%@",[[giftItemInfo objectForKey:@"GiftItem"] giftPrice]];
            if([giftItemInfo objectForKey:@"GiftPrice"]){
                priceSelectedLbl.text=[NSString stringWithFormat:@"   %@",[giftItemInfo objectForKey:@"GiftPrice"]];
            }
            else
                priceSelectedLbl.text=[NSString stringWithFormat:@"   $%@",[[giftItemInfo objectForKey:@"GiftItem"] giftPrice]];
        }
        
    }
    if([giftItemInfo objectForKey:@"PersonalMessage"]){
        personalMsgTxtView.text=[giftItemInfo objectForKey:@"PersonalMessage"];
    }
    //Dynamic[fit] label width respected to the size of the text
    CGSize giftPriceLbl_maxsize = CGSizeMake(giftPriceLbl.frame.size.width, giftPriceLbl.frame.size.height);
    CGSize giftPriceLbl_new_size=[giftPriceLbl.text sizeWithFont:giftPriceLbl.font constrainedToSize:giftPriceLbl_maxsize lineBreakMode:UILineBreakModeTailTruncation];
    giftPriceLbl.frame=CGRectMake(giftPriceLbl.frame.origin.x, giftPriceLbl.frame.origin.y, giftPriceLbl_new_size.width, giftPriceLbl.frame.size.height);
    
    
    shippingCostLbl.frame= CGRectMake(giftPriceLbl.frame.origin.x+3+giftPriceLbl.frame.size.width, shippingCostLbl.frame.origin.y, shippingCostLbl.frame.size.width, shippingCostLbl.frame.size.height);
    
    [dateLabel.layer setCornerRadius:6.0];
    [dateLabel.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [dateLabel.layer setBorderWidth:1.0];
    
    
    monthsArray=[[NSMutableArray alloc]init];
    daysArray=[[NSMutableArray alloc]init];
    
    UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomInOutForCards:)];
    tapRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    giftTitleInZoomScreen.text=[[giftItemInfo objectForKey:@"GiftItem"] giftTitle];
    
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
    [zoomDoneBtn.layer setBorderColor:[[UIColor blackColor]CGColor]];
    [zoomDoneBtn.layer setBorderWidth:1.0];
    [zoomDoneBtn.layer setCornerRadius:5.0];
}
-(void)zoomInOutForCards:(UITapGestureRecognizer*)tapRecog{
    
    CGPoint tapLocation=[tapRecog locationInView:giftDetailsScroll];
    
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
        
        if(CGRectContainsPoint(giftImg.frame, tapLocation))
        {
            
            GGLog(NSStringFromCGRect(self.view.bounds));
            
            zoomScrollView=[[GfitZoomInView alloc]initWithFrame:[self.view bounds]];
            zoomScrollView.theContainerView.image=giftImg.image;
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
            
        }
        
    }
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
    ImageLoader_Q=dispatch_queue_create("Gift card picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSString *urlStr=[[giftItemInfo objectForKey:@"GiftItem"] giftImageUrl];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                giftImg.image=thumbnail;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
- (IBAction)backToListOfGifts:(id)sender {
    giftItemInfo=nil;
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
        CGRect origFrame=priceRangePickerBgView.frame;//CGRectMake(0, 220, 320, 260);
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        priceRangePickerBgView.frame=origFrame;
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
        CGRect origFrame=electrnicalPhysicalBgView.frame;//CGRectMake(0, 220, 320, 260);
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        electrnicalPhysicalBgView.frame=origFrame;
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
    //giftDetailsScroll.userInteractionEnabled=NO;
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
    
    [giftItemInfo setObject:[priceSelectedLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]forKey:@"GiftPrice"];
    if([[sendMediaLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"Electronically"]){
        [giftItemInfo setValue:[NSNumber numberWithBool:YES]  forKey:@"IsSendElectronically"];
    }
    else
         [giftItemInfo setValue:[NSNumber numberWithBool:NO] forKey:@"IsSendElectronically"];
   
    [giftItemInfo setObject:[personalMsgTxtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
    [giftItemInfo setObject:[NSString stringWithFormat:@"%d-%d-%d",year,selectedMonth,selectedDay] forKey:@"DateOfDelivery"];
    
    
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        
        SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
        /*if([[sendMediaLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"Electronically"]){
            sendOptions.isSendElectronically=YES;
        }
        else
            sendOptions.isSendElectronically=NO;*/
        sendOptions.isSendElectronically=[[giftItemInfo valueForKey:@"IsSendElectronically"] boolValue];
        NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
        [giftAndSenderInfo setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] forKey:@"RecipientName"];
        [giftAndSenderInfo setObject:eventNameLbl.text forKey:@"EventName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftId] forKey:@"GiftID"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftTitle] forKey:@"GiftName"];
        [giftAndSenderInfo setObject:[[giftItemInfo objectForKey:@"GiftItem"] giftImageUrl] forKey:@"GiftImgUrl"];
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"GiftPrice"] forKey:@"GiftPrice"];
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"PersonalMessage"] forKey:@"PersonalMessage"];
        [giftAndSenderInfo setObject:[giftItemInfo objectForKey:@"DateOfDelivery"]  forKey:@"DateOfDelivery"];
        
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
            AlertWithMessageAndDelegateActionHandling(@"GiftGiv", @"Login facebook and select an event to celebrate", [NSArray arrayWithObjects:@"Cancel",@"Login", nil], self);   
        }
        
        
        
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==1){
        
        [fb_giftgiv_detailsScreen authorizeOurAppWithFacebook];
    }
}
#pragma mark -
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
    [self setShippingCostLbl:nil];
    [self setGiftTitleInZoomScreen:nil];
    [self setZoomDoneBtn:nil];
    [self setDetailsTxtLbl:nil];
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
    [giftTitleInZoomScreen release];
    [zoomDoneBtn release];
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
    [shippingCostLbl release];
    [_detailsTxtLbl release];
    [fb_giftgiv_detailsScreen release];
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
