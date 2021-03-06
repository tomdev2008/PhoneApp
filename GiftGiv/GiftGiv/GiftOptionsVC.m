//
//  GiftOptionsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftOptionsVC.h"


@implementation GiftOptionsVC
@synthesize giftsTable;
@synthesize giftCategoryPageControl;
@synthesize giftItemsBgView;
@synthesize profilePicImg;
@synthesize profileNameLbl;
@synthesize eventNameLbl;

@synthesize categoryTitleLbl;


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
        
    [self showProgressHUD:self.view withMsg:nil];
    
    eventNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
    
    profileNameLbl.text=[[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"] uppercaseString];
        
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        NSString *urlStr;
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"FBProfilePic"])
            urlStr=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"FBProfilePic"];
        else 
            urlStr=FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]);
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                profilePicImg.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                
            });
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                profilePicImg.image=thumbnail;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
    
    
    
    if(currentiOSVersion<6.0){
        pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive" ofType:@"png"] retain];
        pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive" ofType:@"png"] retain];
    }
    
    else if(currentiOSVersion>=6.0){
        
        //Enable the below statements when the project is compiled with iOS 6.0 and change the colors for the dots
        /*[giftCategoryPageControl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0]];
         [giftCategoryPageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.4431 green:0.8902 blue:0.9254 alpha:1.0]];*/
    }
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(126, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 63, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+5+profileNameLbl.frame.size.width, 64, eventName_newSize.width, 21);
    
    
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [giftItemsBgView addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [giftItemsBgView addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    
    [self makeRequestToGetCategories];
    

}
-(void)retrieveGiftThumbnails{
    
    int giftItemsCount=[listOfAllGiftItems count];
   
    for(int i=0;i<giftItemsCount;i++){
        dispatch_queue_t ImageLoader_Q;
        ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
        dispatch_async(ImageLoader_Q, ^{
            
            NSString *urlStr=[[[listOfAllGiftItems objectAtIndex:i]objectForKey:@"GiftDetails"] giftThumbnailUrl];
            
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            UIImage *thumbnail = [UIImage imageWithData:data];
            
            if(thumbnail==nil){
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    
                    
                    //profilePicImg.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                    
                });
                
            }
            else {
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[listOfAllGiftItems objectAtIndex:i]];
                    [tempDict setObject:thumbnail forKey:@"GiftThumbnail"];
                    [listOfAllGiftItems replaceObjectAtIndex:i withObject:tempDict];
                    [tempDict release];                   
                    [self loadCurrentGiftItemsForCategory:[[giftCategoriesList objectAtIndex:giftCatNum-1]catId]];
                });
            }
            
        });
        dispatch_release(ImageLoader_Q);
    }
     [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
}
-(void)makeRequestToGetCategories{
    
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetCategories/>"];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetCategories"];
        
        GiftCategoriesRequest *giftCats=[[GiftCategoriesRequest alloc]init];
        [giftCats setGiftCatDelegate:self];
        [giftCats makeGiftCategoriesRequest:theRequest];
        [giftCats release];
    }
    else{
        [self stopHUD];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        AlertWithMessageAndDelegate(@"GiftGiv", @"Check your network settings", nil);
    }
    
}

