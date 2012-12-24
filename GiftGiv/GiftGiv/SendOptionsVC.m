//
//  SendOptionsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SendOptionsVC.h"

@implementation SendOptionsVC
@synthesize sendOptionsContentScroll;
@synthesize confirmBtnLbl;
@synthesize confirmBtn;
@synthesize isSendElectronically;
@synthesize zipBgView;
@synthesize zipTxtFld;
@synthesize recipientSMSContentView;
@synthesize phoneNumBgView;
@synthesize emailsText;
@synthesize phoneNumTxtFld;
@synthesize emailBgView;
@synthesize emailTxtFld;
@synthesize keyboardAccessoryView;
@synthesize recipientemailContentView;
@synthesize recipientAddressContentView;
@synthesize streeAddress_oneBgView;
@synthesize streeAddress_oneTxtFld;
@synthesize streetAddress_twoBgView;
@synthesize streetAddress_twoTxtFld;
@synthesize cityBgView;
@synthesize cityTxtFld;
@synthesize stateLbl;
@synthesize addressEmailSMSSelPickerBgView;
@synthesize addressMailSMSPicker;
@synthesize addEmailSMSSegment;
@synthesize profilePic;
@synthesize statePickerBgView;
@synthesize stateSelSegmentCntl;
@synthesize statesPicker;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize recipientAddressLbl;
@synthesize sendingInfoDict;

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
   
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
    
    
    profileNameLbl.text=[[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] uppercaseString];
    emailTxtFld.text=[self getEmailAddressOfRecipient:profileNameLbl.text];
    phoneNumTxtFld.text=[self getPhoneNumOfRecipient:profileNameLbl.text];
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
    if([[UIScreen mainScreen] bounds].size.height == 568)
        sendOptionsContentScroll.frame=CGRectMake(0, 44, 320, 416+88);
    else{
        sendOptionsContentScroll.frame=CGRectMake(0, 44, 320, 416);
    }
    
    [self.view addSubview:sendOptionsContentScroll];
    
    //list of states (postal abbreviations) collected from http://www.stateabbreviations.us/
    
    listOfStates=[[NSMutableArray alloc]initWithArray:[[NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ListOfStates" ofType:@"plist"]] objectForKey:@"StateCodes"]];   
    listOfSendOptions=[[NSMutableArray alloc]initWithCapacity:2];
    
    
    if(isSendElectronically){
        
        [listOfSendOptions addObject:@"Recipient email address"];
        
        [listOfSendOptions addObject:@"Text recipient for address"];
        recipientAddressLbl.text=@"   Recipient email address";
        [self refreshTheFormForOption:1];
        
    }
    else{
        
        if([[sendingInfoDict objectForKey:@"GiftPrice"] isEqualToString:@""]){
            _whereShouldWeLbl.text=@"Where should we send your message?";
            recipientAddressLbl.text=@"   Post on wall";
            [listOfSendOptions addObject:@"Post on wall"];
            [listOfSendOptions addObject:@"Recipient email address"];
            [listOfSendOptions addObject:@"Text recipient number"];
            [self refreshTheFormForOption:3];
            
        }
        else{
            [listOfSendOptions addObject:@"I know the address"];
            [listOfSendOptions addObject:@"Email recipient for address"];
            [listOfSendOptions addObject:@"Text recipient for address"];
            recipientAddressLbl.text=@"   I know the address";
            [self refreshTheFormForOption:0];
        }
        
        
        
        
    }
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    
    
    [recipientAddressLbl.layer setCornerRadius:6.0];
    [recipientAddressLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [recipientAddressLbl.layer setBorderWidth:1.0];
    
    [streeAddress_oneBgView.layer setCornerRadius:6.0];
    [streeAddress_oneBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [streeAddress_oneBgView.layer setBorderWidth:1.0];
    
    [streetAddress_twoBgView.layer setCornerRadius:6.0];
    [streetAddress_twoBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [streetAddress_twoBgView.layer setBorderWidth:1.0];
    
    [cityBgView.layer setCornerRadius:6.0];
    [cityBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [cityBgView.layer setBorderWidth:1.0];
    
    [stateLbl.layer setCornerRadius:6.0];
    [stateLbl.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [stateLbl.layer setBorderWidth:1.0];
    
    [zipBgView.layer setCornerRadius:6.0];
    [zipBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [zipBgView.layer setBorderWidth:1.0];
    
    [phoneNumBgView.layer setCornerRadius:6.0];
    [phoneNumBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [phoneNumBgView.layer setBorderWidth:1.0];
    
    [emailBgView.layer setCornerRadius:6.0];
    [emailBgView.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [emailBgView.layer setBorderWidth:1.0];
    
    
    zipTxtFld.inputAccessoryView=keyboardAccessoryView;
    
}
-(NSString*)getEmailAddressOfRecipient:(NSString*)contactName{
    ABAddressBookRef allPeople = ABAddressBookCreate();
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    
    for(int i = 0; i < numberOfContacts; i++){
        NSString* name = @"";
        NSString* email = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray = (NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        
        CFRelease(emailProperty);
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
             CFRelease(fnameProperty);
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
            CFRelease(lnameProperty);
        }
       
        if([name caseInsensitiveCompare:contactName]==NSOrderedSame){
            
        
            if ([emailArray count] > 0) {
                if ([emailArray count] > 1) {
                    email = [email stringByAppendingString:[NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]]];
                    
                }else {
                    email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
                }
            }
            [emailArray release];
            CFRelease(allContacts);
            CFRelease(allPeople);
            return email;
        }
        [emailArray release];
        
        
    }
    
    CFRelease(allContacts);
    CFRelease(allPeople);
    return @"";
}
-(NSString*)getPhoneNumOfRecipient:(NSString*)contactName{
    ABAddressBookRef allPeople = ABAddressBookCreate();
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    
    for(int i = 0; i < numberOfContacts; i++){
        NSString* name = @"";
        NSString* phone = @"";
               
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        
        NSArray *phoneArray = (NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        CFRelease(phoneProperty);
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
            CFRelease(fnameProperty);
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
            CFRelease(lnameProperty);
        }
        
        
        
        if([name caseInsensitiveCompare:contactName]==NSOrderedSame){
            
            
            if ([phoneArray count] > 0) {
                if ([phoneArray count] > 1) {
                    for (int i = 0; i < [phoneArray count]; i++) {
                        phone = [phone stringByAppendingString:[NSString stringWithFormat:@"%@\n", [phoneArray objectAtIndex:i]]];
                    }
                }
                else {
                    phone = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:0]];
                }
             }
            [phoneArray release];
            CFRelease(allContacts);
            CFRelease(allPeople);
            return phone;
        }
        
    }
    
    CFRelease(allContacts);
    CFRelease(allPeople);
    return @"";
}
-(void)refreshTheFormForOption:(int)optionIndex{
    
    if([sendingInfoDict objectForKey:@"RecipientMailID"])
        [sendingInfoDict removeObjectForKey:@"RecipientMailID"];
    if([sendingInfoDict objectForKey:@"RequestMessage"])
        [sendingInfoDict removeObjectForKey:@"RequestMessage"];
    if([sendingInfoDict objectForKey:@"RecipientPhoneNum"])
        [sendingInfoDict removeObjectForKey:@"RecipientPhoneNum"];
    if([sendingInfoDict objectForKey:@"RecipientAddress"])
        [sendingInfoDict removeObjectForKey:@"RecipientAddress"];
    if([_wallPostDescription superview])
        [_wallPostDescription removeFromSuperview];
    
    switch (optionIndex) {
            //address
        case 0:
            if([recipientSMSContentView superview])
                [recipientSMSContentView removeFromSuperview];
            if([recipientemailContentView superview]){
                [recipientemailContentView removeFromSuperview];
                
            }
            if(![recipientAddressContentView superview]){
                recipientAddressContentView.frame=CGRectMake(23, 166, 275, 317);
                [sendOptionsContentScroll addSubview:recipientAddressContentView];
                
            }
            
            CGRect confirmBtnFrame_Address=confirmBtn.frame;
            confirmBtnFrame_Address.origin.y=505;
            confirmBtn.frame=confirmBtnFrame_Address;
            
            CGRect confirmLblFrame_Address=confirmBtnLbl.frame;
            confirmLblFrame_Address.origin.y=511;
            confirmBtnLbl.frame=confirmLblFrame_Address;
            
            sendOptionsContentScroll.contentSize=CGSizeMake(320, 556);
            break;
            //mail
        case 1:
            if([recipientAddressContentView superview]){
                [recipientAddressContentView removeFromSuperview];
            }
            if([recipientSMSContentView superview])
                [recipientSMSContentView removeFromSuperview];
            if(![recipientemailContentView superview]){
                if(isSendElectronically){
                    emailsText.text=@"Please provide recipient's email address. We will send the gift to that address.";
                }
                else
                    emailsText.text=@"We'll send an email to your recipient to securely ask for their mailing address. Don't worry: we won't give away the surprise.";
                
                recipientemailContentView.frame=CGRectMake(23, 166, 275, 140);
                [sendOptionsContentScroll addSubview:recipientemailContentView];
            }
            if([statePickerBgView superview]){
                [statePickerBgView removeFromSuperview];
            }
            //requestMsgTxtView.frame=CGRectMake(23, 320, 275 , 82);
            //[sendOptionsContentScroll addSubview:requestMsgTxtView];
            
            CGRect confirmBtnFrame_email=confirmBtn.frame;
            confirmBtnFrame_email.origin.y=364;
            confirmBtn.frame=confirmBtnFrame_email;
            
            CGRect confirmLblFrame_email=confirmBtnLbl.frame;
            confirmLblFrame_email.origin.y=370;
            confirmBtnLbl.frame=confirmLblFrame_email;
            sendOptionsContentScroll.contentSize=CGSizeMake(320, 416);
            break;
            //sms
        case 2:
            if([recipientAddressContentView superview])
                [recipientAddressContentView removeFromSuperview];
            if([recipientemailContentView superview]){
                [recipientemailContentView removeFromSuperview];
                
            }
            if([statePickerBgView superview]){
                [statePickerBgView removeFromSuperview];
            }
            if(![recipientSMSContentView superview]){
                recipientSMSContentView.frame=CGRectMake(23, 166, 275, 130);
                [sendOptionsContentScroll addSubview:recipientSMSContentView];
                
            }
            CGRect confirmBtnFrame_sms=confirmBtn.frame;
            confirmBtnFrame_sms.origin.y=364;
            confirmBtn.frame=confirmBtnFrame_sms;
            
            CGRect confirmLblFrame_sms=confirmBtnLbl.frame;
            confirmLblFrame_sms.origin.y=370;
            confirmBtnLbl.frame=confirmLblFrame_sms;
            sendOptionsContentScroll.contentSize=CGSizeMake(320, 416);
            break;
            
            //Wall posting
        case 3:
            if([recipientSMSContentView superview])
                [recipientSMSContentView removeFromSuperview];
            if([recipientemailContentView superview])
                [recipientemailContentView removeFromSuperview];
            
            _wallPostDescription.frame=CGRectMake(23, 161, 275, 80);
            [sendOptionsContentScroll addSubview:_wallPostDescription];
            
            sendOptionsContentScroll.contentSize=CGSizeMake(320, 416);
            
            break;
            
    }
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
    
    svos = sendOptionsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textField  bounds];
	rc = [textField  convertRect:rc toView:sendOptionsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[sendOptionsContentScroll setContentOffset:pt animated:YES];
    //sendOptionsContentScroll.userInteractionEnabled=NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField isEqual:emailTxtFld]){
		emailTxtFld.text=[emailTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![emailTxtFld.text isEqualToString:@""]){
            if(![self validateMail:emailTxtFld.text]){
                //emailTxtFld.textColor=[UIColor redColor];
                AlertWithMessageAndDelegate(@"GiftGiv", @"Invalid email address", nil);
            }
        }
        
	}
    [sendOptionsContentScroll setContentOffset:svos animated:YES];
    sendOptionsContentScroll.userInteractionEnabled=YES;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    //sendOptionsContentScroll.userInteractionEnabled=NO;
    svos = sendOptionsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [textView bounds];
	rc = [textView convertRect:rc toView:sendOptionsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=65;
	[sendOptionsContentScroll setContentOffset:pt animated:YES];
}

#pragma mark - PickerViewDatasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if([pickerView isEqual:statesPicker])
        return [listOfStates count];
    else{
        return [listOfSendOptions count];
               
    }
    
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
    //customized view for the picker with check mark as selection
    if([pickerView isEqual:statesPicker]){
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
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stateSelectedByPicker:)];
            [tapGesture setNumberOfTapsRequired:1];
            [view addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            [view addSubview:checkMarkLbl];
            [view addSubview:priceLabel];
            
            [priceLabel release];
            [checkMarkLbl release];
            
            
        }
        view.tag=row;
        if(row==selectedStateRow){
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor colorWithRed:0.274 green:0.51 blue:0.71 alpha:1.0]];
            
        }
        else{
            [(UILabel*)[view viewWithTag:999] setTextColor:[UIColor blackColor]];        
        }
        
        [(UILabel*)[view viewWithTag:999] setText:[NSString stringWithFormat:@"  %@",[listOfStates objectAtIndex:row]]];
        
        for(UIView *subview in [view subviews]){
            if([subview isKindOfClass:[UILabel class]]){
                if([(UILabel*)subview viewWithTag:888]){
                    if(row==selectedStateRow)
                        [(UILabel*)subview setText:@"✓"];
                    else
                        [(UILabel*)subview setText:@""];
                }
                
            }
            
        }
        
        return view;
    }
    else{
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
	
    
}
#pragma mark -
-(void)stateSelectedByPicker:(UITapGestureRecognizer*)sender{
    
    selectedStateRow=[sender.view tag];
    [statesPicker selectRow:selectedStateRow inComponent:0 animated:YES];
    
    [statesPicker reloadComponent:0];
    
    if(selectedStateRow>0 && selectedStateRow<[listOfStates count]-1){
        [stateSelSegmentCntl setEnabled:YES forSegmentAtIndex:0];
        [stateSelSegmentCntl setEnabled:YES forSegmentAtIndex:1];
        
    }
    
    else if(selectedStateRow==0){
        [stateSelSegmentCntl setEnabled:NO forSegmentAtIndex:0];
        [stateSelSegmentCntl setEnabled:YES forSegmentAtIndex:1];
    }
    else if(selectedStateRow==[listOfStates count]-1){
        [stateSelSegmentCntl setEnabled:YES forSegmentAtIndex:0];
        [stateSelSegmentCntl setEnabled:NO forSegmentAtIndex:1];
    }
    
}
-(void)addressOptionSelectedByPicker:(UITapGestureRecognizer*)sender{
    
    selectedSendOptionRow=[sender.view tag];
    [addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    
    [addressMailSMSPicker reloadComponent:0];
    
    if(selectedSendOptionRow>0 && selectedSendOptionRow<[listOfSendOptions count]-1){
        [addEmailSMSSegment setEnabled:YES forSegmentAtIndex:0];
        [addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
        
    }
    
    else if(selectedSendOptionRow==0){
        [addEmailSMSSegment setEnabled:NO forSegmentAtIndex:0];
        [addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
    }
    else if(selectedSendOptionRow==[listOfSendOptions count]-1){
        [addEmailSMSSegment setEnabled:YES forSegmentAtIndex:0];
        [addEmailSMSSegment setEnabled:NO forSegmentAtIndex:1];
    }
    
}

- (IBAction)recipientAddressOptionAction:(id)sender {
    
    
    for(UIView *subview in [sendOptionsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    sendOptionsContentScroll.userInteractionEnabled=NO;
    svos = sendOptionsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [recipientAddressLbl bounds];
	rc = [recipientAddressLbl convertRect:rc toView:sendOptionsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=15;
	[sendOptionsContentScroll setContentOffset:pt animated:YES];
    if(addressEmailSMSSelPickerBgView.hidden)
        addressEmailSMSSelPickerBgView.hidden=NO;
    if(![addressEmailSMSSelPickerBgView superview]){
        CGRect origFrame=addressEmailSMSSelPickerBgView.frame;
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        addressEmailSMSSelPickerBgView.frame=origFrame;
        [self.view.window addSubview:addressEmailSMSSelPickerBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [addressEmailSMSSelPickerBgView.layer addAnimation:animation forKey:@"animation"];
    [addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    if(selectedSendOptionRow==0){
        [addEmailSMSSegment setEnabled:NO forSegmentAtIndex:0];
        [addEmailSMSSegment setEnabled:YES forSegmentAtIndex:1];
    }
    
    /*UIActionSheet *mediaActions=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    if(!isSendElectronically)
        [mediaActions addButtonWithTitle:@"I know the address"];
    if(isSendElectronically)
        [mediaActions addButtonWithTitle:@"Recipient email address"];
    else
        [mediaActions addButtonWithTitle:@"Email recipient for address"];
    [mediaActions addButtonWithTitle:@"SMS recipient for address"];
    [mediaActions addButtonWithTitle:@"Cancel"];
    mediaActions.cancelButtonIndex = mediaActions.numberOfButtons - 1;
    [mediaActions showInView:self.view];
    [mediaActions release];*/
}
/*#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
            
        case 0:
            if(isSendElectronically){
                [self refreshTheFormForOption:1];
                //recipientAddressLbl.text=@"   Email recipient for address";
            }
            else{
                [self refreshTheFormForOption:0];
                //recipientAddressLbl.text=@"   I know the address";
            }
            recipientAddressLbl.text=[NSString stringWithFormat:@"   %@",[actionSheet buttonTitleAtIndex:buttonIndex]];
            break;
            
        case 1:
            if(isSendElectronically){
                [self refreshTheFormForOption:2];
                //recipientAddressLbl.text=@"   SMS recipient for address";
            }
            else{
                [self refreshTheFormForOption:1];
                //recipientAddressLbl.text=@"   Email recipient for address";
            }
            recipientAddressLbl.text=[NSString stringWithFormat:@"   %@",[actionSheet buttonTitleAtIndex:buttonIndex]];
            break;
            //SMS
        case 2:
            if(!isSendElectronically){
                [self refreshTheFormForOption:2];
                recipientAddressLbl.text=[NSString stringWithFormat:@"   %@",[actionSheet buttonTitleAtIndex:buttonIndex]];
                //recipientAddressLbl.text=@"   SMS recipient for address";
            }
            
            break;
    }
    
    //[giftDetailsScroll setContentOffset:svos animated:YES];
    //giftDetailsScroll.userInteractionEnabled=YES;
}
#pragma mark -*/
- (IBAction)stateSelectionAction:(id)sender {
    for(UIView *subview in [sendOptionsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:NO];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:NO];
        }
    }
    sendOptionsContentScroll.userInteractionEnabled=NO;
    svos = sendOptionsContentScroll.contentOffset;
	CGPoint pt;
	CGRect rc = [stateLbl bounds];
	rc = [stateLbl convertRect:rc toView:sendOptionsContentScroll];
	pt = rc.origin;
	pt.x = 0;
	
    pt.y-=15;
	[sendOptionsContentScroll setContentOffset:pt animated:YES];
    if(statePickerBgView.hidden)
        statePickerBgView.hidden=NO;
    if(![statePickerBgView superview]){
        CGRect origFrame=statePickerBgView.frame;
        origFrame.origin.y=(self.view.frame.size.height - origFrame.size.height)+20;
        statePickerBgView.frame=origFrame;
        [self.view.window addSubview:statePickerBgView];
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    [statePickerBgView.layer addAnimation:animation forKey:@"animation"];
    [statesPicker selectRow:selectedStateRow inComponent:0 animated:YES];
    if(selectedStateRow==0){
        [stateSelSegmentCntl setEnabled:NO forSegmentAtIndex:0];
        [stateSelSegmentCntl setEnabled:YES forSegmentAtIndex:1];
    }
}
- (IBAction)resignKeyboardAction:(id)sender {
    
    if([zipTxtFld isFirstResponder])
        [zipTxtFld resignFirstResponder];
    if([phoneNumTxtFld isFirstResponder])
        [phoneNumTxtFld resignFirstResponder];
    
    [sendOptionsContentScroll setContentOffset:svos animated:YES];
    sendOptionsContentScroll.userInteractionEnabled=YES;
}

- (IBAction)backToGiftDetailsScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)confirmScreenAction:(id)sender {
    [sendingInfoDict setObject:[NSNumber numberWithBool:isSendElectronically] forKey:@"IsElectronicSending"];
    if([recipientemailContentView superview]){
        if(![emailTxtFld.text isEqualToString:@""]){
            if([self validateMail:emailTxtFld.text]){
                //Push the next screen (gift summary)
                GiftSummaryVC *giftSummary=[[GiftSummaryVC alloc]initWithNibName:@"GiftSummaryVC" bundle:nil];
                
                [sendingInfoDict setObject:[emailTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"RecipientMailID"];
                giftSummary.giftSummaryDict=sendingInfoDict;
                [self.navigationController pushViewController:giftSummary animated:YES];
                [giftSummary release];
                
            }
            else
                AlertWithMessageAndDelegate(@"GiftGiv", @"Invalid email address", nil);
        }
        else{
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please provide recipient's email address", nil);
        }
    }
    else if([recipientSMSContentView superview]){
        phoneNumTxtFld.text=[phoneNumTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![phoneNumTxtFld.text isEqualToString:@""]){
            //push the next screen (gift summary)
            GiftSummaryVC *giftSummary=[[GiftSummaryVC alloc]initWithNibName:@"GiftSummaryVC" bundle:nil];
            [sendingInfoDict setObject:[phoneNumTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"RecipientPhoneNum"];
            giftSummary.giftSummaryDict=sendingInfoDict;
            [self.navigationController pushViewController:giftSummary animated:YES];
            [giftSummary release];
            
        }
        else{
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please provide a recipient phone number", nil);
        }
    }
    else if([recipientAddressContentView superview]){
        streeAddress_oneTxtFld.text=[streeAddress_oneTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        streetAddress_twoTxtFld.text=[streetAddress_twoTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        cityTxtFld.text=[cityTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        zipTxtFld.text=[zipTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([streeAddress_oneTxtFld.text isEqualToString:@""]||[cityTxtFld.text isEqualToString:@""]||[zipTxtFld.text isEqualToString:@""]){
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please provide all details", nil);
        }
        else{
            //push the next screen (gift summary)
            GiftSummaryVC *giftSummary=[[GiftSummaryVC alloc]initWithNibName:@"GiftSummaryVC" bundle:nil];
            NSString *address=[NSString stringWithFormat:@"%@, ",streeAddress_oneTxtFld.text];
            if(![streetAddress_twoTxtFld.text isEqualToString:@""])
                address=[address stringByAppendingFormat:@"%@,",streetAddress_twoTxtFld.text];
            address=[address stringByAppendingFormat:@"%@, ",[cityTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            address=[address stringByAppendingFormat:@"%@, ",[stateLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            address=[address stringByAppendingFormat:@"%@, ",zipTxtFld.text];
            
            [sendingInfoDict setObject:address forKey:@"RecipientAddress"];
            
            giftSummary.giftSummaryDict=sendingInfoDict;
            [self.navigationController pushViewController:giftSummary animated:YES];
            [giftSummary release];
        }
        
    }
    //Treat this as posting on wall for free gift items
    else if([[sendingInfoDict objectForKey:@"GiftPrice"] isEqualToString:@""]){
        GiftSummaryVC *giftSummary=[[GiftSummaryVC alloc]initWithNibName:@"GiftSummaryVC" bundle:nil];
        [sendingInfoDict setObject:@"Yes" forKey:@"WallPost"];
        giftSummary.giftSummaryDict=sendingInfoDict;
        [self.navigationController pushViewController:giftSummary animated:YES];
        [giftSummary release];
    }
}
- (IBAction)stateSelectionDone:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [statePickerBgView.layer addAnimation:animation forKey:@"animation"];
    statePickerBgView.hidden=YES;
    [sendOptionsContentScroll setContentOffset:svos animated:YES];
    sendOptionsContentScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [sendOptionsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:YES];
        }
    }
    
    
    stateLbl.text=[NSString stringWithFormat:@"   %@",[listOfStates objectAtIndex:selectedStateRow]];
}

- (IBAction)stateSelectionNavigatorActions:(id)sender {
    switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
            //previous
        case 0:
            
            if(selectedStateRow>0){
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:1];
                selectedStateRow--;                
            }
            
            if(selectedStateRow==0){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:0];
            }
            
            break;
            //next
        case 1:
            if(selectedStateRow<[listOfStates count]-1){
                selectedStateRow++;
                [(UISegmentedControl*)sender setEnabled:YES forSegmentAtIndex:0];
                
            }
            
            if(selectedStateRow==[listOfStates count]-1){
                [(UISegmentedControl*)sender setEnabled:NO forSegmentAtIndex:1];
            }
            
            break;
            
            
    }
    [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [statesPicker selectRow:selectedStateRow inComponent:0 animated:YES];
    [statesPicker reloadComponent:0];
}
#pragma mark -
- (IBAction)addressEmailSMSSelDoneAction:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    [addressEmailSMSSelPickerBgView.layer addAnimation:animation forKey:@"animation"];
    addressEmailSMSSelPickerBgView.hidden=YES;
    
    sendOptionsContentScroll.userInteractionEnabled=YES;
    
    for(UIView *subview in [sendOptionsContentScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setUserInteractionEnabled:YES];
        }
        if([subview isKindOfClass:[UITextField class]]){
            [(UITextField*)subview setUserInteractionEnabled:YES];
        }
    }
    
    
    recipientAddressLbl.text=[NSString stringWithFormat:@"   %@",[listOfSendOptions objectAtIndex:selectedSendOptionRow]];

    BOOL isFreeGiftItem=NO;
    
    if([[sendingInfoDict objectForKey:@"GiftPrice"] isEqualToString:@""]){
        isFreeGiftItem=YES;
    }
    
    switch (selectedSendOptionRow) {
            
        case 0:
            
            if(isSendElectronically){
                [self refreshTheFormForOption:1];
                
            }
            else{
                if(isFreeGiftItem)
                    [self refreshTheFormForOption:3];
                else
                    [self refreshTheFormForOption:0];
                
            }
            
            break;
            
        case 1:
            if(isSendElectronically){
                [self refreshTheFormForOption:2];
                
            }
            else{
                
                [self refreshTheFormForOption:1];
                
            }
            
            break;
            //SMS
        case 2:
            if(!isSendElectronically){
                [self refreshTheFormForOption:2];
                
            }
            
            break;
    }
    
    [sendOptionsContentScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
    
    
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
    [addressMailSMSPicker selectRow:selectedSendOptionRow inComponent:0 animated:YES];
    [addressMailSMSPicker reloadComponent:0];
    
}
#pragma mark -
-(void)viewWillDisappear:(BOOL)animated{
    if([addressEmailSMSSelPickerBgView superview])
        [addressEmailSMSSelPickerBgView removeFromSuperview];
    if([statePickerBgView superview])
        [statePickerBgView removeFromSuperview];

    [super viewWillDisappear:animated];
}
- (void)viewDidUnload
{
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setRecipientAddressLbl:nil];
    [self setRecipientAddressContentView:nil];
    [self setStreeAddress_oneBgView:nil];
    [self setStreeAddress_oneTxtFld:nil];
    [self setStreetAddress_twoBgView:nil];
    [self setStreetAddress_twoTxtFld:nil];
    [self setCityBgView:nil];
    [self setCityTxtFld:nil];
    [self setStateLbl:nil];
    [self setZipBgView:nil];
    [self setZipTxtFld:nil];
    [self setRecipientSMSContentView:nil];
    [self setPhoneNumBgView:nil];
    [self setPhoneNumTxtFld:nil];
    [self setRecipientemailContentView:nil];
    [self setEmailBgView:nil];
    [self setEmailTxtFld:nil];
    [self setKeyboardAccessoryView:nil];
    
    [self setSendOptionsContentScroll:nil];
    [self setConfirmBtnLbl:nil];
    [self setConfirmBtn:nil];
    [self setStatePickerBgView:nil];
    [self setStatesPicker:nil];
    [self setStateSelSegmentCntl:nil];
    [self setEmailsText:nil];
    [self setAddressEmailSMSSelPickerBgView:nil];
    [self setAddressMailSMSPicker:nil];
    [self setAddEmailSMSSegment:nil];
    [self setWallPostDescription:nil];
    [self setWhereShouldWeLbl:nil];
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
        
    [listOfSendOptions release];
    [profilePic release];
    [profileNameLbl release];
    [eventNameLbl release];
    [recipientAddressLbl release];
    [recipientAddressContentView release];
    [streeAddress_oneBgView release];
    [streeAddress_oneTxtFld release];
    [streetAddress_twoBgView release];
    [streetAddress_twoTxtFld release];
    [cityBgView release];
    [cityTxtFld release];
    [stateLbl release];
    [zipBgView release];
    [zipTxtFld release];
    [recipientSMSContentView release];
    [phoneNumBgView release];
    [phoneNumTxtFld release];
    [recipientemailContentView release];
    [emailBgView release];
    [emailTxtFld release];
    
    [keyboardAccessoryView release];
    
    [listOfStates release];
    [sendOptionsContentScroll release];
    [confirmBtnLbl release];
    [confirmBtn release];
    [statePickerBgView release];
    [statesPicker release];
    [stateSelSegmentCntl release];
    [sendingInfoDict release];
    [emailsText release];
    [addressEmailSMSSelPickerBgView release];
    [addressMailSMSPicker release];
    [addEmailSMSSegment release];
    [_wallPostDescription release];
    [_whereShouldWeLbl release];
    [super dealloc];
}

@end
