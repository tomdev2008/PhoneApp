//
//  HomeScreenVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "HomeScreenVC.h"

@implementation HomeScreenVC
@synthesize eventsBgView;
@synthesize pageControlForEventGroups;
@synthesize eventsTable;
@synthesize eventTitleLbl;
//@synthesize eventTitle_2_Lbl;
//@synthesize events_2_Table;

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
    fb_giftgiv_home=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_home.fbGiftGivDelegate=self;
    
    categoryTitles=[[NSMutableArray alloc]init];
    listOfBirthdayEvents=[[NSMutableArray alloc]init];
    newJobEvents=[[NSMutableArray alloc]init];
    anniversaryEvents=[[NSMutableArray alloc]init];
    congratsEvents=[[NSMutableArray alloc]init];
    allupcomingEvents=[[NSMutableArray alloc]init];
    
    eventTitleLbl.text=events_category_1;
    
    
    if(currentiOSVersion<6.0){
        pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive" ofType:@"png"] retain];
        pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive" ofType:@"png"] retain];
    }
    
    if(currentiOSVersion>=6.0){
        
        //Enable the below statements when the project is compiled with iOS 6.0 and change the colors for the dots
        /*[pageControlForEventGroups setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0]];
         [pageControlForEventGroups setPageIndicatorTintColor:[UIColor colorWithRed:0.4431 green:0.8902 blue:0.9254 alpha:1.0]];*/
    }
    
    
    [self performSelector:@selector(loadGestures)withObject:nil afterDelay:0.1];
    
    
    eventGroupNum=1;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    [super viewDidLoad];
    
}
-(void)loadGestures{
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [eventsBgView addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [eventsBgView addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
}
-(void)viewWillAppear:(BOOL)animated{
    
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"] ){
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]){
            //[self showProgressHUD:self.view withMsg:nil];
            [self performSelector:@selector(makeRequestToGetEvents)];
        }
        
        else{
            if([CheckNetwork connectedToNetwork]){
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
                
                [fb_giftgiv_home listOfBirthdayEvents];
                
            }
        }
    }
    
    [eventsTable reloadData];
    ////[events_2_Table reloadData];
    [super viewWillAppear:YES];
}
-(void)makeRequestToGetEvents{
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        //NSLog(@"gift home id..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetEvents>\n<tem:userId>%@</tem:userId>\n<tem:typeEventList>Display</tem:typeEventList>\n</tem:GetEvents>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetEvents"];
        
        GetEventsRequest *getEvents=[[GetEventsRequest alloc]init];
        [getEvents setEventsDelegate:self];
        [getEvents getListOfEvents:theRequest];
        [getEvents release];
    }
    else{
        AlertWithMessageAndDelegate(@"Network connectivity", @"Please check your network connection", nil);
    }
}
#pragma -EventsRequest delegate
-(void) receivedAllEvents:(NSMutableArray*)allEvents{
   
    int eventsCount=[allEvents count];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:eventsCount];
    
    if(eventsCount){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self stopHUD];
        if([allupcomingEvents count])
            [allupcomingEvents removeAllObjects];
        if([listOfBirthdayEvents count])
            [listOfBirthdayEvents removeAllObjects];
        if([newJobEvents count])
            [newJobEvents removeAllObjects];
        if([congratsEvents count])
            [congratsEvents removeAllObjects];
        if([anniversaryEvents count])
            [anniversaryEvents removeAllObjects];
        
        for (int i=0;i<eventsCount;i++){
            NSMutableDictionary *eventDict=[[NSMutableDictionary alloc]init];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_FriendId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"uid"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_EventId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"id"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_Name]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
                        
            [eventDict setObject:[[[allEvents objectAtIndex:i]eventName]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_type"];
            [eventDict setObject:[[[[[allEvents objectAtIndex:i]eventdate]componentsSeparatedByString:@"T"]objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_date"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]isEventFromQuery]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"isEventFromQuery"];
            [eventDict setObject:@"" forKey:@"ProfilePicture"];
            NSString *eventType=[[[allEvents objectAtIndex:i]eventType]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([eventType isEqualToString:@"Birthday"])
                [listOfBirthdayEvents addObject:eventDict];
            else if([eventType isEqualToString:@"New Job"])
                [newJobEvents addObject:eventDict];
            else if([eventType isEqualToString:@"Congratulations"])
                [congratsEvents addObject:eventDict];
            else if([eventType isEqualToString:@"Relationship"])
                [anniversaryEvents addObject:eventDict];
            
            [allupcomingEvents addObject:eventDict];
            [eventDict release];
            
        }
        //NSLog(@"%@",allupcomingEvents);
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        //[self performSelector:@selector(updateNextColumnTitle)];
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([listOfBirthdayEvents count]>1)
            [self sortEvents:listOfBirthdayEvents eventCategory:2];
        if([newJobEvents count]>1)
            [self sortEvents:newJobEvents eventCategory:4];
        if([congratsEvents count]>1)
            [self sortEvents:congratsEvents eventCategory:5];
        if([anniversaryEvents count]>1)
            [self sortEvents:anniversaryEvents eventCategory:3];
        
        [[NSUserDefaults standardUserDefaults]setObject:allupcomingEvents forKey:@"AllUpcomingEvents"];
        //eventTitleLbl.text=events_category_1;
        shouldLoadingPicsStop=YES;
        [self loadProfilePictures];     
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[self stopHUD];
        
        [eventsTable reloadData];
        //////[events_2_Table reloadData];
    }
    else{
        if([CheckNetwork connectedToNetwork]){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
            [fb_giftgiv_home listOfBirthdayEvents];
            
        }
    }
}
#pragma mark -
-(void)swipingForEventGroups:(UISwipeGestureRecognizer*)swipeRecognizer{
    
    // The events list should be in carousel effect
    
    //previous
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if(eventGroupNum>1)
		{						
			eventGroupNum--;
			
			[self swiping:0];
            
		}
		else if(eventGroupNum==1 && totalGroups!=0)
		{
			eventGroupNum=totalGroups;
			[self swiping:0];
		}
    }
    //next
    else if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if(eventGroupNum<totalGroups)
		{					
			eventGroupNum++;
			
			[self swiping:1];
			
        }
		else if(eventGroupNum==totalGroups)
		{
			eventGroupNum=1;
			[self swiping:1];
		}
    }
    pageControlForEventGroups.currentPage=eventGroupNum-1;
}
-(void)swiping:(int)swipeDirectionNum{
    
    if(swipeDirectionNum==1){
        tranAnimationForEventGroups=[self getAnimationForEventGroup:kCATransitionFromRight];
    }
    else
        tranAnimationForEventGroups=[self getAnimationForEventGroup:kCATransitionFromLeft];
    
    [eventsBgView.layer addAnimation:tranAnimationForEventGroups forKey:@"groupAnimation"];
    
    eventTitleLbl.text=[categoryTitles objectAtIndex:eventGroupNum-1];
    
    //[self performSelector:@selector(updateNextColumnTitle)];
    
    
    [eventsTable reloadData];
    ////[events_2_Table reloadData];
}
-(void)checkTotalNumberOfGroups{
    totalGroups=0;
    if([categoryTitles count])
        [categoryTitles removeAllObjects];
    if([allupcomingEvents count]){
        
        [categoryTitles addObject:events_category_1];
        totalGroups++;
    }
    if([listOfBirthdayEvents count]){
        
        [categoryTitles addObject:events_category_2];
        totalGroups++;
    }
    if([anniversaryEvents count]){
        
        [categoryTitles addObject:events_category_3];
        totalGroups++;
    }    
    if([newJobEvents count]){
        
        [categoryTitles addObject:events_category_4];
        totalGroups++;
    }
    
    if([congratsEvents count]){
        
        [categoryTitles addObject:events_category_5];
        totalGroups++;
    }
    
    pageControlForEventGroups.numberOfPages=totalGroups;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
}
#pragma mark - Transition
-(CATransition *)getAnimationForEventGroup:(NSString *)animationType
{
	CATransition *animation1 = [CATransition animation];
	animation1.duration = 0.6f;//0.4f
	//animation1.timingFunction = UIViewAnimationCurveEaseInOut;
	animation1.type = kCATransitionPush;
	
	animation1.subtype = animationType;
	
	return animation1;
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if([tableView isEqual:eventsTable]){
        if([eventTitleLbl.text isEqualToString:events_category_1]){
            
            return [allupcomingEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_2]){
            return [listOfBirthdayEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_3]){
            return [anniversaryEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_4]){
            return [newJobEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_5]){
            return [congratsEvents count];
            
        }
    }
    /*else if([tableView isEqual:events_2_Table]){
        if([eventTitle_2_Lbl.text isEqualToString:events_category_1]){
            
            return [allupcomingEvents count];
            
        }
        if([eventTitle_2_Lbl.text isEqualToString:events_category_2]){
            return [listOfBirthdayEvents count];
            
        }
        if([eventTitle_2_Lbl.text isEqualToString:events_category_3]){
            return [anniversaryEvents count];
            
        }
        if([eventTitle_2_Lbl.text isEqualToString:events_category_4]){
            return [newJobEvents count];
            
        }
        if([eventTitle_2_Lbl.text isEqualToString:events_category_5]){
            return [congratsEvents count];
            
        }
    }
    */
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([tableView isEqual:eventsTable]){
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
        if([eventTitleLbl.text isEqualToString:events_category_1]){
            if([allupcomingEvents count]){
                //NSLog(@"upcoming..%@",allupcomingEvents);
                [self loadEventsData:allupcomingEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
            }
        }
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
            
            if([listOfBirthdayEvents count]){
                //NSLog(@"list of birthdays..%@",listOfBirthdayEvents);
                [self loadEventsData:listOfBirthdayEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
                
            }
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
            
            if([anniversaryEvents count]){
                //NSLog(@"list of anniversaries..%@",anniversaryEvents);
                [self loadEventsData:anniversaryEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
                
            }
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4]){
            
            if([newJobEvents count]){
                //NSLog(@"list of newJobEvents..%@",newJobEvents);
                [self loadEventsData:newJobEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];   
            }
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_5]){
            
            if([congratsEvents count]){
               // NSLog(@"list of congratsEvents..%@",congratsEvents);
                
                [self loadEventsData:congratsEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
            }
            
        }
        
        
        //Dynamic[fit] label width respected to the size of the text
        CGSize eventName_maxSize = CGSizeMake(113, 21);
        CGSize eventName_new_size=[cell.eventNameLbl.text sizeWithFont:cell.eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        cell.eventNameLbl.frame=CGRectMake(63, 29, eventName_new_size.width, 21);
        
        CGSize eventDate_maxSize = CGSizeMake(90, 21);
        CGSize eventDate_newSize = [cell.dateLbl.text sizeWithFont:cell.dateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        
        cell.dateLbl.frame= CGRectMake(cell.eventNameLbl.frame.origin.x+3+cell.eventNameLbl.frame.size.width, 30, eventDate_newSize.width, 21); 
        
        return cell;
    }
    /*else if([tableView isEqual:events_2_Table]){
        
        static NSString *cellIdentifier_2;
        cellIdentifier_2=[NSString stringWithFormat:@"Cell_2_%d",indexPath.row];
        tableView.backgroundColor=[UIColor clearColor];
        EventCustomCell *cell_two = (EventCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
        
        if (cell_two == nil) {
            
            cell_two=[[[NSBundle mainBundle]loadNibNamed:@"EventCustomCell" owner:self options:nil] lastObject];
            
            cell_two.selectionStyle=UITableViewCellSelectionStyleNone;
            cell_two.bubbleIconForCommentsBtn.tag=indexPath.row;
            [cell_two.bubbleIconForCommentsBtn addTarget:self action:@selector(eventDetailsAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        if([eventTitle_2_Lbl.text isEqualToString:events_category_1]){
            if([allupcomingEvents count]){
               // NSLog(@"upcoming...2..%@",allupcomingEvents);
                [self loadEventsData:allupcomingEvents withCell:cell_two inTable:events_2_Table forIndexPath:indexPath];
                
            }
        }
        else if([eventTitle_2_Lbl.text isEqualToString:events_category_2]){
            
            if([listOfBirthdayEvents count]){
                //NSLog(@"birthday.....2..%@",listOfBirthdayEvents);
                [self loadEventsData:listOfBirthdayEvents withCell:cell_two inTable:events_2_Table forIndexPath:indexPath];
                
                
            }
            
        }
        else if([eventTitle_2_Lbl.text isEqualToString:events_category_3]){
            
            if([anniversaryEvents count]){
                 //NSLog(@"anniversaries.....2..%@",anniversaryEvents);
                [self loadEventsData:anniversaryEvents withCell:cell_two inTable:events_2_Table forIndexPath:indexPath];
                
                
            }
            
        }
        else if([eventTitle_2_Lbl.text isEqualToString:events_category_4]){
            
            if([newJobEvents count]){
                //NSLog(@"newjob.......2..%@",newJobEvents);
                [self loadEventsData:newJobEvents withCell:cell_two inTable:events_2_Table forIndexPath:indexPath];   
            }
            
        }
        else if([eventTitle_2_Lbl.text isEqualToString:events_category_5]){
            
            if([congratsEvents count]){
                
                //NSLog(@"congratsEvents.......2..%@",congratsEvents);
                [self loadEventsData:congratsEvents withCell:cell_two inTable:events_2_Table forIndexPath:indexPath];
                
            }
            
        }
        
        
        //Dynamic[fit] label width respected to the size of the text
        CGSize eventName_maxSize = CGSizeMake(113, 21);
        CGSize eventName_new_size=[cell_two.eventNameLbl.text sizeWithFont:cell_two.eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        cell_two.eventNameLbl.frame=CGRectMake(63, 29, eventName_new_size.width, 21);
        
        CGSize eventDate_maxSize = CGSizeMake(90, 21);
        CGSize eventDate_newSize = [cell_two.dateLbl.text sizeWithFont:cell_two.dateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        
        cell_two.dateLbl.frame= CGRectMake(cell_two.eventNameLbl.frame.origin.x+3+cell_two.eventNameLbl.frame.size.width, 30, eventDate_newSize.width, 21); 
        
        return cell_two;
    }*/
	return nil;
}
-(void)loadEventsData:(NSMutableArray*)sourceArray withCell:(EventCustomCell*)cell inTable:(UITableView*)table forIndexPath:(NSIndexPath*)indexPath{
    
    if([[sourceArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
        cell.bubbleIconForCommentsBtn.hidden=NO;
        cell.profileNameLbl.text=[[[sourceArray objectAtIndex:indexPath.row]objectForKey:@"from"] objectForKey:@"name"];
        
    }
    else{
        cell.profileNameLbl.text=[[sourceArray objectAtIndex:indexPath.row]objectForKey:@"name"];
        if([[sourceArray objectAtIndex:indexPath.row] objectForKey:@"isEventFromQuery"]){
            if([[[sourceArray objectAtIndex:indexPath.row] objectForKey:@"isEventFromQuery"]isEqualToString:@"true"])
                cell.bubbleIconForCommentsBtn.hidden=NO;
            else
                cell.bubbleIconForCommentsBtn.hidden=YES;
        }
        else {
            cell.bubbleIconForCommentsBtn.hidden=YES;
        }
    }
    cell.eventNameLbl.text=[[sourceArray objectAtIndex:indexPath.row] objectForKey:@"event_type"];
    
    
    NSString *dateDisplay=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[[sourceArray objectAtIndex:indexPath.row] objectForKey:@"event_date"]];//[self updatedDateToBeDisplayedForTheEvent:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"event_date"]];
    if([dateDisplay isEqualToString:@"Today"]||[dateDisplay isEqualToString:@"Yesterday"]||[dateDisplay isEqualToString:@"Tomorrow"]||[dateDisplay isEqualToString:@"Recent"]){
        cell.dateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
        //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica-Bold" size:7.0];
    }
    else{
        //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica" size:7.0];
        cell.dateLbl.textColor=[UIColor blackColor];
    }
    cell.dateLbl.text=dateDisplay;
    
    if([[[sourceArray objectAtIndex:indexPath.row] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
        cell.profileImg.image=[[sourceArray objectAtIndex:indexPath.row] objectForKey:@"ProfilePicture"];
    }
    
    
    
}
/*-(NSString*)updatedDateToBeDisplayedForTheEvent:(id)eventDate{
 
 if(customDateFormat==nil){
 customDateFormat=[[NSDateFormatter alloc]init];
 }
 NSString *endDateString;
 
 if([eventDate isKindOfClass:[NSString class]]){
 
 eventDate=[NSString stringWithFormat:@"%@",eventDate];
 
 [customDateFormat setDateFormat:@"yyyy-MM-dd"];
 NSDate *tempDate = [customDateFormat dateFromString:eventDate];
 [customDateFormat setDateFormat:@"MMM dd"];
 endDateString=[customDateFormat stringFromDate:tempDate];
 }
 else{
 [customDateFormat setDateFormat:@"MMM dd"];
 endDateString=[customDateFormat stringFromDate:(NSDate*)eventDate];
 }
 
 NSString *startDateString=[customDateFormat stringFromDate:[NSDate date]]; //current date
 
 NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:[customDateFormat dateFromString:startDateString] toDate:[customDateFormat dateFromString:endDateString] options:0];
 
 //NSLog(@"%d",[components day]);
 [gregorianCalendar release];
 
 switch ([components day]) {
 case -1:
 return @"Yesterday";
 
 break;
 case 0:
 return @"Today";
 break;
 case 1:
 return @"Tomorrow";
 break;
 
 }
 if([components day]<-1){
 return @"Recent";
 }
 if([components day]>1){
 
 return endDateString;
 }
 return nil;
 }*/
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([tableView isEqual:eventsTable]){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
        }
        //Gift options screen
        GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
        
        if([eventTitleLbl.text isEqualToString:events_category_1]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
            
        }
        
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            if([[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            if([[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                [tempInfoDict setObject:[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                [tempInfoDict setObject:[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        else if([eventTitleLbl.text isEqualToString:events_category_5]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            if([[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                [tempInfoDict setObject:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                [tempInfoDict setObject:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        
        [self.navigationController pushViewController:giftOptions animated:YES];
        [giftOptions release];
    }
    
    
    
}

#pragma mark -
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    
    if([eventTitleLbl.text isEqualToString:events_category_1]){
        if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"picture"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
        
        if([[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"])
             [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]forKey:@"userID"];
        if([[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        
        [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        //NSLog(@" temp dict..%@",tempInfoDict);
        
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        //details.basicInfoForMsg=tempInfoDict;
        [tempInfoDict release];
        
    }
    
    else if([eventTitleLbl.text isEqualToString:events_category_2]){
        if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"picture"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        
        if([[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
             [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        
        if([[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];                   
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_3]){
        if([[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"picture"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        if([[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        
        if([[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        [tempInfoDict setObject:[[anniversaryEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_4]){
        if([[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"picture"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        if([[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        
        if([[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        [tempInfoDict setObject:[[newJobEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_5]){
        if([[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"picture"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        if([[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        
        if([[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        [tempInfoDict setObject:[[congratsEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        
    }
    
    [self.navigationController pushViewController:details animated:YES];
    [details release];
    
}
//Setting screen
- (IBAction)settingsAction:(id)sender {
    SettingsVC *settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
    
}

- (IBAction)pageControlActionForEventGroups:(id)sender {
    
    if(currentiOSVersion<6.0){
        for (int i = 0; i < [pageControlForEventGroups.subviews count]; i++)
        {
            UIImageView* dot = [pageControlForEventGroups.subviews objectAtIndex:i];
            if (i == pageControlForEventGroups.currentPage)
                dot.image = pageActiveImage;
            else
                dot.image = pageInactiveImage;
        }
    }
    
    if(pageControlForEventGroups.currentPage>eventGroupNum-1){
        eventGroupNum=pageControlForEventGroups.currentPage+1;
        [self swiping:1];
    }
    else{
        eventGroupNum=pageControlForEventGroups.currentPage+1;
        [self swiping:0];
    }
    
}

- (IBAction)showListOfOrders:(id)sender {
    OrderHistoryListVC *orders=[[OrderHistoryListVC alloc]initWithNibName:@"OrderHistoryListVC" bundle:nil];
    [self.navigationController pushViewController:orders animated:YES];
    [orders release];
    
}
#pragma mark - Facebook Events delegate
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [fb_giftgiv_home getAllFriendsWithTheirDetails];
    if([listOfBirthdays count]){
        
        if([listOfBirthdayEvents count])
            [listOfBirthdayEvents removeAllObjects];
        [listOfBirthdayEvents addObjectsFromArray:listOfBirthdays];
        
        int countOfBirthdays=[listOfBirthdayEvents count];
        
        for (int i=0;i<countOfBirthdays;i++){
            NSMutableDictionary *tempDict=[listOfBirthdayEvents objectAtIndex:i];
            NSArray *dateComponents=[[tempDict objectForKey:@"birthday_date"] componentsSeparatedByString:@"/"];
            if([dateComponents count]!=3){
                if(customDateFormat==nil){
                    customDateFormat = [[NSDateFormatter alloc] init];
                    
                }
                [customDateFormat setDateFormat:@"yyyy"];
                NSString *yearString = [customDateFormat stringFromDate:[NSDate date]];
                
                NSString *updatedDateString=[[tempDict objectForKey:@"birthday_date"] stringByAppendingFormat:@"/%@",yearString];
                [tempDict setObject:updatedDateString forKey:@"birthday_date"];
                [listOfBirthdayEvents replaceObjectAtIndex:i withObject:tempDict];
            }
            if(customDateFormat==nil){
                customDateFormat = [[NSDateFormatter alloc] init];
            }
            [customDateFormat setDateFormat:@"MM/dd/yyyy"];
            NSDate *stringToDate=[customDateFormat dateFromString:[tempDict objectForKey:@"birthday_date"]];
            [customDateFormat setDateFormat:@"yyyy-MM-dd"];
            [tempDict setObject:[customDateFormat stringFromDate:stringToDate] forKey:@"event_date"];
            [tempDict setObject:@"birthday" forKey:@"event_type"];
            [tempDict setObject:@"" forKey:@"ProfilePicture"];
            [listOfBirthdayEvents replaceObjectAtIndex:i withObject:tempDict];
        }
        [allupcomingEvents addObjectsFromArray:listOfBirthdayEvents];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        //[self performSelector:@selector(updateNextColumnTitle)];
        
        
        [eventsTable reloadData];
        ////[events_2_Table reloadData];
        birthdayEventUserNoToAddAsUser=1;
        shouldLoadingPicsStop=NO;
        
        [self storeAllupcomingsForSuccessScreen];
        [self loadProfilePictures];
        
        [self makeRequestToAddUserForBirthdays:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];
    }
    
    
}
/*-(void)updateNextColumnTitle{
    int nextGroupNum=eventGroupNum;
    
    if(eventGroupNum==[categoryTitles count]){
        nextGroupNum=1;
    }
    
    else
        nextGroupNum++;
   // NSLog(@"next group..%d",nextGroupNum);
   // eventTitle_2_Lbl.text=[categoryTitles objectAtIndex:nextGroupNum-1];
}*/
-(void)loadProfilePictures{
    int upcomingEventsCount=[allupcomingEvents count];
    int birthdayEventsCount=[listOfBirthdayEvents count];
    int anniversaryEventscount=[anniversaryEvents count];
    int newjobEventsCount=[newJobEvents count];
    int congratsEventsCount=[congratsEvents count];
    
    
    for(int i=0;i<upcomingEventsCount;i++){
        
        if(![[[allupcomingEvents objectAtIndex:i] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[allupcomingEvents objectAtIndex:i]objectForKey:@"uid"])
                    urlStr=FacebookPicURL([[allupcomingEvents objectAtIndex:i]objectForKey:@"uid"]);
                else
                    urlStr=FacebookPicURL([[[allupcomingEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[allupcomingEvents objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            if(!shouldLoadingPicsStop)
                                [[allupcomingEvents objectAtIndex:i] setObject:thumbnail forKey:@"ProfilePicture"];
                            shouldLoadingPicsStop=NO;
                            [self loadImageForEventAtIndexNum:i forTable:eventsTable];
                            //[self loadImageForEventAtIndexNum:i forTable:events_2_Table];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
    
    
    for(int i=0;i<birthdayEventsCount;i++){
        
        if(![[[listOfBirthdayEvents objectAtIndex:i] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[listOfBirthdayEvents objectAtIndex:i]objectForKey:@"uid"])
                    urlStr=FacebookPicURL([[listOfBirthdayEvents objectAtIndex:i]objectForKey:@"uid"]);
                else
                    urlStr=FacebookPicURL([[[listOfBirthdayEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[listOfBirthdayEvents objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            if(!shouldLoadingPicsStop)
                                [[listOfBirthdayEvents objectAtIndex:i] setObject:thumbnail forKey:@"ProfilePicture"];
                            shouldLoadingPicsStop=NO;
                            [self loadImageForEventAtIndexNum:i forTable:eventsTable];
                            //[self loadImageForEventAtIndexNum:i forTable:events_2_Table];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
    
    
    for(int i=0;i<anniversaryEventscount;i++){
        
        if(![[[anniversaryEvents objectAtIndex:i] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[anniversaryEvents objectAtIndex:i]objectForKey:@"uid"])
                    urlStr=FacebookPicURL([[anniversaryEvents objectAtIndex:i]objectForKey:@"uid"]);
                else
                    urlStr=FacebookPicURL([[[anniversaryEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[anniversaryEvents objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            if(!shouldLoadingPicsStop)
                                [[anniversaryEvents objectAtIndex:i] setObject:thumbnail forKey:@"ProfilePicture"];
                            shouldLoadingPicsStop=NO;
                            [self loadImageForEventAtIndexNum:i forTable:eventsTable];
                            //[self loadImageForEventAtIndexNum:i forTable:events_2_Table];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
    
    for(int i=0;i<newjobEventsCount;i++){
        
        if(![[[newJobEvents objectAtIndex:i] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[newJobEvents objectAtIndex:i]objectForKey:@"uid"])
                    urlStr=FacebookPicURL([[newJobEvents objectAtIndex:i]objectForKey:@"uid"]);
                else
                    urlStr=FacebookPicURL([[[newJobEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[newJobEvents objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            if(!shouldLoadingPicsStop)
                                [[newJobEvents objectAtIndex:i] setObject:thumbnail forKey:@"ProfilePicture"];
                            shouldLoadingPicsStop=NO;
                            [self loadImageForEventAtIndexNum:i forTable:eventsTable];
                            //[self loadImageForEventAtIndexNum:i forTable:events_2_Table];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
    
    for(int i=0;i<congratsEventsCount;i++){
        
        if(![[[congratsEvents objectAtIndex:i] objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]]){
            dispatch_queue_t ImageLoader_Q;
            ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
            dispatch_async(ImageLoader_Q, ^{
                NSString *urlStr;
                if([[congratsEvents objectAtIndex:i]objectForKey:@"uid"])
                    urlStr=FacebookPicURL([[congratsEvents objectAtIndex:i]objectForKey:@"uid"]);
                else
                    urlStr=FacebookPicURL([[[congratsEvents objectAtIndex:i]objectForKey:@"from"] objectForKey:@"id"]);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if(data==nil){
                    [[congratsEvents objectAtIndex:i] setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                }
                else {
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    
                    if(thumbnail!=nil){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            if(!shouldLoadingPicsStop)
                                [[congratsEvents objectAtIndex:i] setObject:thumbnail forKey:@"ProfilePicture"];
                            shouldLoadingPicsStop=NO;
                            [self loadImageForEventAtIndexNum:i forTable:eventsTable];
                            //[self loadImageForEventAtIndexNum:i forTable:events_2_Table];
                            
                        });
                    }
                    
                }
                
                
            });
            dispatch_release(ImageLoader_Q);
            
        }
    }
    
}

-(void) loadImageForEventAtIndexNum:(int)index forTable:(UITableView*)table{
    /*[table beginUpdates];
    
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    
    [table endUpdates];*/
    [table reloadData];
}

-(void)makeRequestToAddUserForBirthdays:(NSMutableDictionary*)userDetails{
    
    if([CheckNetwork connectedToNetwork]){
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddNormalUser>\n<tem:fbId>%@</tem:fbId>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>https://graph.facebook.com/%@/picture</tem:profilePictureUrl>\n<tem:dob>%@</tem:dob>\n<tem:email></tem:email></tem:AddNormalUser>",[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"first_name"],[userDetails objectForKey:@"last_name"],[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"event_date"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddNormalUser"];
        
        AddUserRequest *addUser=[[AddUserRequest alloc]init];
        [addUser setAddUserDelegate:self];
        [addUser addUserServiceRequest:theRequest];
        [addUser release];
    }
    else{
        AlertWithMessageAndDelegate(@"GiftGiv", @"Check your network settings", nil);
    }
    
}
- (void)facebookDidRequestFailed{
    //AlertWithMessageAndDelegate(@"Oops", @"facebook request failed", nil);
}
#pragma mark - Events from statuses
- (void)birthdayEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    for (NSDictionary *existEvents in listOfBirthdayEvents){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventDetails objectForKey:@"from"]objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return ;
    }
    
    
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    
    [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSDate *convertedDateFromString;
    if([eventDetails objectForKey:@"picture"]){
        convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"created_time"]];
    }
    else{
        convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
    }
    
    [customDateFormat setDateFormat:@"yyyy-MM-dd"];
    
    [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
    [eventDetails setObject:@"birthday" forKey:@"event_type"];
    [eventDetails setObject:@"" forKey:@"ProfilePicture"];
    [listOfBirthdayEvents addObject:eventDetails];
    [allupcomingEvents addObject:eventDetails];
    [self performSelector:@selector(checkTotalNumberOfGroups)];
    
    //[self performSelector:@selector(updateNextColumnTitle)];
    
    if([allupcomingEvents count]>1)
        [self sortEvents:allupcomingEvents eventCategory:1];
    if([listOfBirthdayEvents count]>1)
        [self sortEvents:listOfBirthdayEvents eventCategory:2];
    
    
    shouldLoadingPicsStop=YES;
    [self loadProfilePictures];
    [eventsTable reloadData];
    ////[events_2_Table reloadData];
    
    
}
-(void)storeAllupcomingsForSuccessScreen{
    NSMutableArray *tempArray=[[NSMutableArray alloc]initWithArray:allupcomingEvents];
    for(NSMutableDictionary *eventDict in tempArray ){
        [eventDict setObject:@"" forKey:@"ProfilePicture"];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AllUpcomingEvents"];
    }
    [[NSUserDefaults standardUserDefaults]setObject:tempArray forKey:@"AllUpcomingEvents"];
    
    [tempArray release];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[allupcomingEvents count]];
}
- (void)newJobEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"picture"]){
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"created_time"]];
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        [eventDetails setObject:@"new job" forKey:@"event_type"];
        [eventDetails setObject:@"" forKey:@"ProfilePicture"];
        [newJobEvents addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
       // [self performSelector:@selector(updateNextColumnTitle)];
        if([allupcomingEvents count])
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([newJobEvents count])
            [self sortEvents:newJobEvents eventCategory:4];
        shouldLoadingPicsStop=YES;
        
        [self storeAllupcomingsForSuccessScreen];
        
        [self loadProfilePictures];
        [eventsTable reloadData];
        ////[events_2_Table reloadData];
        
    }
    
}
- (void)anniversaryEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"picture"]){
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"created_time"]];
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        [eventDetails setObject:@"relationships" forKey:@"event_type"];
        [eventDetails setObject:@"" forKey:@"ProfilePicture"];
        [anniversaryEvents addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        //[self performSelector:@selector(updateNextColumnTitle)];
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([anniversaryEvents count]>1)
            [self sortEvents:anniversaryEvents eventCategory:3];
        shouldLoadingPicsStop=YES;
        
        [self storeAllupcomingsForSuccessScreen];
        
        [self loadProfilePictures];
        
        [eventsTable reloadData];
        ////[events_2_Table reloadData];
        
    }
}
- (void)congratsEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"picture"]){
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"created_time"]];
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        [eventDetails setObject:@"congratulations" forKey:@"event_type"];
        [eventDetails setObject:@"" forKey:@"ProfilePicture"];
        [congratsEvents addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        //[self performSelector:@selector(updateNextColumnTitle)];
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([congratsEvents count]>1)
            [self sortEvents:congratsEvents eventCategory:5];
        
        shouldLoadingPicsStop=YES;
        
        [self storeAllupcomingsForSuccessScreen];
        
        [self loadProfilePictures];
        [eventsTable reloadData];
        ////[events_2_Table reloadData];
        
    }
}
#pragma  mark - Sorting
- (void)sortEvents:(NSMutableArray*)listOfEvents eventCategory:(int)catNum{
	
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
	int eventsCount=[listOfEvents count];
	for (int i=0; i<eventsCount;i++) {
        
        if([[[listOfEvents objectAtIndex:i] objectForKey:@"event_date"] isKindOfClass:[NSString class]]){
            [customDateFormat setDateFormat:@"yyyy-MM-dd"];
            NSDate *date1 =[customDateFormat dateFromString:[[listOfEvents objectAtIndex:i]objectForKey:@"event_date"]];
            [customDateFormat setDateFormat:@"MMM dd"];
            
            [[listOfEvents objectAtIndex:i] setObject:[customDateFormat dateFromString:[customDateFormat stringFromDate:date1]] forKey:@"event_date"];
        }
		
	}
   	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"event_date" ascending:YES];
    
    switch (catNum) {
            //all upcoming
        case 1:
            
            [allupcomingEvents replaceObjectsInRange:NSMakeRange(0, [allupcomingEvents count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            
            
            
            break;
            //birthdays
        case 2:
            
            [listOfBirthdayEvents replaceObjectsInRange:NSMakeRange(0, [listOfBirthdayEvents count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            break;
            //anniversaries
        case 3:
            
            [anniversaryEvents replaceObjectsInRange:NSMakeRange(0, [anniversaryEvents count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            
            break;
            //new job
        case 4:
            [newJobEvents replaceObjectsInRange:NSMakeRange(0, [newJobEvents count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            break;
            //congratulations
        case 5:
            [congratsEvents replaceObjectsInRange:NSMakeRange(0, [congratsEvents count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            break;
            
    }
    
    
    [sortDescriptor release];
    
    [eventsTable reloadData];
    ////[events_2_Table reloadData];
	
}
#pragma mark - Check Event existance
-(BOOL)checkWhetherEventExistInTheListOfEvents:(NSMutableDictionary*)eventsData{
    
    for (NSDictionary *existEvents in newJobEvents){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventsData objectForKey:@"from"]objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return YES;
    }
    
    for (NSDictionary *existEvents in anniversaryEvents){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventsData objectForKey:@"from"]objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return YES;
    }
    for (NSDictionary *existEvents in congratsEvents){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventsData objectForKey:@"from"]objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return YES;
    }
    return NO;
}

#pragma mark - Add User Request delegate
-(void) responseForAddUser:(NSMutableDictionary*)response{
    if([response objectForKey:@"NormalUser"]){
        
        //response will return userID.
        if(birthdayEventUserNoToAddAsUser<[listOfBirthdayEvents count]){
            birthdayEventUserNoToAddAsUser++;
            [self makeRequestToAddUserForBirthdays:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];   
        }
    }
    
    
    
    
}
-(void) requestFailed{
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed", nil);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
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
    [self setEventsBgView:nil];
    [self setEventTitleLbl:nil];
    [self setPageControlForEventGroups:nil];
    [self setEventsTable:nil];
    //[self setEventTitle_2_Lbl:nil];
    //[self setEvents_2_Table:nil];
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
    
    [fb_giftgiv_home setFbGiftGivDelegate:nil];
    //[fb_giftgiv_home release];
    if(currentiOSVersion<6.0){
        [pageActiveImage release];
        [pageInactiveImage release]; 
    }
    
    [listOfBirthdayEvents release];
    [newJobEvents release];
    [anniversaryEvents release];
    [congratsEvents release];
    [allupcomingEvents release];
    
    [categoryTitles release];
    [eventsBgView release];
    [eventTitleLbl release];
    [pageControlForEventGroups release];
    [eventsTable release];
    //[eventTitle_2_Lbl release];
   // [events_2_Table release];
    [super dealloc];
}

@end