#pragma mark - Get gift categories Request delegate
-(void) responseForGiftCategories:(NSMutableArray*)categoriesList{
    
    if([categoriesList count]){
        giftCategoriesList=[[NSMutableArray alloc] initWithArray:categoriesList];
        
        if([CheckNetwork connectedToNetwork]){
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetGiftItemforPhone/>"];
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            //NSLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetGiftItemforPhone"];
            
            GiftItemsRequest *giftItems=[[GiftItemsRequest alloc]init];
            [giftItems setGiftItemsDelegate:self];
            [giftItems makeGiftItemsRequest:theRequest];
            [giftItems release];
        }
        else{
            [self stopHUD];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            AlertWithMessageAndDelegate(@"GiftGiv", @"Check your network settings", nil);
        }
        
        
        
    }
    else{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self stopHUD];
    }
    
    
    
}
-(void) requestFailed{
    [self stopHUD];
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed", nil);
}
#pragma mark - Gift Items
-(void) responseForGiftItems:(NSMutableArray*)listOfGifts{
    if([listOfAllGiftItems count]){
        [listOfAllGiftItems removeAllObjects];
        [listOfAllGiftItems release];
        listOfAllGiftItems=nil;
    }
    if(listOfAllGiftItems==nil){
        listOfAllGiftItems=[[NSMutableArray alloc]init];
    }
    [listOfAllGiftItems addObjectsFromArray:listOfGifts];
    
    totalCats=[giftCategoriesList count];
    giftCategoryPageControl.numberOfPages=totalCats;    
    giftCatNum=1;
    giftCategoryPageControl.currentPage=giftCatNum-1;
    
    
    
    [self loadCurrentGiftItemsForCategory:[[giftCategoriesList objectAtIndex:giftCatNum-1]catId]];
    
    [self performSelector:@selector(retrieveGiftThumbnails)];    
      

    [self stopHUD];
}
-(void)loadCurrentGiftItemsForCategory :(NSString*)categoryId{
    
    if(currentGiftItems!=nil){
        if([currentGiftItems count])
            [currentGiftItems removeAllObjects];
        [currentGiftItems release];
        currentGiftItems=nil;
    }
    
    if([listOfAllGiftItems count]){
        
        for(NSMutableDictionary *giftItemDict in listOfAllGiftItems){
            
            if([categoryId isEqualToString:[[giftItemDict objectForKey:@"GiftDetails"]giftCategoryId]]){
                if(currentGiftItems==nil){
                    currentGiftItems=[[NSMutableArray alloc]init];
                }
                
                [currentGiftItems addObject:giftItemDict];
            }
                     
        }
    }
    
    categoryTitleLbl.text=[[giftCategoriesList objectAtIndex:giftCatNum-1] catName];
    [giftsTable reloadData];
}
#pragma mark -

