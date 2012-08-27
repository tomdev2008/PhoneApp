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
@synthesize giftCategoriesScroll;
@synthesize profilePicImg;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize giftsList;

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
    
    profileNameLbl.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"];
    
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSString *urlStr=FacebookPicURL([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"]);
        
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
    profileNameLbl.frame=CGRectMake(57, 56, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+5+profileNameLbl.frame.size.width, 57, eventName_newSize.width, 21);
    
    
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [giftsTable addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [giftsTable addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    
    [self makeRequestToGetCategories];
    
    //[self reloadTheContentForGifts];
}
-(void)loadDynamicCategories{
    
    UIFont *catTitleFont=[UIFont fontWithName:@"Helvetica" size:25];
    
    int xOriginForButton=0;
    totalCats=[giftCategoriesList count];
    
    //Gift categories
    for(int i=0;i<totalCats;i++){
        
        //dynamic button width based on the title for it
        CGSize giftCatTitleSize=[[[giftCategoriesList objectAtIndex:i]catName] sizeWithFont:catTitleFont constrainedToSize:CGSizeMake(MAXFLOAT, 40) lineBreakMode:UILineBreakModeWordWrap];
        UIButton *giftCatBtn=[[UIButton alloc]initWithFrame:CGRectMake(xOriginForButton, 2, giftCatTitleSize.width, 40)];
        giftCatBtn.tag=i+1;
        [giftCatBtn addTarget:self action:@selector(categoryActions:) forControlEvents:UIControlEventTouchUpInside];
        [giftCatBtn.titleLabel setFont:catTitleFont];
        [giftCatBtn setTitle:[[giftCategoriesList objectAtIndex:i]catName] forState:UIControlStateNormal];
        if(i==0)
            [giftCatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [giftCatBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [giftCategoriesScroll addSubview:giftCatBtn];
        
        [giftCategoriesScroll setContentSize:CGSizeMake(xOriginForButton+giftCatTitleSize.width, 44)];
        xOriginForButton=xOriginForButton+giftCatTitleSize.width+10;
        [giftCatBtn release];
    }
    giftCategoryPageControl.numberOfPages=totalCats;    
    giftCatNum=1;
    giftCategoryPageControl.currentPage=giftCatNum-1;
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
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    if(flowersList!=nil){
        if([flowersList count]){
            [flowersList removeAllObjects];
        }
        [flowersList release];
        flowersList=nil;
    }
    if(greetingCardsList!=nil){
        if([greetingCardsList count]){
            [greetingCardsList removeAllObjects];
        }
        [greetingCardsList release];
        greetingCardsList=nil;
    }
    if(giftCarsList!=nil){
        if([giftCarsList count]){
            [giftCarsList removeAllObjects];
        }
        [giftCarsList release];
        giftCarsList=nil;
    }
    int categoriesCount=[giftCategoriesList count];
    if([listOfGifts count]){
        
        for(GiftItemObject *giftItem in listOfGifts){
            
            for(int i=0;i<categoriesCount;i++){
                
                if([giftItem.giftCategoryId isEqualToString:[[giftCategoriesList objectAtIndex:i]catId]]){
                    
                    if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"flowers"]){
                        if(flowersList==nil){
                            flowersList=[[NSMutableArray alloc]init];
                        }
                        
                        [flowersList addObject:giftItem];
                        break;
                    }
                    if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"gift cards"]){
                        if(giftCarsList==nil){
                            giftCarsList=[[NSMutableArray alloc]init];
                        }
                        
                        [giftCarsList addObject:giftItem];
                        break;
                    }
                    if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"greeting cards"]){
                        if(greetingCardsList==nil){
                            greetingCardsList=[[NSMutableArray alloc]init];
                        }
                        
                        [greetingCardsList addObject:giftItem];
                        break;
                    }
                    
                }
            }
            
        }
    }
    
    
    for(int i=0;i<[giftCategoriesList count];i++){
        if(![flowersList count]){
            
            if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"flowers"]){
                [giftCategoriesList removeObject:[giftCategoriesList objectAtIndex:i]];
            }
        }
        if(greetingCardsList==nil){
            if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"greeting cards"]){
                [giftCategoriesList removeObject:[giftCategoriesList objectAtIndex:i]];
            }
        }
        if(giftCarsList==nil){
            if([[[giftCategoriesList objectAtIndex:i] catName] isEqualToString:@"gift cards"]){
                [giftCategoriesList removeObject:[giftCategoriesList objectAtIndex:i]];
            }
        }
        
    }
    
    [self loadDynamicCategories];
    giftCatNum=1;
    [self reloadTheContentForGifts];
    [self stopHUD];
}
#pragma mark -

