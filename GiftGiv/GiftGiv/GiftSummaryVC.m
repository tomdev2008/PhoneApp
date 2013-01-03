//
//  GiftSummaryVC.m
//  GiftGiv
//
//  Created by Srinivas G on 01/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftSummaryVC.h"

#define RETURN_URL @"http://ReturnURL"
#define CANCEL_URL @"http://CancelURL"

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
@synthesize msgHeadLbl;


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
    GGLog(@"gift summary..%@",giftSummaryDict);
    giftSummaryScroll.frame=CGRectMake(0, 44, 320, 416);
    [self.view addSubview:giftSummaryScroll];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSendingOrderToServer) name:@"STARTORDER" object:nil];
    
    if([[giftSummaryDict objectForKey:@"GiftPrice"] isEqualToString:@""])
        isFreeGiftItem=YES;
    
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
     
    
    profileNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"];
    giftNameLbl.text=[giftSummaryDict objectForKey:@"GiftName"];
    if(![[giftSummaryDict objectForKey:@"GiftPrice"] isEqualToString:@""])
        giftPriceLbl.text=[giftSummaryDict objectForKey:@"GiftPrice"];
   
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
    [self loadImage:[giftSummaryDict objectForKey:@"GiftImgUrl"] forAnObject:giftImg];
    
    
   
    
    profileNameLbl.text=[[giftSummaryDict objectForKey:@"RecipientName"] uppercaseString];
    //eventNameLbl.text=[giftSummaryDict objectForKey:@"EventName"];
    
    personalMsgLbl.text=[giftSummaryDict objectForKey:@"PersonalMessage"];
    
    if([[giftSummaryDict objectForKey:@"IsElectronicSending"]integerValue]){
        if([giftSummaryDict objectForKey:@"RecipientPhoneNum"]){
            addressLbl.text=[giftSummaryDict objectForKey:@"RecipientPhoneNum"];
            
        }
        else if([giftSummaryDict objectForKey:@"RecipientMailID"]){
            addressLbl.text=[giftSummaryDict objectForKey:@"RecipientMailID"];
            
        }
        mailGiftToLbl.text=@"Mail Gift to:";
    }
    else{
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
    }
    if(isFreeGiftItem){
        recipientAddressHeadLbl.text=@"RECIPIENT DELIVERY";
        disclosureLbl.hidden=YES;
        giftImg.hidden=YES;
        //giftNameLbl.frame=CGRectMake(18, 98, 282, 21);
        //giftNameLbl.font=[UIFont fontWithName:@"Helvetica" size:18];
        giftNameLbl.hidden=YES;
        
        FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
        defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
        defaultStyle.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        defaultStyle.textAlignment = FTCoreTextAlignementJustified;
        [_thoughtFullMessageLbl addStyle:defaultStyle];
        
        _thoughtFullMessageLbl.text=[giftSummaryDict objectForKey:@"EditableGiftDescription"];
        [_thoughtFullMessageLbl fitToSuggestedHeight:MAXFLOAT];
        paymentBtnLbl.text=@"SEND";
        
        if([giftSummaryDict objectForKey:@"WallPost"])
            mailGiftToLbl.text=@"Post on wall";
        else
            mailGiftToLbl.text=@"Mail Gift to:";
    }
    else{
        _thoughtFullMessageLbl.hidden=YES;
    }
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 19, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 20, eventName_newSize.width, 21);
    
    if(personalMsgLbl.text==nil || [personalMsgLbl.text isEqualToString:@""]){
        msgHeadLbl.hidden=YES;
        
    }
    else
        msgHeadLbl.hidden=NO;
    
    if(isFreeGiftItem){
        
        msgHeadLbl.frame=CGRectMake(msgHeadLbl.frame.origin.x, _thoughtFullMessageLbl.frame.origin.y+_thoughtFullMessageLbl.frame.size.height+5, msgHeadLbl.frame.size.width, msgHeadLbl.frame.size.height);
        
    }
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [personalMsgLbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    personalMsgLbl.frame=CGRectMake(personalMsgLbl.frame.origin.x, msgHeadLbl.frame.origin.y+msgHeadLbl.frame.size.height+5, 280.0, labelSize.height);
    if(isFreeGiftItem){
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, _thoughtFullMessageLbl.frame.origin.y+_thoughtFullMessageLbl.frame.size.height+10, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    else{
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, personalMsgLbl.frame.origin.y+personalMsgLbl.frame.size.height+5, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    disclosureLbl.frame=CGRectMake(disclosureLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, disclosureLbl.frame.size.width, disclosureLbl.frame.size.height);
           
    if(isFreeGiftItem){
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+17, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    else{
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+17, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+10, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    
    
    giftSummaryScroll.contentSize=CGSizeMake(320, paymentBtn.frame.origin.y+paymentBtn.frame.size.height+10);
    
}

-(void)loadImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView{
    //GGLog(@"%@",imgURL);
    __block NSString *tempImgURL=imgURL;
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        if([targetImgView isEqual:profilePic]){
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"]){
                tempImgURL=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"];
            }
            else
                tempImgURL=FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]);
        }
        
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempImgURL]];
        UIImage *giftImage = [UIImage imageWithData:data];
        
        if(giftImage==nil){
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if([targetImgView isEqual:profilePic])
                    profilePic.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                
            });
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                if(![targetImgView isEqual:profilePic])
                {
                    targetImgView.image=giftImage;
                    [self performSelector:@selector(reloadGiftDetails)];
                    /*if(giftImage.size.width<125 || giftImage.size.height<125){
                        targetImgView.frame= CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y+(giftImage.size.height)/4, giftImage.size.width, giftImage.size.height);
                        targetImgView.image=giftImage;
                    }
                    else{
                       UIImage *targetedImage= [giftImage imageByScalingProportionallyToSize:CGSizeMake(125, 125)];
                        targetImgView.frame=CGRectMake(targetImgView.frame.origin.x, targetImgView.frame.origin.y, targetedImage.size.width, targetedImage.size.height);
                        targetImgView.image=targetedImage;
                        
                         [self performSelector:@selector(reloadGiftDetails)];                    
                       
                    }*/
                    
                }
                else
                    targetImgView.image=giftImage;
                
                              
                
                                 
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
}
-(void)reloadGiftDetails{
       
    giftNameLbl.frame=CGRectMake(giftNameLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2-21, giftNameLbl.frame.size.width, giftNameLbl.frame.size.height);
    giftPriceLbl.frame=CGRectMake(giftPriceLbl.frame.origin.x, giftImg.frame.origin.y+(giftImg.frame.size.height)/2, giftPriceLbl.frame.size.width, giftPriceLbl.frame.size.height);
    
    if(msgHeadLbl.hidden){
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
    else{
        msgHeadLbl.frame=CGRectMake(msgHeadLbl.frame.origin.x, giftImg.frame.origin.y+giftImg.frame.size.height+20, msgHeadLbl.frame.size.width, msgHeadLbl.frame.size.height);
         personalMsgLbl.frame=CGRectMake(personalMsgLbl.frame.origin.x, msgHeadLbl.frame.origin.y+msgHeadLbl.frame.size.height+2, personalMsgLbl.frame.size.width, personalMsgLbl.frame.size.height);
        recipientAddressHeadLbl.frame=CGRectMake(recipientAddressHeadLbl.frame.origin.x, personalMsgLbl.frame.origin.y+personalMsgLbl.frame.size.height+5, recipientAddressHeadLbl.frame.size.width, recipientAddressHeadLbl.frame.size.height);
    }
        
    
    
    mailGiftToLbl.frame=CGRectMake(mailGiftToLbl.frame.origin.x, recipientAddressHeadLbl.frame.origin.y+recipientAddressHeadLbl.frame.size.height-5, mailGiftToLbl.frame.size.width, mailGiftToLbl.frame.size.height);
    addressLbl.frame=CGRectMake(addressLbl.frame.origin.x, mailGiftToLbl.frame.origin.y+mailGiftToLbl.frame.size.height-3, addressLbl.frame.size.width, addressLbl.frame.size.height);
    disclosureLbl.frame=CGRectMake(disclosureLbl.frame.origin.x, addressLbl.frame.origin.y+addressLbl.frame.size.height+10, disclosureLbl.frame.size.width, disclosureLbl.frame.size.height);
    
    
    if(disclosureLbl.frame.size.height+disclosureLbl.frame.origin.y>=376){
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+17, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, disclosureLbl.frame.origin.y+disclosureLbl.frame.size.height+10, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    else{
        paymentBtnLbl.frame=CGRectMake(paymentBtnLbl.frame.origin.x, 381, paymentBtnLbl.frame.size.width, paymentBtnLbl.frame.size.height);
        paymentBtn.frame=CGRectMake(paymentBtn.frame.origin.x, 374, paymentBtn.frame.size.width, paymentBtn.frame.size.height);
    }
    
    
    giftSummaryScroll.contentSize=CGSizeMake(320, paymentBtn.frame.origin.y+paymentBtn.frame.size.height+10);
    
    
    
    
}
- (IBAction)backToRecipientForm:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark DeviceReferenceTokenDelegate methods

//This method is called when a device reference token has been successfully fetched.
- (void)receivedDeviceReferenceToken:(NSString *)token {
	//store the token for later use
	[ECNetworkHandler sharedInstance].deviceReferenceToken = token;
	
	//carry on to the review page
	//[self reviewOrder:nil];
    
    [self performSelector:@selector(paymentActionCalledWhenDeviceInitailized)];
}

//This method is called when a device reference token could not be fetched.
- (void)couldNotFetchDeviceReferenceToken {
	//optionally check the errorMessage property to see what the problem was
	//GGLog(@"DEVICE REFERENCE TOKEN ERROR: %@", [PayPal getPayPalInst].errorMessage);
	
	//clear any previously-stored token
	[ECNetworkHandler sharedInstance].deviceReferenceToken = @"";
	
    
    [self performSelector:@selector(paymentActionCalledWhenDeviceInitailized)];
}
- (IBAction)paymentBtnAction:(id)sender {
    
    [self showProgressHUD:self.view withMsg:nil];
    
    if(isFreeGiftItem){
        [self performSelector:@selector(startSendingOrderToServer)];
    }
    else{
        [[PayPal getPayPalInst] fetchDeviceReferenceTokenWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_LIVE withDelegate:self];
    }
    
}
#pragma mark - Sending the order to Server
-(void)startSendingOrderToServer{
    //If the recipient user is not from the events/contacts
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"DummyUserId"])
        [self prepareRequestToAddOrderFor:[[NSUserDefaults standardUserDefaults]objectForKey:@"DummyUserId"]];
    else{
        if([CheckNetwork connectedToNetwork]){
            
            NSString *soapmsgFormat;
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"userID"]){
                soapmsgFormat=[NSString stringWithFormat:@"<tem:GetUser>\n<tem:fbId>%@</tem:fbId>\n</tem:GetUser>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"userID"]];
            }
            else{
                soapmsgFormat=[NSString stringWithFormat:@"<tem:GetUser>\n<tem:fbId>%@</tem:fbId>\n</tem:GetUser>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_userID"]];
            }
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetUser"];
            
            GetUserRequest *getUser=[[GetUserRequest alloc]init];
            [getUser setGetuserDelegate:self];
            [getUser makeRequestToGetUserId:theRequest];
            [getUser release];
        }
    }
}
-(void) responseForGetuser:(UserDetailsObject*)userdetails{
    
    [self prepareRequestToAddOrderFor:userdetails.userId];
    
    
}
-(void)prepareRequestToAddOrderFor:(NSString*)userId{
    
    if([CheckNetwork connectedToNetwork]){
        NSString *sentAsStatus;
        if([[giftSummaryDict objectForKey:@"IsElectronicSending"]integerValue]){
            sentAsStatus=@"electronic";
        }
        else
            sentAsStatus=@"physical";
        NSString *priceValue;
        if([[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@""]){
            priceValue=@"0";
        }
        else{
            priceValue=[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] ;
        }
        NSString *soapmsgFormat=@"";
        if([giftSummaryDict objectForKey:@"RecipientAddress"]){
            //statusCode=@"0";
            NSArray *address=[[giftSummaryDict objectForKey:@"RecipientAddress"] componentsSeparatedByString:@","];
            NSString *address_2=@"";
            
            if([address count]==5){
                address_2=[address objectAtIndex:4];
            }
            soapmsgFormat=[NSString stringWithFormat:@"<tem:AddOrderv2>\n<tem:details>%@</tem:details>\n<tem:userMessage>%@</tem:userMessage>\n<tem:status>0</tem:status>\n<tem:recipientId>%@</tem:recipientId>\n<tem:recipientName>%@</tem:recipientName>\n<tem:email></tem:email>\n<tem:phone></tem:phone>\n<tem:addressLine1>%@</tem:addressLine1>\n<tem:addressLine2>%@</tem:addressLine2>\n<tem:city>%@</tem:city>\n<tem:state>%@</tem:state>\n<tem:zip>%@</tem:zip>\n<tem:senderId>%@</tem:senderId>\n<tem:itemId>%@</tem:itemId>\n<tem:price>%@</tem:price>\n<tem:dateofdelivery>%@</tem:dateofdelivery>\n<tem:sentAs>%@</tem:sentAs>\n</tem:AddOrderv2>",[giftSummaryDict objectForKey:@"EventName"],[giftSummaryDict objectForKey:@"PersonalMessage"],userId,[giftSummaryDict objectForKey:@"RecipientName"],[address objectAtIndex:0],[address objectAtIndex:1],[address objectAtIndex:2],[address objectAtIndex:3],address_2,[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[giftSummaryDict objectForKey:@"GiftID"],priceValue,[giftSummaryDict objectForKey:@"DateOfDelivery"],sentAsStatus];
        }
        else if([giftSummaryDict objectForKey:@"RecipientMailID"]){
            
            soapmsgFormat=[NSString stringWithFormat:@"<tem:AddOrderv2>\n<tem:details>%@</tem:details>\n<tem:userMessage>%@</tem:userMessage>\n<tem:status>0</tem:status>\n<tem:recipientId>%@</tem:recipientId>\n<tem:recipientName>%@</tem:recipientName>\n<tem:email>%@</tem:email>\n<tem:phone></tem:phone>\n<tem:addressLine1></tem:addressLine1>\n<tem:addressLine2></tem:addressLine2>\n<tem:city></tem:city>\n<tem:state></tem:state>\n<tem:zip></tem:zip>\n<tem:senderId>%@</tem:senderId>\n<tem:itemId>%@</tem:itemId>\n<tem:price>%@</tem:price>\n<tem:dateofdelivery>%@</tem:dateofdelivery>\n<tem:sentAs>%@</tem:sentAs>\n</tem:AddOrderv2>",[giftSummaryDict objectForKey:@"EventName"],[giftSummaryDict objectForKey:@"PersonalMessage"],userId,[giftSummaryDict objectForKey:@"RecipientName"],[giftSummaryDict objectForKey:@"RecipientMailID"],[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[giftSummaryDict objectForKey:@"GiftID"],priceValue,[giftSummaryDict objectForKey:@"DateOfDelivery"],sentAsStatus];
        }
        else if([giftSummaryDict objectForKey:@"RecipientPhoneNum"]){
            
            soapmsgFormat=[NSString stringWithFormat:@"<tem:AddOrderv2>\n<tem:details>%@</tem:details>\n<tem:userMessage>%@</tem:userMessage>\n<tem:status>0</tem:status>\n<tem:recipientId>%@</tem:recipientId>\n<tem:recipientName>%@</tem:recipientName>\n<tem:email></tem:email>\n<tem:phone>%@</tem:phone>\n<tem:addressLine1></tem:addressLine1>\n<tem:addressLine2></tem:addressLine2>\n<tem:city></tem:city>\n<tem:state></tem:state>\n<tem:zip></tem:zip>\n<tem:senderId>%@</tem:senderId>\n<tem:itemId>%@</tem:itemId>\n<tem:price>%@</tem:price>\n<tem:dateofdelivery>%@</tem:dateofdelivery>\n<tem:sentAs>%@</tem:sentAs>\n</tem:AddOrderv2>",[giftSummaryDict objectForKey:@"EventName"],[giftSummaryDict objectForKey:@"PersonalMessage"],userId,[giftSummaryDict objectForKey:@"RecipientName"],[giftSummaryDict objectForKey:@"RecipientPhoneNum"],[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[giftSummaryDict objectForKey:@"GiftID"],priceValue,[giftSummaryDict objectForKey:@"DateOfDelivery"],sentAsStatus];
        }
        
        else if([giftSummaryDict objectForKey:@"WallPost"]){
            soapmsgFormat=[NSString stringWithFormat:@"<tem:AddOrderv2>\n<tem:details>%@</tem:details>\n<tem:userMessage>%@</tem:userMessage>\n<tem:status>0</tem:status>\n<tem:recipientId>%@</tem:recipientId>\n<tem:recipientName>%@</tem:recipientName>\n<tem:email></tem:email>\n<tem:phone></tem:phone>\n<tem:addressLine1></tem:addressLine1>\n<tem:addressLine2></tem:addressLine2>\n<tem:city></tem:city>\n<tem:state></tem:state>\n<tem:zip></tem:zip>\n<tem:senderId>%@</tem:senderId>\n<tem:itemId>%@</tem:itemId>\n<tem:price>%@</tem:price>\n<tem:dateofdelivery>%@</tem:dateofdelivery>\n<tem:sentAs>electronic</tem:sentAs>\n</tem:AddOrderv2>",[giftSummaryDict objectForKey:@"EventName"],[giftSummaryDict objectForKey:@"EditableGiftDescription"],userId,[giftSummaryDict objectForKey:@"RecipientName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[giftSummaryDict objectForKey:@"GiftID"],priceValue,[giftSummaryDict objectForKey:@"DateOfDelivery"]];
        }
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        GGLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddOrderv2"];
        
        AddOrderRequest *addOrder=[[AddOrderRequest alloc]init];
        [addOrder setAddorderDelegate:self];
        [addOrder makeReqToAddOrder:theRequest];
        [addOrder release];
    }
    
}
-(void) responseForAddOrder:(NSMutableString*)orderCode{
    
    GGLog(@"Order code...%@",orderCode);
    int isElectronic=[[giftSummaryDict objectForKey:@"IsElectronicSending"]integerValue];
    NSString *sentAsStatus;
    if(isElectronic){
        sentAsStatus=@"electronic";
    }
    else
        sentAsStatus=@"physical";
    
    NSString *priceValue;
    if([[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@""]){
        priceValue=@"0";
    }
    else{
        priceValue=[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] ;
    }
    
    shouldPushToNextScreen=YES;
    NSString *soapmsgFormatAlertOrderEmail=[NSString stringWithFormat:@"<tem:AlertOrderEmail>\n<tem:senderName>%@ %@</tem:senderName>\n<tem:recipientName>%@</tem:recipientName>\n<tem:eventType>%@</tem:eventType>\n<tem:giftItem>%@</tem:giftItem>\n<tem:giftPrice>%@</tem:giftPrice>\n<tem:deliveryMethod>%@</tem:deliveryMethod>\n<tem:deliveryDate>%@</tem:deliveryDate></tem:AlertOrderEmail>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"first_name"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"last_name"],[giftSummaryDict objectForKey:@"RecipientName"],[giftSummaryDict objectForKey:@"EventName"],[giftSummaryDict objectForKey:@"GiftName"],priceValue,sentAsStatus,[giftSummaryDict objectForKey:@"DateOfDelivery"]];
   
    
    NSString *soapRequestString=SOAPRequestMsg(soapmsgFormatAlertOrderEmail);
    GGLog(@"%@",soapRequestString);
    NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AlertOrderEmail"];
    
    AlertOrderEmailRequest *alertOrderMailReq=[[AlertOrderEmailRequest alloc]init];
    [alertOrderMailReq setAlertOrderEmailDelegate:self];
    [alertOrderMailReq makeReqToAlertOrderEmail:theRequest];
    [alertOrderMailReq release];

    //wall post
    if([giftSummaryDict objectForKey:@"WallPost"]){
        shouldPushToNextScreen=NO;
        
        NSString *soapmsgFormatAlertOrderEmail=[NSString stringWithFormat:@"<tem:PostOnFacebookWall>\n<tem:fromFBId>%@</tem:fromFBId>\n<tem:toFBId>%@</tem:toFBId>\n<tem:mesage>%@</tem:mesage>\n</tem:PostOnFacebookWall>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"uid"],[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"],[giftSummaryDict objectForKey:@"EditableGiftDescription"]];
        
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormatAlertOrderEmail);
        GGLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"PostOnFacebookWall"];
        
        AlertOrderEmailRequest *alertOrderMailReq=[[AlertOrderEmailRequest alloc]init];
        [alertOrderMailReq setAlertOrderEmailDelegate:self];
        [alertOrderMailReq makeReqToAlertOrderEmail:theRequest];
        [alertOrderMailReq release];
        
    }
    else if([giftSummaryDict objectForKey:@"RecipientMailID"]){
        
        if(isFreeGiftItem){
            shouldPushToNextScreen=NO;
            NSString *soapmsgFormatAlertOrderEmail=[NSString stringWithFormat:@"<tem:SendThoughtFulMessageEmail>\n<tem:fromName>%@ %@</tem:fromName>\n<tem:toName>%@</tem:toName>\n<tem:toEmail>%@</tem:toEmail>\n<tem:message>%@</tem:message>\n<tem:deliveryDate>%@</tem:deliveryDate>\n</tem:SendThoughtFulMessageEmail>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"first_name"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"last_name"],[giftSummaryDict objectForKey:@"RecipientName"],[giftSummaryDict objectForKey:@"RecipientMailID"],[giftSummaryDict objectForKey:@"EditableGiftDescription"],[giftSummaryDict objectForKey:@"DateOfDelivery"]];
            
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormatAlertOrderEmail);
            GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"SendThoughtFulMessageEmail"];
            
            SendThoughfulMessageEmailReq *sendThoughtfulMsgMailReq=[[SendThoughfulMessageEmailReq alloc]init];
            [sendThoughtfulMsgMailReq setSendThoughtfulMsgEmailReqDel:self];
            [sendThoughtfulMsgMailReq makeReqToSendThoughtful:theRequest];
            [sendThoughtfulMsgMailReq release];
        }
        else if(!isElectronic){

            NSString *profilePicURL;
            
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"]){
                profilePicURL=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"linkedIn_pic_url"];
                
            }
            else{
                profilePicURL=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]objectForKey:@"FBProfilePic"];
            }
            shouldPushToNextScreen=NO;
            
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:SendEmail>\n<tem:orderId>%@</tem:orderId>\n<tem:toEmail>%@</tem:toEmail>\n<tem:subject>%@</tem:subject>\n<tem:fromName>%@ %@</tem:fromName>\n<tem:toName>%@</tem:toName>\n<tem:optionalMessage>Hi %@ -\n\nCongratulations!!! I wish I could be with you to take part in this celebration. However, I have selected a small gift at giftgiv to celebrate this joyous occasion. Can you please send your address so that giftgiv can deliver it to you?</tem:optionalMessage>\n<tem:recipientProfilePic>%@ </tem:recipientProfilePic></tem:SendEmail>",orderCode,[giftSummaryDict objectForKey:@"RecipientMailID"],[giftSummaryDict objectForKey:@"EventName"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"first_name"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"last_name"],[giftSummaryDict objectForKey:@"RecipientName"],[giftSummaryDict objectForKey:@"RecipientName"],profilePicURL];
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"SendEmail"];
            
            SendEmailRequest *mailReq=[[SendEmailRequest alloc]init];
            [mailReq setSendEmailDelegate:self];
            [mailReq makeReqToSendMail:theRequest];
            [mailReq release];
            
        }
        
    }
    else if([giftSummaryDict objectForKey:@"RecipientPhoneNum"]){
        
        if(isFreeGiftItem){
            shouldPushToNextScreen=NO;
        }
        else if(!isElectronic){
            shouldPushToNextScreen=NO;
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:SendSMS>\n<tem:orderId>%@</tem:orderId>\n<tem:toPhone>%@</tem:toPhone>\n<tem:fromName>%@ %@</tem:fromName>\n<tem:toName>%@</tem:toName>\n</tem:SendSMS>",orderCode,[giftSummaryDict objectForKey:@"RecipientPhoneNum"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"first_name"],[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"last_name"],[giftSummaryDict objectForKey:@"RecipientName"]];
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            //GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"SendSMS"];
            
            SendSMSRequest *smsReq=[[SendSMSRequest alloc]init];
            [smsReq setSendSMSDelegate:self];
            [smsReq makeReqToSendSMS:theRequest];
            [smsReq release];
        }
        
    }
   
    
}
-(void) responseForSendThoughtful:(NSMutableString*)responseCode{
    if(shouldPushToNextScreen)
        [self performSelector:@selector(pushToSuccessScreen)];
    shouldPushToNextScreen=YES;
}
-(void) responseForAlertOrderEmail:(NSMutableString*)response{
    //true -- send
    //false -- failed
    if(shouldPushToNextScreen){

        if([[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@""] || [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@"0"]){
            //Assuming that this item is free and does not have payment process
            [self performSelector:@selector(pushToSuccessScreen)];
        }
        else{
            //Post a notification to Paypal's controller
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DONEWithOrder" object:nil];
        }
    }
    shouldPushToNextScreen=YES;
}
-(void) responseForPosting:(NSMutableString*)responseCode{
    if(shouldPushToNextScreen)
        [self performSelector:@selector(pushToSuccessScreen)];
    shouldPushToNextScreen=YES;
}
-(void) responseForSendEmail:(NSMutableString*)response{
    
    //true -- send
    //false -- failed
    if([[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@""] || [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@"0"]){
        //Assuming that this item is free and does not have payment process
        [self performSelector:@selector(pushToSuccessScreen)];
    }
    else{
        //Post a notification to Paypal's controller
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DONEWithOrder" object:nil];
    }
    //[self performSelector:@selector(pushToSuccessScreen)];
}
-(void) responseForSendSMS:(NSMutableString*)response{
    
    //true -- send
    //false -- failed
    //[self performSelector:@selector(pushToSuccessScreen)];
    if([[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@""] || [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] isEqualToString:@"0"]){
        //Assuming that this item is free and does not have payment process
        [self performSelector:@selector(pushToSuccessScreen)];
    }
    else{
        //Post a notification to Paypal's controller
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DONEWithOrder" object:nil];
    }
}
-(void) requestFailed{
    //request faild.
}
-(void)pushToSuccessScreen{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DummyUserId"];
    SuccessVC *showSuccess = [[SuccessVC alloc] initWithNibName:@"SuccessVC" bundle:nil];
    [self.navigationController pushViewController:showSuccess animated:YES];
    [showSuccess release];
}
#pragma mark -
-(void)paymentActionCalledWhenDeviceInitailized{
    //In this example, we do the Express Checkout calls completely on the device.  This is not recommended because
	//it requires the merchant API credentials to be stored in the app on the device, and this is a security risk.
	[ECNetworkHandler sharedInstance].username = MERCHANT_USERNAME;
	[ECNetworkHandler sharedInstance].password = MERCHANT_PASSWORD;
	[ECNetworkHandler sharedInstance].signature = MERCHANT_SIGNATURE;
	[ECNetworkHandler sharedInstance].userAction = ECUSERACTION_COMMIT; //user completes payment on paypal site
	
	SetExpressCheckoutRequestDetails *sreq = [[[SetExpressCheckoutRequestDetails alloc] init] autorelease];
	PaymentDetails *paymentDetails = [[[PaymentDetails alloc] init] autorelease];
	[sreq addPaymentDetails:paymentDetails];
    sreq.NoShipping = DO_NOT_DISPLAY_SHIPPING;
    [sreq setSolutionType:SOLE];
	sreq.ReturnURL = RETURN_URL;
	sreq.CancelURL = CANCEL_URL;
    
    paymentDetails.OrderTotal = [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
	
    PaymentDetailsItem *paymentDetailsItem = [[[PaymentDetailsItem alloc] init] autorelease];
    paymentDetailsItem.Name = [giftSummaryDict objectForKey:@"GiftName"];
    paymentDetailsItem.Amount = [[[giftSummaryDict objectForKey:@"GiftPrice"]stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    [paymentDetails addPaymentDetailsItem:paymentDetailsItem];
	
	//Call setExpressCheckout.  The response will be handled below in the expressCheckoutResponseReceived: method.
	[[ECNetworkHandler sharedInstance] setExpressCheckoutWithRequest:sreq withDelegate:self];
}
- (void)expressCheckoutResponseReceived:(NSObject *)response {
	if ([response isKindOfClass:[NSError class]]) {
        //If we get back an error, display an alert.
        AlertWithMessageAndDelegate(@"Payment failed", [(NSError *)response localizedDescription], nil);
		
		
	} else if ([response isKindOfClass:[NSString class]]) { //got back token
		//The response from setExpressCheckout is an Express Checkout token.  The ECNetworkHandler class stores
		//this token for us, so we do not have to pass it back in.  Redirect to PayPal's login page.
		[self.navigationController pushViewController:[[[WebViewController alloc] initWithURL:[ECNetworkHandler sharedInstance].redirectURL returnURL:RETURN_URL cancelURL:CANCEL_URL giftItem:giftSummaryDict]autorelease] animated:TRUE];
	}
    [self stopHUD];
}
#pragma mark - ProgressHUD methods

- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr  
{
	HUD = [[MBProgressHUD alloc] initWithView:targetView];
	
	// Add HUD to screen
	[targetView addSubview:HUD];
	
	// Regisete for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	HUD.labelText=titleStr;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD show:YES];
	
}
- (void)stopHUD{
    if (![HUD isHidden]) {
        [HUD setHidden:YES];
    }
}
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD=nil;
}
#pragma mark -
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
    [self setMsgHeadLbl:nil];
    
    [self setThoughtFullMessageLbl:nil];
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
    
    [msgHeadLbl release];
    [_thoughtFullMessageLbl release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STARTORDER" object:nil];
    [super dealloc];
}
@end
