//
//  EventDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 24/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "EventDetailsVC.h"

@implementation EventDetailsVC
@synthesize profileImgView;
@synthesize nameLbl;
@synthesize eventNameLbl;
@synthesize eventDateLbl;
@synthesize likesCommentsLbl;
@synthesize commentsTable;
@synthesize eventDescription;
@synthesize eventImg;
@synthesize detailsScroll;
@synthesize isPhotoTagged;
//@synthesize basicInfoForMsg;

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
    
    NSString *profilePicId;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(redirectToLogin) name:@"LogOutAllAcounts" object:nil];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"]){
        linkedInLikes=0;
        lnk_giftgiv_eventDetails=[[LinkedIn_GiftGiv alloc]init];
        lnk_giftgiv_eventDetails.lnkInGiftGivDelegate=self;
        profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"linkedIn_userID"];
    }
    else {
        fb_giftgiv_eventDetails=[[Facebook_GiftGiv alloc]init];
        fb_giftgiv_eventDetails.fbGiftGivDelegate=self;
        profilePicId= [[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userID"];
    }
    
    
    
    listOfComments=[[NSMutableArray alloc]init];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"PositionTitle"]){
        nameLbl.frame=CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y-5, nameLbl.frame.size.width, nameLbl.frame.size.height);
        eventDateLbl.hidden=YES;
        eventNameLbl.frame=CGRectMake(eventNameLbl.frame.origin.x, eventNameLbl.frame.origin.y-5, 208, eventNameLbl.frame.size.height+10);
        eventNameLbl.numberOfLines=2;
        eventNameLbl.text=[NSString stringWithFormat:@"%@\n%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"PositionTitle"],[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"CompanyName"]];
    }
    else{
        eventDateLbl.hidden=NO;
        eventNameLbl.frame=CGRectMake(eventNameLbl.frame.origin.x, eventNameLbl.frame.origin.y, 115, eventNameLbl.frame.size.height);
        eventNameLbl.text=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"eventName"];
        eventDateLbl.text=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"eventDate"]];
        
        //Dynamic[fit] label width respected to the size of the text
        CGSize eventName_maxSize = CGSizeMake(115, 21);
        CGSize eventName_new_size=[eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        eventNameLbl.frame=CGRectMake(73, 87, eventName_new_size.width, 21);
        
        CGSize eventDate_maxSize = CGSizeMake(88, 21);
        CGSize eventDate_newSize = [eventDateLbl.text sizeWithFont:eventDateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        
        eventDateLbl.frame= CGRectMake(eventNameLbl.frame.origin.x+3+eventNameLbl.frame.size.width, 88, eventDate_newSize.width, 21);
    }
    
    nameLbl.text=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"userName"];
    
    
        
    NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",profilePicId]];
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath]){
        profileImgView.image=[UIImage imageWithContentsOfFile:filePath];
    }
    else{
        profileImgView.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
    }
    if([CheckNetwork connectedToNetwork]){
        [self showProgressHUD:self.view withMsg:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"msgID"])
            [fb_giftgiv_eventDetails getEventDetails:[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"msgID"]];
        else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"position_update_key"]){
            //call to linkedIn detailed events.
            if([lnk_giftgiv_eventDetails isLinkedInAuthorized]){
                [lnk_giftgiv_eventDetails getLikesForAnUpdat:[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"position_update_key"]];
                [lnk_giftgiv_eventDetails getListOfCommentsForTheUpdate:[[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedEventDetails"] objectForKey:@"position_update_key"]];
                
            }
        }
        
    }
        
}
-(void) requestFailed{
}
#pragma mark -Facebook delegates
- (void)facebookDidRequestFailed{
   
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
    AlertWithMessageAndDelegate(@"Oops!",@"There was a problem finding the details for the event. Please log back in.", self);
}
- (void)receivedDetailedEventInfo:(NSMutableDictionary*)eventDetails{
    
    GGLog(@"details..%@",eventDetails);
       
    int likesCount=[[[eventDetails objectForKey:@"likes"] objectForKey:@"data"] count];
    int commentsCount=[[[eventDetails objectForKey:@"comments"] objectForKey:@"data"] count];
    
    if([listOfComments count])
        [listOfComments removeAllObjects];
    if(listOfComments!=nil){
        [listOfComments release];
        listOfComments=nil;
    }
    listOfComments=[[NSMutableArray alloc]initWithArray:[[eventDetails objectForKey:@"comments"]objectForKey:@"data"]];
    shouldLoadingPicsStop=NO;
    [self loadProfilePictures];
    likesCommentsLbl.text=[NSString stringWithFormat:@"%d likes, %d comments",likesCount,commentsCount];
    
    if([eventDetails objectForKey:@"picture"]){
        //event photo's default frame 10, 120,300,170
        eventImg.frame=CGRectMake(10, 0, 300, 170);
        
        dispatch_queue_t ImageLoader_Q;
        ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
        dispatch_async(ImageLoader_Q, ^{
            
            NSString *urlStr=[eventDetails objectForKey:@"source"];
            
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            UIImage *eventPic = [UIImage imageWithData:data];
            
            if(eventPic!=nil){
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    eventImg.image=eventPic;                   
                    
                });
                
            }
            
        });
        dispatch_release(ImageLoader_Q);
        
        [detailsScroll addSubview:eventImg];
        likesCommentsLbl.frame=CGRectMake(13, 190, 221, 21);
        commentsTable.frame=CGRectMake(10, 219, 300, 80);
    }
    else{
        //event description's default frame 5, 115, 310, 100
        eventDescription.frame=CGRectMake(5, 0, 310, MAXFLOAT);
        
        eventDescription.text=[eventDetails objectForKey:@"message"];
        
        [detailsScroll addSubview:eventDescription];
        CGSize eventDescription_maxSize = CGSizeMake(310, MAXFLOAT);
        CGSize eventDescription_newSize=[eventDescription.text sizeWithFont:eventDescription.font constrainedToSize:eventDescription_maxSize lineBreakMode:UILineBreakModeWordWrap];
        eventDescription.frame=CGRectMake(5, 0,310, eventDescription_newSize.height+28);
        //GGLog(@"%@",NSStringFromCGSize(eventDescription_newSize));
        
        
        likesCommentsLbl.frame=CGRectMake(13, eventDescription.frame.origin.y+eventDescription.frame.size.height+5, 221, 21);
        
        commentsTable.frame=CGRectMake(10,likesCommentsLbl.frame.origin.y+21+5, 300,400-(likesCommentsLbl.frame.origin.y+21+5));
    }
    float tableHeight=0;
    for(int i=0;i<commentsCount;i++){
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica-Light" size:12.0];
        CGSize constraintSize = CGSizeMake(246.0f, MAXFLOAT);
        
        CGSize labelSize = [[NSString stringWithFormat:@"%@ %@",[[[listOfComments objectAtIndex:i]objectForKey:@"from"]objectForKey:@"name"],[[listOfComments objectAtIndex:i]objectForKey:@"message"]] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        if(labelSize.height>40)
            tableHeight+=labelSize.height+5;
        else
            tableHeight+=44+5;
    }
    
    commentsTable.frame=CGRectMake(commentsTable.frame.origin.x, commentsTable.frame.origin.y, 300, tableHeight);
    
    detailsScroll.contentSize=CGSizeMake(320, commentsTable.frame.origin.y+commentsTable.frame.size.height);
    [commentsTable reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [listOfComments count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	
	CommentsCustomCell *cell = (CommentsCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"CommentsCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
	}
    
    if([[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]){
        NSString *profileNameAndComment=[NSString stringWithFormat:@"%@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"message"]];
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:profileNameAndComment];
        
        attrStr.font=[UIFont fontWithName:@"Helvetica-Light" size:12];
        [attrStr setTextColor:[UIColor blackColor]];
        
        [attrStr setTextColor:[UIColor colorWithRed:0 green:0.67 blue:0.66 alpha:1.0] range:[profileNameAndComment rangeOfString:[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"]]];
        [attrStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:[profileNameAndComment rangeOfString:[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"]]];
        cell.commentsLbl.attributedText = attrStr;
    }
    else{
        NSString *profileNameAndComment=[NSString stringWithFormat:@"%@ %@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"person"]objectForKey:@"first-name"],[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"person"]objectForKey:@"last-name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"comment"]];
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:profileNameAndComment];
        
        attrStr.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
        [attrStr setTextColor:[UIColor colorWithRed:0 green:0.67 blue:0.66 alpha:1.0]];
        
        [attrStr setTextColor:[UIColor blackColor] range:[profileNameAndComment rangeOfString:[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"comment"]]];
        [attrStr setFont:[UIFont fontWithName:@"Helvetica-Light" size:12] range:[profileNameAndComment rangeOfString:[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"comment"]]];
        cell.commentsLbl.attributedText = attrStr;
    }
    cell.commentsLbl.textAlignment = UITextAlignmentLeft;
    
    
    if([[listOfComments objectAtIndex:indexPath.row] objectForKey:@"commentProPic"]){
        cell.profilePic.image=[[listOfComments objectAtIndex:indexPath.row] objectForKey:@"commentProPic"];
    }
    
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica-Light" size:12.0];
    CGSize constraintSize = CGSizeMake(246.0f, MAXFLOAT);
    CGSize labelSize;
    if([[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]){
        labelSize = [[NSString stringWithFormat:@"%@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"message"]] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    }
    else{
        labelSize = [[NSString stringWithFormat:@"%@ %@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"person"]objectForKey:@"first-name"],[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"person"]objectForKey:@"last-name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"comment"]] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    }
    
    if(labelSize.height>40)
        return labelSize.height+5;
    
    return 44+5;
}
#pragma mark -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self showProgressHUD:self.view withMsg:nil];
    settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    [settings performSelector:@selector(performLogoutAction)];
       
}
-(void)redirectToLogin{
    [self stopHUD];
    [settings release];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)loadProfilePictures{
    int commentsCount=[listOfComments count];
    
    for(int i=0;i<commentsCount;i++){
        
        if(![[listOfComments objectAtIndex:i] objectForKey:@"commentProPic"] && !shouldLoadingPicsStop){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[listOfComments objectAtIndex:i]objectForKey:@"from"])
                    urlStr=FacebookPicURL([[[listOfComments objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                else{
                    urlStr=[[[listOfComments objectAtIndex:i] objectForKey:@"person"] objectForKey:@"picture-url"];
                }
                
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[listOfComments objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"commentProPic"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [[listOfComments objectAtIndex:i] setObject:thumbnail forKey:@"commentProPic"];
                            
                            [commentsTable beginUpdates];
                            
                            [commentsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:i inSection:0], nil]
                                                 withRowAnimation:UITableViewRowAnimationNone];
                            [commentsTable endUpdates];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
}

#pragma mark -
- (IBAction)backToEventsList:(id)sender {
    shouldLoadingPicsStop=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showGiftCategories:(id)sender {
    
    GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
}
#pragma mark -LinkedIn Delegates
- (void)linkedInDidRequestFailed{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
- (void)receivedCommentsForAnUpdate:(id)comments{
    if([listOfComments count])
        [listOfComments removeAllObjects];
    if(listOfComments!=nil){
        [listOfComments release];
        listOfComments=nil;
    }
    if([[comments objectForKey:@"update-comment"] isKindOfClass:[NSDictionary class]]){
        if([comments allKeys]){
            listOfComments=[[NSMutableArray alloc]init];
            [listOfComments addObject:(NSDictionary*)[comments objectForKey:@"update-comment"]];
        }
        
    }
    else{
       
        listOfComments=[[NSMutableArray alloc]initWithArray:[(NSDictionary*)comments objectForKey:@"update-comment"]];
        
    }
    likesCommentsLbl.frame=CGRectMake(13, 5, 221, 21);
    if([listOfComments count]){
        int commentsCount=[listOfComments count];
        shouldLoadingPicsStop=NO;
        [self loadProfilePictures];
        
        likesCommentsLbl.text=[NSString stringWithFormat:@"%d likes %d comments",linkedInLikes,commentsCount];


        
        //event description's default frame 5, 115, 310, 100
        //eventDescription.frame=CGRectMake(5, 0, 310, 100);
       
        //eventDescription.text=[eventDetails objectForKey:@"message"];
        
        //[detailsScroll addSubview:eventDescription];
        /*CGSize eventDescription_maxSize = CGSizeMake(310, 100);
        CGSize eventDescription_newSize=[eventDescription.text sizeWithFont:eventDescription.font constrainedToSize:eventDescription_maxSize lineBreakMode:UILineBreakModeWordWrap];
        eventDescription.frame=CGRectMake(5, 0,310, eventDescription_newSize.height+28);
        //GGLog(@"%@",NSStringFromCGSize(eventDescription_newSize));
        
        
        likesCommentsLbl.frame=CGRectMake(13, eventDescription.frame.origin.y+eventDescription.frame.size.height+5, 221, 21);*/
        
        
        commentsTable.frame=CGRectMake(10,likesCommentsLbl.frame.origin.y+21+5, 300,400-(likesCommentsLbl.frame.origin.y+21+5));
        
        float tableHeight=0;
        for(int i=0;i<commentsCount;i++){
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica-Light" size:12.0];
            CGSize constraintSize = CGSizeMake(246.0f, MAXFLOAT);
            
            CGSize labelSize = [[NSString stringWithFormat:@"%@ %@ %@",[[[listOfComments objectAtIndex:i]objectForKey:@"person"]objectForKey:@"first-name"],[[[listOfComments objectAtIndex:i]objectForKey:@"person"]objectForKey:@"last-name"],[[listOfComments objectAtIndex:i]objectForKey:@"comment"]] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
            if(labelSize.height>40)
                tableHeight+=labelSize.height+5;
            else
                tableHeight+=44+5;
        }
        
        commentsTable.frame=CGRectMake(commentsTable.frame.origin.x, commentsTable.frame.origin.y, 300, tableHeight);
        
        detailsScroll.contentSize=CGSizeMake(320, commentsTable.frame.origin.y+commentsTable.frame.size.height);
        [commentsTable reloadData];
       
    }
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
- (void)receivedLikesForAnUpdate:(int)likesCount{
    linkedInLikes=likesCount;
    likesCommentsLbl.text=[NSString stringWithFormat:@"%d likes %d comments",likesCount,[listOfComments count]];
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
    [self setProfileImgView:nil];
    [self setNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setEventDateLbl:nil];
    [self setEventDescription:nil];
    [self setEventImg:nil];
    [self setLikesCommentsLbl:nil];
    [self setCommentsTable:nil];
    [self setDetailsScroll:nil];
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
    
    if(fb_giftgiv_eventDetails){
        [fb_giftgiv_eventDetails setFbGiftGivDelegate:nil];
        [fb_giftgiv_eventDetails release];
    }
    if(lnk_giftgiv_eventDetails){
        [lnk_giftgiv_eventDetails setLnkInGiftGivDelegate:nil];
        [lnk_giftgiv_eventDetails release];
    }
    [listOfComments release];
    
    [profileImgView release];
    [nameLbl release];
    [eventNameLbl release];
    [eventDateLbl release];
    [eventDescription release];
    [eventImg release];
    [likesCommentsLbl release];
    [commentsTable release];
    [detailsScroll release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LogOutAllAcounts" object:nil];
    [super dealloc];
}

@end
