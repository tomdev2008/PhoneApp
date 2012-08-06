//
//  OrderHistoryDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "OrderHistoryDetailsVC.h"

@implementation OrderHistoryDetailsVC
@synthesize statusLbl;
@synthesize mailGiftToLbl;
@synthesize giftImg;
@synthesize askAgainBtn;
@synthesize askAddressLbl;
@synthesize orderDetailsScroll;
@synthesize giftNameLbl;
@synthesize statusHeadLbl;
@synthesize statusDateLbl;
@synthesize recipientAddressHeadLbl;
@synthesize profilePic;
@synthesize messageLbl;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize giftPriceLbl;
@synthesize addressLbl;

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
    
    orderDetailsScroll.frame=CGRectMake(0, 44, 320, 416);
    [self.view addSubview:orderDetailsScroll];
    
    
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(57, 12, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 12, eventName_newSize.width, 21);
    
    
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [messageLbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    messageLbl.frame=CGRectMake(messageLbl.frame.origin.x, messageLbl.frame.origin.y, 280.0, labelSize.height);
    
    recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, messageLbl.frame.origin.y+messageLbl.frame.size.height+10, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    
    statusHeadLbl.frame=CGRectMake(statusHeadLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, statusHeadLbl.frame.size.width, statusHeadLbl.frame.size.height);
    statusDateLbl.frame=CGRectMake(statusDateLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, statusDateLbl.frame.size.width, statusDateLbl.frame.size.height);
    statusLbl.frame=CGRectMake(statusLbl.frame.origin.x, statusHeadLbl.frame.origin.y+statusHeadLbl.frame.size.height-3, statusLbl.frame.size.width, statusLbl.frame.size.height);
    
    // askAddressLbl,askAgainBtn will be visible only if the order is of type Email/SMS
    
    askAddressLbl.frame=CGRectMake(askAddressLbl.frame.origin.x, statusLbl.frame.origin.y+statusLbl.frame.size.height+13, askAddressLbl.frame.size.width, askAddressLbl.frame.size.height);
    
    askAgainBtn.frame=CGRectMake(askAgainBtn.frame.origin.x, askAddressLbl.frame.origin.y+askAddressLbl.frame.size.height+10, askAgainBtn.frame.size.width, askAgainBtn.frame.size.height);
    
    //The scroll content size has to change respected to statusLbl or askAddressLbl based on the Order type (Email/SMS)
    orderDetailsScroll.contentSize=CGSizeMake(320, askAgainBtn.frame.origin.y+askAgainBtn.frame.size.height+10);
    
    
    
}
- (IBAction)backToOrdersList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingsAction:(id)sender {
    SettingsVC *settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}
#pragma mark -

- (void)viewDidUnload
{
    [self setOrderDetailsScroll:nil];
    [self setProfilePic:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftPriceLbl:nil];
    [self setAddressLbl:nil];
    [self setMessageLbl:nil];
    [self setStatusDateLbl:nil];
    [self setRecipientAddressHeadLbl:nil];
    [self setStatusHeadLbl:nil];
    [self setGiftNameLbl:nil];
    [self setStatusLbl:nil];
    [self setAskAddressLbl:nil];
    [self setMailGiftToLbl:nil];
    [self setGiftImg:nil];
    [self setAskAgainBtn:nil];
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
    [orderDetailsScroll release];
    [profilePic release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftPriceLbl release];
    [addressLbl release];
    [messageLbl release];
    [statusDateLbl release];
    [recipientAddressHeadLbl release];
    [statusHeadLbl release];
    [giftNameLbl release];
    [statusLbl release];
    [askAddressLbl release];
    [mailGiftToLbl release];
    [giftImg release];
    [askAgainBtn release];
    [super dealloc];
}
- (IBAction)askAgainAction:(id)sender {
    // Send a request to ask the address
}
@end
