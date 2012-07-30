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

@synthesize keyboardAccessoryView;

@synthesize recipientAddressContentView;
@synthesize streeAddress_oneBgView;
@synthesize streeAddress_oneTxtFld;
@synthesize streetAddress_twoBgView;
@synthesize streetAddress_twoTxtFld;
@synthesize cityBgView;
@synthesize cityTxtFld;
@synthesize stateLbl;
@synthesize profilePic;

@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize recipientAddressLbl;


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
    
    sendOptionsContentScroll.frame=CGRectMake(0, 44, 320, 416);
    [self.view addSubview:sendOptionsContentScroll];
   
    if(isSendElectronically){
        
        recipientAddressLbl.text=@"   E-mail recipient for address";
        [self refreshTheFormForOption:1];
        
    }
    else{
        
        recipientAddressLbl.text=@"   I know the address";
        [self refreshTheFormForOption:0];
        
    }   
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(57, 12, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 12, eventName_newSize.width, 21);
    
   
    
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
    
    
    zipTxtFld.inputAccessoryView=keyboardAccessoryView;
    
}
-(void)refreshTheFormForOption:(int)optionIndex{
    
    
    
    switch (optionIndex) {
            //address
        case 0:
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
            break;
            //sms
        case 2:
            
            break;
 
    }
}
#pragma mark - mail validation

 

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
       
    
    [sendOptionsContentScroll setContentOffset:svos animated:YES];
    sendOptionsContentScroll.userInteractionEnabled=YES;
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)recipientAddressOptionAction:(id)sender {
    
    UIActionSheet *mediaActions=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    if(!isSendElectronically)
        [mediaActions addButtonWithTitle:@"I know the address"];
    [mediaActions addButtonWithTitle:@"E-mail recipient for address"];
    [mediaActions addButtonWithTitle:@"SMS recipient for address"];
    [mediaActions addButtonWithTitle:@"Cancel"];
    mediaActions.cancelButtonIndex = mediaActions.numberOfButtons - 1;
    [mediaActions showInView:self.view];
    [mediaActions release];
}
#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
           
        case 0:
            if(isSendElectronically){
                [self refreshTheFormForOption:1];
                //recipientAddressLbl.text=@"   E-mail recipient for address";
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
                //recipientAddressLbl.text=@"   E-mail recipient for address";
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
#pragma mark -
- (IBAction)stateSelectionAction:(id)sender {
    
}
- (IBAction)resignKeyboardAction:(id)sender {
    
    if([zipTxtFld isFirstResponder])
        [zipTxtFld resignFirstResponder];
    
    [sendOptionsContentScroll setContentOffset:svos animated:YES];
    sendOptionsContentScroll.userInteractionEnabled=YES;
}

- (IBAction)backToGiftDetailsScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)confirmScreenAction:(id)sender {
    
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
    [self setKeyboardAccessoryView:nil];
    
    [self setSendOptionsContentScroll:nil];
    [self setConfirmBtnLbl:nil];
    [self setConfirmBtn:nil];
    
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
   
    [keyboardAccessoryView release];
    
   
    [sendOptionsContentScroll release];
    [confirmBtnLbl release];
    [confirmBtn release];
    
   
    
    [super dealloc];
}
@end
