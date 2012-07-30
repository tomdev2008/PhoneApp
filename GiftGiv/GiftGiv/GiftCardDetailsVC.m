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
@synthesize priceListArray;

@synthesize prevNextSegmentControl;
@synthesize pricePicker;

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
    // Do any additional setup after loading the view from its nib.
    
    //profilePic.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
    //giftImg.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
    giftDetailsScroll.frame=CGRectMake(0, 44, 320,416);
    [self.view addSubview:giftDetailsScroll];
    
    [giftDetailsScroll setContentSize:CGSizeMake(320, 536)];
    personalMsgTxtView.inputAccessoryView=messageInputAccessoryView;
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(57, 12, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 12, eventName_newSize.width, 21);
    priceListArray =[[NSMutableArray alloc]initWithObjects:@"$10",@"$20",@"$30",@"$40",@"$50",@"$60",@"$70",@"$80",@"$90", nil];
    
    
    [priceSelectedLbl.layer setCornerRadius:6.0];
    [priceSelectedLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [priceSelectedLbl.layer setBorderWidth:1.0];
    
    [sendMediaLbl.layer setCornerRadius:6.0];
    [sendMediaLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [sendMediaLbl.layer setBorderWidth:1.0];
    
    [personalMsgTxtView.layer setCornerRadius:6.0];
    [personalMsgTxtView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [personalMsgTxtView.layer setBorderWidth:1.0];
    
    
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
	
    pt.y-=15;
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
    giftDetailsScroll.userInteractionEnabled=NO;
    UIActionSheet *mediaActions=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Electronically",@"Physically", nil];
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
	[giftDetailsScroll setContentOffset:pt animated:YES];
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
    SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
    if([[sendMediaLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"Electronically"]){
        sendOptions.isSendElectronically=YES;
    }
    else
        sendOptions.isSendElectronically=NO;
    NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
    [giftAndSenderInfo setObject:@"BONNIE GIESEN" forKey:@"RecipientName"];
    [giftAndSenderInfo setObject:@"birthday" forKey:@"EventName"];
    [giftAndSenderInfo setObject:@"12345" forKey:@"GiftID"];
    [giftAndSenderInfo setObject:@"Birthday card" forKey:@"GiftName"];
    [giftAndSenderInfo setObject:[priceSelectedLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]forKey:@"GiftPrice"];
    [giftAndSenderInfo setObject:[personalMsgTxtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
        
    [giftAndSenderInfo release];
    [self.navigationController pushViewController:sendOptions animated:YES];
    [sendOptions release];
}
#pragma mark - Actionsheet delegate
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
    
    
    priceSelectedLbl.text=[NSString stringWithFormat:@"   %@",[priceListArray objectAtIndex:selectedPriceRow]];
    
}
#pragma mark - PickerViewDatasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	
	return [priceListArray count];
    
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
    //customized view for the picker with check mark as selection
    
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
    
    [(UILabel*)[view viewWithTag:999] setText:[NSString stringWithFormat:@"  %@",[priceListArray objectAtIndex:row]]];
    
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
#pragma mark -
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
    [super dealloc];
}

@end
