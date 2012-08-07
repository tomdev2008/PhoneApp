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
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+3+profileNameLbl.frame.size.width, 56, eventName_newSize.width, 21);
    
    
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [giftsTable addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureForGiftCats:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [giftsTable addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    giftCategoriesList=[[NSMutableArray alloc] initWithObjects:@"cards",@"gift cards",@"flowers", nil];
    
    UIFont *catTitleFont=[UIFont fontWithName:@"Helvetica" size:25];
    
    int xOriginForButton=0;
    totalCats=[giftCategoriesList count];
    
    //Gift categories
    for(int i=0;i<totalCats;i++){
        
        //dynamic button width based on the title for it
        CGSize giftCatTitleSize=[[giftCategoriesList objectAtIndex:i] sizeWithFont:catTitleFont constrainedToSize:CGSizeMake(MAXFLOAT, 40) lineBreakMode:UILineBreakModeWordWrap];
        UIButton *giftCatBtn=[[UIButton alloc]initWithFrame:CGRectMake(xOriginForButton, 2, giftCatTitleSize.width, 40)];
        giftCatBtn.tag=i+1;
        [giftCatBtn addTarget:self action:@selector(categoryActions:) forControlEvents:UIControlEventTouchUpInside];
        [giftCatBtn.titleLabel setFont:catTitleFont];
        [giftCatBtn setTitle:[giftCategoriesList objectAtIndex:i] forState:UIControlStateNormal];
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
    
    [self reloadTheContentForGifts];
}
-(void)reloadTheContentForGifts{
    if([giftsList count] && giftsList!=nil){
        [giftsList removeAllObjects];
        [giftsList release];
        giftsList=nil;
        
    }
    giftsList=[[NSMutableArray alloc]initWithCapacity:50];
    for(int i=0;i<50;i++){
        NSMutableDictionary *giftDict=[[NSMutableDictionary alloc]init];
        [giftDict setObject:@"" forKey:@"GiftIconURL"];
        [giftDict setObject:[NSString stringWithFormat:@"%@ sample",[giftCategoriesList objectAtIndex:giftCatNum-1]] forKey:@"GiftTitle"];
        [giftDict setObject:[NSString stringWithFormat:@"$%d.99",giftCatNum-1] forKey:@"GiftPrice"];
        [giftsList addObject:giftDict];
        [giftDict release];
    }
    
}
-(void)swipeGestureForGiftCats:(UISwipeGestureRecognizer*)swipeRecognizer{
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
    [giftsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
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
	return 25;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	tableView.backgroundColor=[UIColor clearColor];
	GiftCustomCell *cell = (GiftCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.tag=indexPath.row;  
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"GiftCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        cell.giftTitle_one.text=[[giftsList objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftTitle"];
        cell.giftPrice_one.text=[[giftsList objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftPrice"];
        cell.giftTitle_two.text=[[giftsList objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftTitle"];
        cell.giftPrice_two.text=[[giftsList objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftPrice"];
        [cell.giftIcon_one addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.giftIcon_two addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
		
	}
    
    
	return cell;
}
#pragma mark -
-(void)giftTileIconTapped:(id)sender{
    
    int rowNum=[(GiftCustomCell*)[(UIButton*)sender superview] tag];
    int columNum=[sender tag];
    NSDictionary *selectedGift=[giftsList objectAtIndex:(rowNum*2+columNum)-1];
    NSLog(@"%@",selectedGift);
    
    if([[giftCategoriesList objectAtIndex:giftCatNum-1] isEqualToString:@"gift cards"]){
        GiftCardDetailsVC *giftCardDetails=[[GiftCardDetailsVC alloc]initWithNibName:@"GiftCardDetailsVC" bundle:nil];
        [self.navigationController pushViewController:giftCardDetails animated:YES];
        [giftCardDetails release];
    }
    else{
        
        Gift_GreetingCardDetailsVC *greetingCardDetails=[[Gift_GreetingCardDetailsVC alloc]initWithNibName:@"Gift_GreetingCardDetailsVC" bundle:nil];
        if([[giftCategoriesList objectAtIndex:giftCatNum-1] isEqualToString:@"flowers"])
            greetingCardDetails.isGreetingCard=NO;
        else
            greetingCardDetails.isGreetingCard=YES;
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
    
    [profilePicImg release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftCategoryPageControl release];
    [giftsTable release];
    [giftCategoriesScroll release];
    [giftCategoriesList release];
    [giftsList release];
    [super dealloc];
}

@end