-(void)swipeGestureForGiftCats:(UISwipeGestureRecognizer*)swipeRecognizer{
    
    if(totalCats>1){
        //previous
        if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            if(giftCatNum>1)
            {						
                giftCatNum--;
                
                [self swipingForGiftCategories:0];
                
                
            }
            else if(giftCatNum==1)
            {
                giftCatNum=totalCats;
                [self swipingForGiftCategories:0];
            }
        }
        //next
        else if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            if(giftCatNum<totalCats)
            {					
                giftCatNum++;
                
                [self swipingForGiftCategories:1];
                
                
            }
            else if(giftCatNum==totalCats)
            {
                giftCatNum=1;
                [self swipingForGiftCategories:1];
            }
        }
        giftCategoryPageControl.currentPage=giftCatNum-1;
    }
    
}
- (IBAction)backToEvents:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)giftCategoriesPaeControlAction:(id)sender {
    if(currentiOSVersion<6.0){
        for (int i = 0; i < [giftCategoryPageControl.subviews count]; i++)
        {
            UIImageView* dot = [giftCategoryPageControl.subviews objectAtIndex:i];
            if (i == giftCategoryPageControl.currentPage)
                dot.image = pageActiveImage;
            else
                dot.image = pageInactiveImage;
        }
    }
    
    if(giftCategoryPageControl.currentPage>giftCatNum-1){
        giftCatNum=giftCategoryPageControl.currentPage+1;
        [self swipingForGiftCategories:1];
    }
    else{
        giftCatNum=giftCategoryPageControl.currentPage+1;
        [self swipingForGiftCategories:0];
    }
}
-(void)swipingForGiftCategories:(int)swipeDirectionNum{
    if(swipeDirectionNum==1){
        
        tranAnimationForGiftCategories=[self getAnimationForGiftCategories:kCATransitionFromRight];
    }
    else{
        
        tranAnimationForGiftCategories=[self getAnimationForGiftCategories:kCATransitionFromLeft];
    }
    
          
    [giftItemsBgView.layer addAnimation:tranAnimationForGiftCategories forKey:@"groupAnimation"];
   
    [self loadCurrentGiftItemsForCategory:[[giftCategoriesList objectAtIndex:giftCatNum-1]catId]];
        
}
-(CATransition *)getAnimationForGiftCategories:(NSString *)animationType{
    CATransition *easeInAnimation = [CATransition animation];
	easeInAnimation.duration = 0.6f;//0.4f
	easeInAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
	easeInAnimation.type = kCATransitionPush ;
	
	easeInAnimation.subtype = animationType;
	
	return easeInAnimation;
}
#pragma mark - Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([currentGiftItems count]%2==0)
        return [currentGiftItems count]/2;
    else
        return [currentGiftItems count]/2+1;
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	tableView.backgroundColor=[UIColor clearColor];
	GiftCustomCell *cell = (GiftCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"GiftCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [cell.giftIcon_one.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.66 blue:0.68 alpha:1.0]CGColor]];
        [cell.giftIcon_one.layer setBorderWidth:3.0];
        [cell.giftIcon_two.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.66 blue:0.68 alpha:1.0]CGColor]];
        [cell.giftIcon_two.layer setBorderWidth:3.0];
        [cell.giftIcon_one addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.giftIcon_two addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
		
	}
    cell.tag=indexPath.row;
    cell.giftTitle_one.text=[[[currentGiftItems objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] giftTitle];
    
    NSArray *priceArray_one=[[[[currentGiftItems objectAtIndex:(indexPath.row*2)] objectForKey:@"GiftDetails"] giftPrice] componentsSeparatedByString:@";"];
    
    if([priceArray_one count]>1){
        ;
        cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_one objectAtIndex:0],[priceArray_one objectAtIndex:[priceArray_one count]-1]];
    }
    else
        cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@",[[[currentGiftItems objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] giftPrice]];
    UIImage *tempImg_one=nil;;
    if([[currentGiftItems objectAtIndex:(indexPath.row*2)] objectForKey:@"GiftThumbnail"])
        tempImg_one=[[currentGiftItems objectAtIndex:(indexPath.row*2)] objectForKey:@"GiftThumbnail"];
    if(tempImg_one!=nil){
        if(tempImg_one.size.width==160 && tempImg_one.size.height==120){
            cell.giftImg_one.frame=CGRectMake(cell.giftImg_one.frame.origin.x+12,cell.giftImg_one.frame.origin.y+25 , 100, 75);
        }
        else if(tempImg_one.size.width==160 && tempImg_one.size.height==172){
            cell.giftImg_one.frame=CGRectMake(cell.giftImg_one.frame.origin.x+12,cell.giftImg_one.frame.origin.y+8 , 100, 108);
        }
        else if(tempImg_one.size.width==110 && tempImg_one.size.height==150){
            cell.giftImg_one.frame=CGRectMake(cell.giftImg_one.frame.origin.x+28,cell.giftImg_one.frame.origin.y+15 , 69, 94);
        }
        
        [cell.giftImg_one setImage:tempImg_one];
    }
    
    
    if([currentGiftItems count]>(indexPath.row*2)+1){
        cell.giftIcon_two.hidden=NO;
        cell.giftPrice_two.hidden=NO;
        cell.giftTitle_two.hidden=NO;
        cell.giftTitle_two.text=[[[currentGiftItems objectAtIndex:(indexPath.row*2)+1] objectForKey:@"GiftDetails"]giftTitle];
        
        NSArray *priceArray_two=[[[[currentGiftItems objectAtIndex:(indexPath.row*2)+1] objectForKey:@"GiftDetails"]giftPrice] componentsSeparatedByString:@";"];
        
        if([priceArray_two count]>1){
            
            cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_two objectAtIndex:0],[priceArray_two objectAtIndex:[priceArray_two count]-1]];
        }
        else
            cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@",[[[currentGiftItems objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftDetails"] giftPrice]];
        UIImage *tempImg_two=nil;
        if([[currentGiftItems objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftThumbnail"]){
            tempImg_two=[[currentGiftItems objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftThumbnail"];
        }
        if(tempImg_two!=nil){
            if(tempImg_two.size.width==160 && tempImg_two.size.height==120){
                cell.giftImg_two.frame=CGRectMake(cell.giftImg_two.frame.origin.x+12,cell.giftImg_two.frame.origin.y+25 , 100, 75);
            }
            else if(tempImg_two.size.width==160 && tempImg_two.size.height==172){
                cell.giftImg_two.frame=CGRectMake(cell.giftImg_two.frame.origin.x+12,cell.giftImg_two.frame.origin.y+8 , 100, 108);
            }
            else if(tempImg_two.size.width==110 && tempImg_two.size.height==150){
                cell.giftImg_two.frame=CGRectMake(cell.giftImg_two.frame.origin.x+28,cell.giftImg_two.frame.origin.y+15 , 69, 94);
            }
            
            
            [cell.giftImg_two setImage:tempImg_two];
        }
                
    }
    
    else{
        cell.giftIcon_two.hidden=YES;
        cell.giftPrice_two.hidden=YES;
        cell.giftTitle_two.hidden=YES;
    }
    
    
	return cell;
}
#pragma mark -
-(void)giftTileIconTapped:(id)sender{
    
    int rowNum=[(GiftCustomCell*)[(UIButton*)sender superview] tag];
    int columNum=[sender tag];
    GiftItemObject *selectedGift=[[currentGiftItems objectAtIndex:(rowNum*2+columNum)-1]objectForKey:@"GiftDetails"];

    //gift cards
    if([[selectedGift.giftPrice componentsSeparatedByString:@";"] count]>1){
        GiftCardDetailsVC *giftCardDetails=[[GiftCardDetailsVC alloc]initWithNibName:@"GiftCardDetailsVC" bundle:nil];
        giftCardDetails.giftItemInfo=selectedGift;
        [self.navigationController pushViewController:giftCardDetails animated:YES];
        [giftCardDetails release];
    }
    else{
        
        Gift_GreetingCardDetailsVC *greetingCardDetails=[[Gift_GreetingCardDetailsVC alloc]initWithNibName:@"Gift_GreetingCardDetailsVC" bundle:nil];
        if(![selectedGift.giftImageBackSideUrl length])
            greetingCardDetails.isGreetingCard=NO;
        else if([selectedGift.giftImageBackSideUrl length])
            greetingCardDetails.isGreetingCard=YES;
        greetingCardDetails.giftItemInfo=selectedGift;
        [self.navigationController pushViewController:greetingCardDetails animated:YES];
        [greetingCardDetails release];
    }
    
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
    [self setProfilePicImg:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftCategoryPageControl:nil];
    [self setGiftsTable:nil];
    [self setCategoryTitleLbl:nil];
    [self setGiftItemsBgView:nil];
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
    
    if(currentiOSVersion<6.0){
        [pageActiveImage release];
        [pageInactiveImage release]; 
    }
    if([giftCategoriesList count])
        [giftCategoriesList removeAllObjects];
    if(giftCategoriesList!=nil){
        [giftCategoriesList release];
        giftCategoriesList=nil;
    }
    if([listOfAllGiftItems count])
        [listOfAllGiftItems removeAllObjects];
    if(listOfAllGiftItems!=nil){
        [listOfAllGiftItems release];
        listOfAllGiftItems=nil;
    }
    
    if([currentGiftItems count])
        [currentGiftItems removeAllObjects];
    if(currentGiftItems!=nil){
        [currentGiftItems release];
        currentGiftItems=nil;
    }
    
    
    [profilePicImg release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftCategoryPageControl release];
    [giftsTable release];
    
    [categoryTitleLbl release];
    [giftItemsBgView release];
    [super dealloc];
}

@end
