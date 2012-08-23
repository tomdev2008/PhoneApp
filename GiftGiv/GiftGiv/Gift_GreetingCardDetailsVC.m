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
@synthesize giftItemInfo;

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
    
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"UserDetails"] objectForKey:@"eventName"];
    
    profileNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"UserDetails"] objectForKey:@"userName"];
    
    [self loadGiftImage:FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDetails"] objectForKey:@"userID"]) forAnObject:profilePic];
    
    
    if(isGreetingCard){
        flowerImgView.hidden=YES;
        frontLbl.hidden=NO;
        backLbl.hidden=NO;
        frontGreetingImg.hidden=NO;
        backGreetingImg.hidden=NO;
        [self loadGiftImage:[giftItemInfo giftImageUrl] forAnObject:frontGreetingImg];
        [self loadGiftImage:[giftItemInfo giftImageBackSideUrl] forAnObject:backGreetingImg];
        
    }
    else{
        frontLbl.hidden=YES;
        backLbl.hidden=YES;
        frontGreetingImg.hidden=YES;
        backGreetingImg.hidden=YES;
        flowerImgView.hidden=NO;
        [self loadGiftImage:[giftItemInfo giftImageUrl] forAnObject:flowerImgView];
        
    }
    
    UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomInOutForCards:)];
    tapRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    greetingNameLbl.text=[giftItemInfo giftTitle];
    greetingPrice.text=[NSString stringWithFormat:@"$%@",[giftItemInfo giftPrice]];
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
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 13, eventName_newSize.width, 21);
    
    [personalMsgTxt.layer setCornerRadius:6.0];
    [personalMsgTxt.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [personalMsgTxt.layer setBorderWidth:1.0];
}

-(void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
        UIImage *giftImg = [UIImage imageWithData:data];
        
        if(giftImg==nil){
            if([targetImgView isEqual:profilePic]){
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                    
                });
            }
            
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                targetImgView.image=giftImg;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
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
            zoomInImgView.image=nil;
            if(CGRectContainsPoint(backGreetingImg.frame, tapLocation)){
                if(![zoomInImgView superview]){
                    zoomInImgView.frame=CGRectMake(0, 0, 320, 460);
                    [self.view addSubview:zoomInImgView];
                }
                zoomInImgView.image=backGreetingImg.image;
                //Assign inside/back image to zoomInImgView
                //zoomInImgView.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
            } 
            if(CGRectContainsPoint(frontGreetingImg.frame, tapLocation)){
                if(![zoomInImgView superview]){
                    zoomInImgView.frame=CGRectMake(0, 0, 320, 460);
                    [self.view addSubview:zoomInImgView];
                }
                zoomInImgView.image=frontGreetingImg.image;
                //Assign front image to zoomInImgView
                //zoomInImgView.image=[ImageAllocationObject loadImageObjectName:@"" ofType:@""];
            }
        }
        else{
            if(CGRectContainsPoint(flowerImgView.frame, tapLocation)){
                if(![zoomInImgView superview]){
                    zoomInImgView.frame=CGRectMake(0, 0, 320, 460);
                    [self.view addSubview:zoomInImgView];
                }
                zoomInImgView.image=flowerImgView.image;
                
            } 
        }
        
    }
    
}
- (IBAction)sendOptionsScreenAction:(id)sender {
    SendOptionsVC *sendOptions=[[SendOptionsVC alloc]initWithNibName:@"SendOptionsVC" bundle:nil];
    sendOptions.isSendElectronically=NO;
    NSMutableDictionary *giftAndSenderInfo=[[NSMutableDictionary alloc]initWithCapacity:10];
    [giftAndSenderInfo setObject:profileNameLbl.text forKey:@"RecipientName"];
    [giftAndSenderInfo setObject:eventNameLbl.text forKey:@"EventName"];
    [giftAndSenderInfo setObject:[giftItemInfo giftId] forKey:@"GiftID"];
    [giftAndSenderInfo setObject:[giftItemInfo giftTitle] forKey:@"GiftName"];
    [giftAndSenderInfo setObject:[giftItemInfo giftImageUrl] forKey:@"GiftImgUrl"];
    [giftAndSenderInfo setObject:greetingPrice.text forKey:@"GiftPrice"];
    [giftAndSenderInfo setObject:[personalMsgTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"PersonalMessage"];
    
    sendOptions.sendingInfoDict=giftAndSenderInfo;
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
    [giftItemInfo release];
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
