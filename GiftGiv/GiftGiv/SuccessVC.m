//
//  SuccessVC.m
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SuccessVC.h"

@implementation SuccessVC
@synthesize upcomingEventsTable;
@synthesize contentScroll;
@synthesize upcomingEvents;
//@synthesize transactionID;


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
    
    upcomingEvents=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"]];
    fm=[NSFileManager defaultManager];
    float tableHeight=[upcomingEvents count]*60;
    
    upcomingEventsTable.frame=CGRectMake(upcomingEventsTable.frame.origin.x, upcomingEventsTable.frame.origin.y, upcomingEventsTable.frame.size.width, tableHeight);
    
    contentScroll.contentSize=CGSizeMake(320, upcomingEventsTable.frame.origin.y+upcomingEventsTable.frame.size.height);
    
    [upcomingEventsTable reloadData];
    
    
    [self loadProfilePictures];
}
-(void) loadProfilePictures{
   
    int upcomingsCount=[upcomingEvents count];
    dispatch_queue_t ImageLoader_Q;
    ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
    
    for(int i=0;i<upcomingsCount;i++){
        
        NSString *urlStr_id=nil;
        if([[upcomingEvents objectAtIndex:i]objectForKey:@"uid"])
            urlStr_id=[[upcomingEvents objectAtIndex:i]objectForKey:@"uid"];//FacebookPicURL([[allupcomingEvents objectAtIndex:i]objectForKey:@"uid"]);
        else if([[upcomingEvents objectAtIndex:i]objectForKey:@"from"])
            urlStr_id=[[[upcomingEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"];//FacebookPicURL([[[allupcomingEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
        else if([[upcomingEvents objectAtIndex:i]objectForKey:@"linkedIn_id"])
            urlStr_id=[[upcomingEvents objectAtIndex:i]objectForKey:@"linkedIn_id"];
        else if([[upcomingEvents objectAtIndex:i]objectForKey:@"FBID"])
            urlStr_id=[[upcomingEvents objectAtIndex:i]objectForKey:@"FBID"];
        
        if(urlStr_id){
            
            
            //NSLog(@"%@",[NSString stringWithFormat:@"%@.png",urlStr_id]);
            if (![fm fileExistsAtPath: [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",urlStr_id]]]){
                                
                NSString *picture_url=nil;
                if([[upcomingEvents objectAtIndex:i]objectForKey:@"uid"])
                {
                    if([[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"])
                        picture_url=[[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"];
                    else
                        picture_url=FacebookPicURL([[upcomingEvents objectAtIndex:i]objectForKey:@"uid"]);
                        
                    
                }
                else if([[upcomingEvents objectAtIndex:i]objectForKey:@"from"])
                {
                    if([[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"])
                        picture_url=[[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"];
                        
                    else
                        picture_url=FacebookPicURL([[[upcomingEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                                            
                    
                }
                else if([[upcomingEvents objectAtIndex:i]objectForKey:@"FBID"])
                {
                    if([[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"])
                        picture_url=[[upcomingEvents objectAtIndex:i]objectForKey:@"pic_square"];
                    
                    else
                        picture_url=FacebookPicURL([[upcomingEvents objectAtIndex:i]objectForKey:@"FBID"]);
                                          
                    
                }
                else if([[upcomingEvents objectAtIndex:i]objectForKey:@"linkedIn_id"])
                {
                    picture_url=[[upcomingEvents objectAtIndex:i]objectForKey:@"pic_url"];
                   
                    
                }
                
                dispatch_async(ImageLoader_Q, ^{
                    
                    //NSString *urlStr=[tempDict objectForKey:@"profile_url"];
                    
                    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:picture_url]];
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail==nil){
                        
                        
                    }
                    else {
                        
                        
                        NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",urlStr_id]]; //Add the file name
                        [UIImagePNGRepresentation(thumbnail) writeToFile:filePath atomically:YES]; //Write the file
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            NSArray *tableCells=[upcomingEventsTable visibleCells];
                            for(int i=0; i<[tableCells count];i++ ){
                                if([[(EventCustomCell*)[tableCells objectAtIndex:i] profileId] isEqualToString:[NSString stringWithFormat:@"%@",urlStr_id]]){
                                    NSIndexPath *indexPath=[upcomingEventsTable indexPathForCell:(EventCustomCell*)[tableCells objectAtIndex:i]];
                                    [upcomingEventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                }
                            }
                            
                        });
                    }
                    
                });
                
                
            }
            
        }
    }
    dispatch_release(ImageLoader_Q);
}

#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [upcomingEvents count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	tableView.backgroundColor=[UIColor clearColor];
	EventCustomCell *cell = (EventCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"EventCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.bubbleIconForCommentsBtn.tag=indexPath.row;
        [cell.bubbleIconForCommentsBtn addTarget:self action:@selector(eventDetailsAction:) forControlEvents:UIControlEventTouchUpInside];
        
	}
    if([upcomingEvents count]){
        
        if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
            cell.bubbleIconForCommentsBtn.hidden=NO;
            cell.profileNameLbl.text=[[[upcomingEvents objectAtIndex:indexPath.row]objectForKey:@"from"] objectForKey:@"name"];
            
        }
        else if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
            cell.bubbleIconForCommentsBtn.hidden=NO;
            cell.profileNameLbl.text=[[upcomingEvents objectAtIndex:indexPath.row]objectForKey:@"FBName"] ;
            
        }
        else{
            cell.profileNameLbl.text=[[upcomingEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"isEventFromQuery"]){
                if([[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"isEventFromQuery"]isEqualToString:@"true"])
                    cell.bubbleIconForCommentsBtn.hidden=NO;
                else
                    cell.bubbleIconForCommentsBtn.hidden=YES;
            }
            else {
                cell.bubbleIconForCommentsBtn.hidden=YES;
            }
        }
        cell.eventNameLbl.text=[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"];
        
        
        NSString *dateDisplay=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"event_date"]];//[self updatedDateToBeDisplayedForTheEvent:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"event_date"]];
        if([dateDisplay isEqualToString:@"Today"]||[dateDisplay isEqualToString:@"Yesterday"]||[dateDisplay isEqualToString:@"Tomorrow"]||[dateDisplay isEqualToString:@"Recent"]){
            cell.dateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
            //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica-Bold" size:7.0];
        }
        else{
            //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica" size:7.0];
            cell.dateLbl.textColor=[UIColor blackColor];
        }
        cell.dateLbl.text=dateDisplay;
        
        
        if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
            
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"]]];
           
            if([fm fileExistsAtPath:filePath]){
                cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
            }
            
            
        }
        else if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
            
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]]];
           
            if([fm fileExistsAtPath:filePath]){
                cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
            }
            
            
        }
        else{
            if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]){
                
                NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]]];
                
                if([fm fileExistsAtPath:filePath]){
                    cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
                }
                
            }
            
            else if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]){
                NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]]];
                
                if([fm fileExistsAtPath:filePath]){
                    cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
                }
                
            }
            
        }
                     
        
    }
    //Dynamic[fit] label width respected to the size of the text
    CGSize eventName_maxSize = CGSizeMake(113, 21);
    CGSize eventName_new_size=[cell.eventNameLbl.text sizeWithFont:cell.eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    cell.eventNameLbl.frame=CGRectMake(63, 29, eventName_new_size.width, 21);
    
    CGSize eventDate_maxSize = CGSizeMake(90, 21);
    CGSize eventDate_newSize = [cell.dateLbl.text sizeWithFont:cell.dateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    cell.dateLbl.frame= CGRectMake(cell.eventNameLbl.frame.origin.x+3+cell.eventNameLbl.frame.size.width, 29, eventDate_newSize.width, 21);
	return cell;
}
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Gift options screen
    GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
    
    
    NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
    if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
        [tempInfoDict setObject:[[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        [tempInfoDict setObject:[[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
    }
    else if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
    }
    else{
        if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"])
            [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
        else if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
            [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
    }
    if([[upcomingEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
    if([[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
    
    [tempInfoDict setObject:[[upcomingEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
    
    [tempInfoDict release];
    
     
    
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
    
}
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    
    if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
        details.isPhotoTagged=YES;
    }
    else
        details.isPhotoTagged=NO;
    
    NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
    
    if([[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
        [tempInfoDict setObject:[[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
    else if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]forKey:@"userID"];
    else if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]forKey:@"userID"];
    if([[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
        [tempInfoDict setObject:[[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
    else if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
    else if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
    
    [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
    [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
    
    if([[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"])
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
    else    
        [tempInfoDict setObject:[[upcomingEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
    //NSLog(@" temp dict..%@",tempInfoDict);
    
    [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
    
    [tempInfoDict release];
    
    
    
    [self.navigationController pushViewController:details animated:YES];
    [details release];
    
}
#pragma mark -
- (IBAction)backToHome:(id)sender {
    if([[[self.navigationController viewControllers] objectAtIndex:1] isKindOfClass:[HomeScreenVC class]]){
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
    else {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }
}

/*- (IBAction)onlineSite:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://giftgiv.com"]];
}*/

- (IBAction)getOrders:(id)sender {
    OrderHistoryListVC *orders=[[OrderHistoryListVC alloc]initWithNibName:@"OrderHistoryListVC" bundle:nil];
    [self.navigationController pushViewController:orders animated:YES];
    [orders release];
}
#pragma mark -
- (void)viewDidUnload
{
    [self setUpcomingEventsTable:nil];
    [self setContentScroll:nil];
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
    //[transactionID release];
    [upcomingEvents release];
    [upcomingEventsTable release];
    [contentScroll release];
    [super dealloc];
}
@end
