//
//  GiftSummaryVC.m
//  GiftGiv
//
//  Created by Srinivas G on 01/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftSummaryVC.h"

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
    
    profileNameLbl.text=[giftSummaryDict objectForKey:@"RecipientName"];
    eventNameLbl.text=[giftSummaryDict objectForKey:@"EventName"];
    giftNameLbl.text=[giftSummaryDict objectForKey:@"GiftName"];
    giftPriceLbl.text=[giftSummaryDict objectForKey:@"GiftPrice"];
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
    profileNameLbl.frame=CGRectMake(57, 12, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 12, eventName_newSize.width, 21);
    
    
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
- (IBAction)backToRecipientForm:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)paymentBtnAction:(id)sender {
    SuccessVC *success=[[SuccessVC alloc]initWithNibName:@"SuccessVC" bundle:nil];
    [self.navigationController pushViewController:success animated:YES];
    [success release];
}
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
    [super dealloc];
}
@end
