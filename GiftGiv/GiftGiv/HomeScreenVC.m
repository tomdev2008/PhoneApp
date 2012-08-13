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
    if([CheckNetwork connectedToNetwork]){
        [[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
        [[Facebook_GiftGiv sharedSingleton] listOfBirthdayEvents];
        //[[Facebook_GiftGiv sharedSingleton] getAllFriendsWithTheirDetails];
    }
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
    
    profilePicImagesArray=[[NSMutableArray alloc] init];
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [eventsBgView addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [eventsBgView addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    eventGroupNum=1;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    [super viewDidLoad];
    
}

-(void)swipingForEventGroups:(UISwipeGestureRecognizer*)swipeRecognizer{
    
    // The events list should be in carousel effect
    
    //previous
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if(eventGroupNum>1)
		{						
			eventGroupNum--;
			
			[self swiping:0];
            
		}
		else if(eventGroupNum==1)
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
    
    if([eventTitleLbl.text isEqualToString:events_category_1]){
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_2]){
        //if([listOfBirthdayEvents count])
        //   [eventsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else if([eventTitleLbl.text isEqualToString:events_category_3]){
    }
    else if([eventTitleLbl.text isEqualToString:events_category_4]){
    }
    else if([eventTitleLbl.text isEqualToString:events_category_5]){
    }
    
    [eventsTable reloadData];
    
    if(!isProfilePicsLoadingInProgress){
        if([profilePicImagesArray count])
            [profilePicImagesArray removeAllObjects];
        [self performSelectorInBackground:@selector(photoRetrieve) withObject:nil];
        isProfilePicsLoadingInProgress=YES;
        [self performSelector:@selector(reloadEventsTable) withObject:nil afterDelay:0.2];
    }
}
-(void)checkTotalNumberOfGroups{
    totalGroups=0;
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
	animation1.timingFunction = UIViewAnimationCurveEaseInOut;
	animation1.type = kCATransitionPush ;
	
	animation1.subtype = animationType;
	
	return animation1;
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    
    return 0;
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
        
        /*switch (pageControlForEventGroups.currentPage) {
         //all upcoming
         case 0:
         if(indexPath.row%2==0){
         cell.eventNameLbl.text=@"New job";
         cell.dateLbl.text=@"Yesterday";
         cell.bubbleIconForCommentsBtn.hidden=NO;
         }
         else{
         cell.eventNameLbl.text=@"Birthday";
         cell.dateLbl.text=@"Today";
         cell.bubbleIconForCommentsBtn.hidden=YES;
         }
         
         break;
         //birthdays
         case 1:
         cell.eventNameLbl.text=@"Birthday";
         cell.dateLbl.text=@"Today";
         cell.bubbleIconForCommentsBtn.hidden=YES;
         break;
         //anniversaries
         case 2:
         cell.eventNameLbl.text=@"Happy anniversary";
         cell.dateLbl.text=@"Yesterday";
         cell.bubbleIconForCommentsBtn.hidden=YES;
         break;
         //New job
         case 3:
         cell.eventNameLbl.text=@"New job";
         cell.dateLbl.text=@"Yesterday";
         cell.bubbleIconForCommentsBtn.hidden=NO;
         break;
         //Congratulations
         case 4:
         cell.eventNameLbl.text=@"Congratulations";
         cell.dateLbl.text=@"Yesterday";
         cell.bubbleIconForCommentsBtn.hidden=YES;
         break;
         
         }*/
        
	}
    if([eventTitleLbl.text isEqualToString:events_category_1]){
        if([allupcomingEvents count]){
            cell.profileNameLbl.text=[[allupcomingEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.eventNameLbl.text=@"Birthday";
            if([profilePicImagesArray count]){
                if(!isProfilePicsLoadingInProgress)
                    cell.profileImg.image=[profilePicImagesArray objectAtIndex:indexPath.row];
            }
            
            NSString *birthdayDt=[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"birthday_date"];
            
            cell.dateLbl.text=[self updatedDateToBeDisplayedForTheEvent:birthdayDt];
            cell.bubbleIconForCommentsBtn.hidden=YES;
        }
    }
    else if([eventTitleLbl.text isEqualToString:events_category_2]){
        
        if([listOfBirthdayEvents count]){
            cell.profileNameLbl.text=[[listOfBirthdayEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.eventNameLbl.text=@"Birthday";
            if([profilePicImagesArray count]){
                if(!isProfilePicsLoadingInProgress)
                    cell.profileImg.image=[profilePicImagesArray objectAtIndex:indexPath.row];
            }
            
            NSString *birthdayDt=[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"birthday_date"];
            
            cell.dateLbl.text=[self updatedDateToBeDisplayedForTheEvent:birthdayDt];
            cell.bubbleIconForCommentsBtn.hidden=YES;
        }
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_3]){
        
        if([anniversaryEvents count]){
            cell.profileNameLbl.text=[[anniversaryEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.eventNameLbl.text=@"Birthday";
            if([profilePicImagesArray count]){
                if(!isProfilePicsLoadingInProgress)
                    cell.profileImg.image=[profilePicImagesArray objectAtIndex:indexPath.row];
            }
            
            NSString *birthdayDt=[[anniversaryEvents objectAtIndex:indexPath.row] objectForKey:@"birthday_date"];
            
            cell.dateLbl.text=[self updatedDateToBeDisplayedForTheEvent:birthdayDt];
            cell.bubbleIconForCommentsBtn.hidden=NO;
        }
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_4]){
        
        if([newJobEvents count]){
            cell.profileNameLbl.text=[[newJobEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.eventNameLbl.text=@"Birthday";
            if([profilePicImagesArray count]){
                if(!isProfilePicsLoadingInProgress)
                    cell.profileImg.image=[profilePicImagesArray objectAtIndex:indexPath.row];
            }
            
            NSString *birthdayDt=[[newJobEvents objectAtIndex:indexPath.row] objectForKey:@"birthday_date"];
            
            cell.dateLbl.text=[self updatedDateToBeDisplayedForTheEvent:birthdayDt];
            cell.bubbleIconForCommentsBtn.hidden=NO;
        }
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_5]){
        
        if([congratsEvents count]){
            cell.profileNameLbl.text=[[congratsEvents objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.eventNameLbl.text=@"Birthday";
            if([profilePicImagesArray count]){
                if(!isProfilePicsLoadingInProgress)
                    cell.profileImg.image=[profilePicImagesArray objectAtIndex:indexPath.row];
            }
            
            NSString *birthdayDt=[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"birthday_date"];
            
            cell.dateLbl.text=[self updatedDateToBeDisplayedForTheEvent:birthdayDt];
            cell.bubbleIconForCommentsBtn.hidden=NO;
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
-(NSString*)updatedDateToBeDisplayedForTheEvent:(NSString*)eventDate{
    
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    [customDateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [customDateFormat dateFromString:eventDate];
    [customDateFormat setDateFormat:@"MMM dd"];
    NSString *endDateString=[customDateFormat stringFromDate:tempDate];
    NSString *startDateString=[customDateFormat stringFromDate:[NSDate date]];
    
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
}
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Gift options screen
    GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
    
}

-(void)photoRetrieve{
	
    if([CheckNetwork connectedToNetwork]){
        
        int totalBirthdaysCount=[listOfBirthdayEvents count];
        //NSLog(@"%d",totalBirthdaysCount);
        for(int i =0; i<totalBirthdaysCount;i++){
            
            UIImage	*tempPicImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:FacebookPicURL([[listOfBirthdayEvents objectAtIndex:i]objectForKey:@"uid"])]]];
            //NSLog(@"%@",FacebookPicURL([[listOfBirthdayEvents objectAtIndex:i]objectForKey:@"uid"]));
            if(tempPicImage){
                [profilePicImagesArray addObject:tempPicImage];
                
            }
            else{
                /*UIImage *image2 = [UIImage imageNamed:@"nophoto.png"];
                 [imgArray replaceObjectAtIndex:i withObject:image2];*/
            }
            
            
        }
        
        isProfilePicsLoadingInProgress=NO;
    }
    
    
}
-(void)reloadEventsTable{
	if(!isProfilePicsLoadingInProgress)
        [eventsTable reloadData];
	else if(isProfilePicsLoadingInProgress)
	{
		[self performSelector:@selector(reloadEventsTable) withObject:nil afterDelay:0.2];
	}
}
#pragma mark -
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    if([sender tag]==0)
        details.isPhotoTagged=YES;
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
#pragma mark - Facebook Events delegate
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays{
    [[Facebook_GiftGiv sharedSingleton] getAllFriendsWithTheirDetails];
    if([listOfBirthdays count]){
        NSLog(@"%@",listOfBirthdays);
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
            [tempDict setObject:[customDateFormat stringFromDate:stringToDate] forKey:@"birthday_date"];
            [listOfBirthdayEvents replaceObjectAtIndex:i withObject:tempDict];
        }
        [allupcomingEvents addObjectsFromArray:listOfBirthdayEvents];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        [eventsTable reloadData];
        
        if(!isProfilePicsLoadingInProgress){
            if([profilePicImagesArray count])
                [profilePicImagesArray removeAllObjects];
            [self performSelectorInBackground:@selector(photoRetrieve) withObject:nil];
            isProfilePicsLoadingInProgress=YES;
            [self performSelector:@selector(reloadEventsTable) withObject:nil afterDelay:0.2];
        }
        
        birthdayEventUserNoToAddAsUser=1;
        [self makeRequestToAddUserForBirthdays:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];
    }
    
    
}
-(void)makeRequestToAddUserForBirthdays:(NSMutableDictionary*)userDetails{
    
    if([CheckNetwork connectedToNetwork]){
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>%@</tem:fbId>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>https://graph.facebook.com/%@/picture</tem:profilePictureUrl>\n<tem:dob>%@</tem:dob>\n<tem:email></tem:email></tem:AddUser>",[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"first_name"],[userDetails objectForKey:@"last_name"],[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"birthday_date"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddUser"];
        
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
#pragma mark -
#pragma mark - Add User Request delegate
-(void) responseForAddUser:(NSMutableString*)response{
    if([response isEqualToString:@"true"]){
        NSLog(@"User added into DB");
    }
    else if([response isEqualToString:@"false"]){
        NSLog(@"User already exists");
    }
    if(birthdayEventUserNoToAddAsUser<[listOfBirthdayEvents count]){
        birthdayEventUserNoToAddAsUser++;
        [self makeRequestToAddUserForBirthdays:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];   
    }
    
    
    
}
-(void) requestFailed{
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed", nil);
}
#pragma mark -
- (void)viewDidUnload
{
    [self setEventsBgView:nil];
    [self setEventTitleLbl:nil];
    [self setPageControlForEventGroups:nil];
    [self setEventsTable:nil];
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
    
    [listOfBirthdayEvents release];
    [newJobEvents release];
    [anniversaryEvents release];
    [congratsEvents release];
    [allupcomingEvents release];
    
    [categoryTitles release];
    [profilePicImagesArray release];
    [eventsBgView release];
    [eventTitleLbl release];
    [pageControlForEventGroups release];
    [eventsTable release];
    [super dealloc];
}

@end
