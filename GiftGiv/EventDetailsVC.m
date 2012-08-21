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
@synthesize isPhotoTagged;
@synthesize basicInfoForMsg;

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
    
    basicInfoForMsg=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDetails"];
    
    listOfComments=[[NSMutableArray alloc]init];
    
    eventNameLbl.text=[basicInfoForMsg objectForKey:@"eventName"];
    eventDateLbl.text=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[basicInfoForMsg objectForKey:@"eventDate"]];
    nameLbl.text=[basicInfoForMsg objectForKey:@"userName"];
    
    
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    dispatch_async(ImageLoader_Q, ^{
        
        NSString *urlStr=FacebookPicURL([basicInfoForMsg objectForKey:@"userID"]);
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                profileImgView.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];                
                
            });
            
        }
        else {
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                profileImgView.image=thumbnail;                   
                
            });
        }
        
    });
    dispatch_release(ImageLoader_Q);
    
    if([CheckNetwork connectedToNetwork]){
        [self showProgressHUD:self.view withMsg:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
        [[Facebook_GiftGiv sharedSingleton] getEventDetails:[basicInfoForMsg objectForKey:@"msgID"]];
        
    }
    
    
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize eventName_maxSize = CGSizeMake(115, 21);
    CGSize eventName_new_size=[eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    eventNameLbl.frame=CGRectMake(70, 87, eventName_new_size.width, 21);
    
    CGSize eventDate_maxSize = CGSizeMake(88, 21);
    CGSize eventDate_newSize = [eventDateLbl.text sizeWithFont:eventDateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventDateLbl.frame= CGRectMake(eventNameLbl.frame.origin.x+3+eventNameLbl.frame.size.width, 88, eventDate_newSize.width, 21);
    
    
    
}
#pragma mark -Facebook delegates
- (void)facebookDidRequestFailed{
    [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
    AlertWithMessageAndDelegate(@"Oops!",@"Something went wrong, please try agin later", nil);
}
- (void)receivedDetailedEventInfo:(NSMutableDictionary*)eventDetails{
    
    //NSLog(@"%@",eventDetails);
    
    [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:nil];
    
    [self stopHUD];
    
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
    
    if(isPhotoTagged){
        //event photo's default frame 10, 120,300,170
        eventImg.frame=CGRectMake(10, 120, 300, 170);
        
        dispatch_queue_t ImageLoader_Q;
        ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
        dispatch_async(ImageLoader_Q, ^{
            
            NSString *urlStr=[eventDetails objectForKey:@"picture"];
            
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            UIImage *eventPic = [UIImage imageWithData:data];
            
            if(eventPic!=nil){
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    eventImg.image=eventPic;                   
                    
                });
                
            }
            
        });
        dispatch_release(ImageLoader_Q);
        
        [self.view addSubview:eventImg];
        likesCommentsLbl.frame=CGRectMake(13, 290, 221, 21);
        commentsTable.frame=CGRectMake(10, 319, 300, 80);
    }
    else{
        //event description's default frame 5, 115, 310, 100
        eventDescription.frame=CGRectMake(5, 115, 310, 100);
        
        eventDescription.text=[eventDetails objectForKey:@"message"];
        
        [self.view addSubview:eventDescription];
        CGSize eventDescription_maxSize = CGSizeMake(310, 100);
        CGSize eventDescription_newSize=[eventDescription.text sizeWithFont:eventDescription.font constrainedToSize:eventDescription_maxSize lineBreakMode:UILineBreakModeWordWrap];
        eventDescription.frame=CGRectMake(5, 115,310, eventDescription_newSize.height+28);
        //NSLog(@"%@",NSStringFromCGSize(eventDescription_newSize));
        
        
        likesCommentsLbl.frame=CGRectMake(13, eventDescription.frame.origin.y+eventDescription.frame.size.height+5, 221, 21);
        
        commentsTable.frame=CGRectMake(10,likesCommentsLbl.frame.origin.y+21+5, 300,400-(likesCommentsLbl.frame.origin.y+21+5));
    }
    [commentsTable reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
	tableView.backgroundColor=[UIColor clearColor];
	CommentsCustomCell *cell = (CommentsCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"CommentsCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
	}
    
    NSString *profileNameAndComment=[NSString stringWithFormat:@"%@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"message"]];
    NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:profileNameAndComment];
    
    attrStr.font=[UIFont fontWithName:@"Helvetica" size:14];
    [attrStr setTextColor:[UIColor blackColor]];
    
    [attrStr setTextColor:[UIColor colorWithRed:0 green:0.67 blue:0.66 alpha:1.0] range:[profileNameAndComment rangeOfString:[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"]]];
    [attrStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:[profileNameAndComment rangeOfString:[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"]]];
    cell.commentsLbl.attributedText = attrStr;
    cell.commentsLbl.textAlignment = UITextAlignmentLeft;
    
    
    if([[listOfComments objectAtIndex:indexPath.row] objectForKey:@"commentProPic"]){
        cell.profilePic.image=[[listOfComments objectAtIndex:indexPath.row] objectForKey:@"commentProPic"];
    }
    
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(246.0f, MAXFLOAT);
    
    CGSize labelSize = [[NSString stringWithFormat:@"%@ %@",[[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"from"]objectForKey:@"name"],[[listOfComments objectAtIndex:indexPath.row]objectForKey:@"message"]] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    if(labelSize.height>40)
        return labelSize.height+5;
    
    return 44+5;
}
#pragma mark - 
-(void)loadProfilePictures{
    int commentsCount=[listOfComments count];
    
    for(int i=0;i<commentsCount;i++){
        
        if(![[listOfComments objectAtIndex:i] objectForKey:@"commentProPic"] && !shouldLoadingPicsStop){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr=FacebookPicURL([[[listOfComments objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[listOfComments objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"commentProPic"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            
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
    [listOfComments release];
    [basicInfoForMsg release];
    [profileImgView release];
    [nameLbl release];
    [eventNameLbl release];
    [eventDateLbl release];
    [eventDescription release];
    [eventImg release];
    [likesCommentsLbl release];
    [commentsTable release];
    [super dealloc];
}

@end
