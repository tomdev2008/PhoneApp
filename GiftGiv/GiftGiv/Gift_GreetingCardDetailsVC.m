//
//  Gift_GreetingCardDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "Gift_GreetingCardDetailsVC.h"

@implementation Gift_GreetingCardDetailsVC
@synthesize giftDetailsContentScroll;
@synthesize profilePic;
@synthesize profileNameLbl;
@synthesize backGreetingImg;
@synthesize eventNameLbl;
@synthesize frontGreetingImg;
@synthesize frontLbl;
@synthesize backLbl;
@synthesize zoomInImgView;
@synthesize greetingNameLbl;
@synthesize flowerImgView;
@synthesize greetingPrice;
@synthesize msgInputAccessoryView;
@synthesize personalMsgTxt;
@synthesize isGreetingCard;

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
        
    if(isGreetingCard){
        flowerImgView.hidden=YES;
        frontLbl.hidden=NO;
        backLbl.hidden=NO;
        frontGreetingImg.hidden=NO;
        backGreetingImg.hidden=NO;
        //frontGreetingImg.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
        //backGreetingImg.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
        UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomInOutForCards:)];
        tapRecognizer.numberOfTapsRequired=2;
        [self.view addGestureRecognizer:tapRecognizer];
        [tapRecognizer release];
    }
    else{
        frontLbl.hidden=YES;
        backLbl.hidden=YES;
        frontGreetingImg.hidden=YES;
        backGreetingImg.hidden=YES;
        flowerImgView.hidden=NO;
        //flowerImgView.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
    }
            
    giftDetailsContentScroll.frame=CGRectMake(0, 44, 320,416);
    [self.view addSubview:giftDetailsContentScroll];
    
    [giftDetailsContentScroll setContentSize:CGSizeMake(320, 610)];
    personalMsgTxt.inputAccessoryView=msgInputAccessoryView;
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(57, 12, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 12, eventName_newSize.width, 21);
    
    [personalMsgTxt.layer setCornerRadius:6.0];
    [personalMsgTxt.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [personalMsgTxt.layer setBorderWidth:1.0];
}
-(void)zoomInOutForCards:(UITapGestureRecognizer*)tapRecog{
    CGPoint tapLocation=[tapRecog locationInView:self.view];

    //zoom out
    if([zoomInImgView superview]){
        if(CGRectContainsPoint(zoomInImgView.frame, tapLocation))
            [zoomInImgView removeFromSuperview];
    }
    else{
        if(flowerImgView.hidden){
            if(CGRectContainsPoint(backGreetingImg.frame, tapLocation)){
                if(![zoomInImgView superview]){
                    zoomInImgView.frame=CGRectMake(0, 0, 320, 460);
                    [self.view addSubview:zoomInImgView];
                }
                //Assign inside/back image to zoomInImgView
                //zoomInImgView.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
            } 
            if(CGRectContainsPoint(frontGreetingImg.frame, tapLocation)){
               if(![zoomInImgView superview]){
                    zoomInImgView.frame=CGRectMake(0, 0, 320, 460);
                    [self.view addSubview:zoomInImgView];
                }
                //Assign front image to zoomInImgView
                //zoomInImgView.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
            }
        }
        
    }
    
}
- (IBAction)sendOptionsScreenAction:(id)sender {
    SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
    sendOptions.isSendElectronically=NO;
    NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
    [giftAndSenderInfo setObject:@"BONNIE GIESEN" forKey:@"RecipientName"];
    [giftAndSenderInfo setObject:@"birthday" forKey:@"EventName"];
    [giftAndSenderInfo setObject:@"12345" forKey:@"GiftID"];
    [giftAndSenderInfo setObject:@"Greeting" forKey:@"GiftName"];
    [giftAndSenderInfo setObject:greetingPrice.text forKey:@"GiftPrice"];
    [giftAndSenderInfo setObject:[personalMsgTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
    
    
    [giftAndSenderInfo release];
    [self.navigationController pushViewController:sendOptions animated:YES];
    [sendOptions release];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    giftDetailsContentScroll.userInteractionEnabled=NO;
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
#pragma mark -
- (void)viewDidUnload
{

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
    [self setZoomInImgView:nil];
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
    [zoomInImgView release];
    [super dealloc];
}

@end