-(void)reloadTheContentForGifts{
    
    
    if([giftsList count] && giftsList!=nil){
        [giftsList removeAllObjects];
        [giftsList release];
        giftsList=nil;
        
    }
    
    if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName]isEqualToString:@"flowers"]){
        giftsList=[[NSMutableArray alloc]initWithArray:flowersList];
    }
    else if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName]isEqualToString:@"gift cards"]){
        giftsList=[[NSMutableArray alloc]initWithArray:giftCarsList];
    }
    else if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName]isEqualToString:@"greeting cards"]){
        giftsList=[[NSMutableArray alloc]initWithArray:greetingCardsList];
    }
    
    [giftsTable reloadData];    
}
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
    else
        tranAnimationForGiftCategories=[self getAnimationForGiftCategories:kCATransitionFromLeft];
    
    for(UIView *subview in [giftCategoriesScroll subviews]){
        if([subview isKindOfClass:[UIButton class]]){
            [(UIButton*)subview setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    UIButton*targetBtn=(UIButton*)[giftCategoriesScroll viewWithTag:giftCatNum];
    [targetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    //Scroll the category titles to visible on the screen
    giftCategoriesScroll.scrollEnabled=YES;
    [giftCategoriesScroll scrollRectToVisible:targetBtn.frame animated:YES];
    giftCategoriesScroll.scrollEnabled=NO;       
    [giftsTable.layer addAnimation:tranAnimationForGiftCategories forKey:@"groupAnimation"];
    
    [self reloadTheContentForGifts];
    
    [giftsTable reloadData];
    //[giftsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
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
    
    if([giftsList count]%2==0)
        return [giftsList count]/2;
    else
        return [giftsList count]/2+1;
    
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
    cell.giftTitle_one.text=[[giftsList objectAtIndex:(indexPath.row*2)] giftTitle];
    
    NSArray *priceArray_one=[[[giftsList objectAtIndex:(indexPath.row*2)] giftPrice] componentsSeparatedByString:@";"];
    
    if([priceArray_one count]>1){
        ;
        cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_one objectAtIndex:0],[priceArray_one objectAtIndex:[priceArray_one count]-1]];
    }
    else
        cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@",[[giftsList objectAtIndex:(indexPath.row*2)] giftPrice]];
    [cell.giftIcon_one setImage:[[giftsList objectAtIndex:(indexPath.row*2)]giftThumbnail] forState:UIControlStateNormal];
    if([giftsList count]>(indexPath.row*2)+1){
        cell.giftIcon_two.hidden=NO;
        cell.giftPrice_two.hidden=NO;
        cell.giftTitle_two.hidden=NO;
        cell.giftTitle_two.text=[[giftsList objectAtIndex:(indexPath.row*2)+1]giftTitle];
        
        NSArray *priceArray_two=[[[giftsList objectAtIndex:(indexPath.row*2)+1] giftPrice] componentsSeparatedByString:@";"];
        
        if([priceArray_two count]>1){
            
            cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_two objectAtIndex:0],[priceArray_two objectAtIndex:[priceArray_two count]-1]];
        }
        else
            cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@",[[giftsList objectAtIndex:(indexPath.row*2)+1] giftPrice]];
        [cell.giftIcon_two setImage:[[giftsList objectAtIndex:(indexPath.row*2)+1]giftThumbnail] forState:UIControlStateNormal];
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
    GiftItemObject *selectedGift=[giftsList objectAtIndex:(rowNum*2+columNum)-1];
    
    if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName] isEqualToString:@"gift cards"]){
        GiftCardDetailsVC *giftCardDetails=[[GiftCardDetailsVC alloc]initWithNibName:@"GiftCardDetailsVC" bundle:nil];
        giftCardDetails.giftItemInfo=selectedGift;
        [self.navigationController pushViewController:giftCardDetails animated:YES];
        [giftCardDetails release];
    }
    else{
        
        Gift_GreetingCardDetailsVC *greetingCardDetails=[[Gift_GreetingCardDetailsVC alloc]initWithNibName:@"Gift_GreetingCardDetailsVC" bundle:nil];
        if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName] isEqualToString:@"flowers"])
            greetingCardDetails.isGreetingCard=NO;
        else if([[[giftCategoriesList objectAtIndex:giftCatNum-1] catName] isEqualToString:@"greeting cards"])
            greetingCardDetails.isGreetingCard=YES;
        greetingCardDetails.giftItemInfo=selectedGift;
        [self.navigationController pushViewController:greetingCardDetails animated:YES];
        [greetingCardDetails release];
    }
    
}
-(void)categoryActions:(id)sender{
    
    if(giftCatNum<[sender tag]){
        giftCatNum=[sender tag];
        [self swipingForGiftCategories:1];
    }
    else if(giftCatNum>[sender tag]){
        giftCatNum=[sender tag];
        [self swipingForGiftCategories:0];
    }
    
    giftCategoryPageControl.currentPage=giftCatNum-1;
    
    
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
    [self setGiftCategoriesScroll:nil];
    [self setGiftsList:nil];
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
    [profilePicImg release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftCategoryPageControl release];
    [giftsTable release];
    [giftCategoriesScroll release];
    
    [giftsList release];
    [super dealloc];
}

@end
