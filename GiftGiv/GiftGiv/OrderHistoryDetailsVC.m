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
@synthesize orderDetailsScroll;
@synthesize giftNameLbl;
@synthesize statusHeadLbl;
@synthesize statusDateLbl;
@synthesize recipientAddressHeadLbl;
@synthesize msgHeadLbl;
@synthesize profilePic;
@synthesize messageLbl;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize giftPriceLbl;
@synthesize addressLbl;
@synthesize orderDetails;

static NSDateFormatter *customDateFormat=nil;

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
    //NSLog(@"%@",orderDetails.price);
    orderDetailsScroll.frame=CGRectMake(0, 44, 320, 416);
    [self.view addSubview:orderDetailsScroll];
    
    [self performSelector:@selector(loadProfilePicture)];
    
    profileNameLbl.text=[orderDetails.recipientName uppercaseString];
    //eventNameLbl.text=orderDetails.
    
    
    [self performSelector:@selector(getGiftItemDetails)];
    
    if(![orderDetails.phone isEqualToString:@""]){
        addressLbl.text=orderDetails.phone;
        mailGiftToLbl.text=@"Address request sent to:";
    }
    else if(![orderDetails.email isEqualToString:@""]){
        addressLbl.text=orderDetails.email;
        mailGiftToLbl.text=@"Address request sent to:";
    }
    else{
        
        NSString *address=[NSString stringWithFormat:@"%@, ",orderDetails.addressLine1];
        if(![orderDetails.addressLine2 isEqualToString:@""])
            address=[address stringByAppendingFormat:@"%@,",orderDetails.addressLine2];
        address=[address stringByAppendingFormat:@"%@, ",orderDetails.city];
        address=[address stringByAppendingFormat:@"%@, ",orderDetails.state];
        address=[address stringByAppendingFormat:@"%@",orderDetails.zip];
        addressLbl.text=address;
        
        mailGiftToLbl.text=@"Mail Gift to:";
    }
    
    if([[orderDetails status] isEqualToString:@"-1"]){
        statusLbl.text=@"Waiting for recipient reply";
    }
    else if([[orderDetails status] isEqualToString:@"0"]){
        
        statusLbl.text=@"Pending at store";
    }
    else if([[orderDetails status] isEqualToString:@"1"]){
        
        statusLbl.text=@"Dispatched";
    }
    else if([[orderDetails status] isEqualToString:@"2"]){
        
        statusLbl.text=@"Delivered";
    }
    else if([[orderDetails status] isEqualToString:@"3"]){
        
        statusLbl.text=@"Returned";
    }
    eventNameLbl.text=[orderDetails details];
    NSString *dateString=[[[orderDetails orderUpdatedDate] componentsSeparatedByString:@"T"] objectAtIndex:0];
    statusDateLbl.text=[self updateDate:dateString];//[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:dateString];
    /*if([statusDateLbl.text isEqualToString:@"Today"]||[statusDateLbl.text isEqualToString:@"Yesterday"]||[statusDateLbl.text isEqualToString:@"Tomorrow"]||[statusDateLbl.text isEqualToString:@"Recent"]){
     statusDateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
     statusDateLbl.font=[UIFont fontWithName:@"Helvetica-Bold" size:7.0];
     }
     */
    
    if(![orderDetails.userMessage isEqualToString:@""]){
        msgHeadLbl.hidden=NO;
        messageLbl.text=orderDetails.userMessage;
        messageLbl.hidden=NO;       
    }
    else{
        messageLbl.hidden=YES;
        msgHeadLbl.hidden=YES;
    }
    
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 19, eventName_newSize.width, 21);
    
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [messageLbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    messageLbl.frame=CGRectMake(messageLbl.frame.origin.x, messageLbl.frame.origin.y, 280.0, labelSize.height);
    recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, messageLbl.frame.origin.y+messageLbl.frame.size.height+10, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    
    recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, messageLbl.frame.origin.y+messageLbl.frame.size.height+10, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    
    statusHeadLbl.frame=CGRectMake(statusHeadLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, statusHeadLbl.frame.size.width, statusHeadLbl.frame.size.height);
    statusDateLbl.frame=CGRectMake(statusDateLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+9, statusDateLbl.frame.size.width, statusDateLbl.frame.size.height);
    statusLbl.frame=CGRectMake(statusLbl.frame.origin.x, statusHeadLbl.frame.origin.y+statusHeadLbl.frame.size.height-3, statusLbl.frame.size.width, statusLbl.frame.size.height);
    
    // askAddressLbl,askAgainBtn will be visible only if the order is of type Email/SMS
    
    
    //The scroll content size has to change respected to statusLbl or askAddressLbl based on the Order type (Email/SMS)
    orderDetailsScroll.contentSize=CGSizeMake(320, statusLbl.frame.origin.y+statusLbl.frame.size.height+10);
    
    
    
}
-(void)loadProfilePicture{
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSString *urlStr=[orderDetails profilePictureUrl];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
               profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
                
            });
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {

                profilePic.image=thumbnail;

            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
-(void)getGiftItemDetails{
    if([CheckNetwork connectedToNetwork]){
        
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetGiftItem>\n<tem:id>%@</tem:id>\n</tem:GetGiftItem>",orderDetails.itemId];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetGiftItem"];
        
        GetGiftItemRequest *getGiftItem=[[GetGiftItemRequest alloc]init];
        [getGiftItem setGiftItemDelegate:self];
        [getGiftItem makeGiftItemRequest:theRequest];
        [getGiftItem release];
    }
}
#pragma mark -GetGiftItemDelegate
-(void) receivedGiftItem:(GetDetailedGiftItemObject*)giftDetails{
    
    giftNameLbl.text=giftDetails.giftTitle;
    giftPriceLbl.text=[NSString stringWithFormat:@"$%@",orderDetails.price];
    [self loadGiftImage:giftDetails.giftImageUrl forAnObject:giftImg];
}
-(void) requestFailed{
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed. Please try again later", nil);
}
#pragma mark -
-(void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
        UIImage *giftImage = [UIImage imageWithData:data];
        
        if(giftImage==nil){
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                
            });
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                if(![targetImgView isEqual:profilePic])
                {
                    if(giftImage.size.width<125 || giftImage.size.height<125){
                        targetImgView.frame= CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y+(giftImage.size.height)/4, giftImage.size.width, giftImage.size.height);
                        targetImgView.image=giftImage;
                    }
                    else{
                        UIImage *targetedImage= [giftImage imageByScalingProportionallyToSize:CGSizeMake(125, 125)];
                        targetImgView.frame=CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y, targetedImage.size.width, targetedImage.size.height);
                        targetImgView.image=targetedImage;
                        
                        [self performSelector:@selector(reloadGiftDetails)];
                        
                        
                    }
                }
                else
                               
                    targetImgView.image=giftImage; 
                
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
-(NSString*)updateDate:(id)sourceDate{
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    NSString *endDateString;
    
    if([sourceDate isKindOfClass:[NSString class]]){
        
        sourceDate=[NSString stringWithFormat:@"%@",sourceDate];
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *tempDate = [customDateFormat dateFromString:sourceDate];
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:tempDate];
    }
    else{
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:(NSDate*)sourceDate];
    }
    /*int day=[[[endDateString componentsSeparatedByString:@" "] objectAtIndex:1] intValue];
    if (day >= 11 && day <= 13) {
         endDateString=[endDateString stringByAppendingString:@"th"];
    }
    switch (day % 10) {
        case 1:
            endDateString=[endDateString stringByAppendingString:@"st"];
            break;
        case 2:
            endDateString=[endDateString stringByAppendingString:@"nd"];
            break;
        case 3:
            endDateString=[endDateString stringByAppendingString:@"rd"];
            break;
        default:
            endDateString=[endDateString stringByAppendingString:@"th"];
            break;
    }
    */
    
    return endDateString;
}
-(void)reloadGiftDetails{
    
        
    giftNameLbl.frame=CGRectMake(giftNameLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2-21, giftNameLbl.frame.size.width, giftNameLbl.frame.size.height);
    giftPriceLbl.frame=CGRectMake(giftPriceLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2, giftPriceLbl.frame.size.width, giftPriceLbl.frame.size.height);
    
    if(msgHeadLbl.hidden){
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    else{
        msgHeadLbl.frame=CGRectMake(msgHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, msgHeadLbl.frame.size.width, msgHeadLbl.frame.size.height);
        messageLbl.frame=CGRectMake(messageLbl.frame.origin.x, msgHeadLbl.frame.origin.y+msgHeadLbl.frame.size.height+2, messageLbl.frame.size.width, messageLbl.frame.size.height);
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, messageLbl.frame.origin.y+messageLbl.frame.size.height+5, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    
    
    
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    
    statusHeadLbl.frame=CGRectMake(statusHeadLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, statusHeadLbl.frame.size.width, statusHeadLbl.frame.size.height);
    statusDateLbl.frame=CGRectMake(statusDateLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+9, statusDateLbl.frame.size.width, statusDateLbl.frame.size.height);
    statusLbl.frame=CGRectMake(statusLbl.frame.origin.x, statusHeadLbl.frame.origin.y+statusHeadLbl.frame.size.height-3, statusLbl.frame.size.width, statusLbl.frame.size.height);
    
    orderDetailsScroll.contentSize=CGSizeMake(320, statusLbl.frame.origin.y+statusLbl.frame.size.height+10);
      
    
    
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
    [self setMailGiftToLbl:nil];
    [self setGiftImg:nil];
    [self setMsgHeadLbl:nil];
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
    [orderDetails release];
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
    
    [mailGiftToLbl release];
    [giftImg release];
    
    [msgHeadLbl release];
    [super dealloc];
}

@end
