//
//  HomeScreenVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "HomeScreenVC.h"

@implementation HomeScreenVC

@synthesize contactsSearchBar;
@synthesize contactsSearchView;
@synthesize eventsBgView;
@synthesize pageControlForEventGroups;
@synthesize eventsTable;
@synthesize eventTitleLbl;


static NSDateFormatter *customDateFormat=nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Notification when user registered in gift giv server such that we can make request for contacts
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedGiftGivUserId) name:@"GiftGivUserIDReceived" object:nil];
        
        //Notification when user is successfully loggin in linkedIn, then will get the profile and network updates respective to that user
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventsFromLinkedIn) name:@"LinkedInLoggedIn" object:nil];
        
        //Notification when user logged out of all accounts, such that will cancel all pending requests for events or profile pictures downloading...
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutFromAllAccounts) name:@"UserLoggedOut" object:nil];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    
    //When device received low memory warning, clean the storage events to avoid the crash
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    fm=[NSFileManager defaultManager];
    fb_giftgiv_home=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_home.fbGiftGivDelegate=self;
    
    //Dispatch queue for profile pictures loading..
    ImageLoader_Q=dispatch_queue_create("profile picture network connection queue", NULL);
    ImageLoader_Q_ForEvents=dispatch_queue_create("event profilePictures",NULL);
    
    lnkd_giftgiv_home=[[LinkedIn_GiftGiv alloc]init];
    lnkd_giftgiv_home.lnkInGiftGivDelegate=self;
    
    categoryTitles=[[NSMutableArray alloc]init];
    listOfBirthdayEvents=[[NSMutableArray alloc]init];
    
    eventsToCelebrateArray=[[NSMutableArray alloc]init];
    listOfContactsArray=[[NSMutableArray alloc]init];
    //linkedInContactsArray=[[NSMutableArray alloc]init];
    
    allupcomingEvents=[[NSMutableArray alloc]init];
    
    eventTitleLbl.text=events_category_1;
    
    
    searchContactsArray=[[NSMutableArray alloc]init];
    
    pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive" ofType:@"png"] retain];
    pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive" ofType:@"png"] retain];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:picturesOperationQueue selector:@selector(cancelAllOperations) name:UIApplicationWillTerminateNotification object:nil];
    
    [self performSelector:@selector(loadGestures)withObject:nil afterDelay:0.1];
    
    //To update the page dot and group which currently viewing.
    eventGroupNum=1;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    //Create an operation for profile picture downloads
    picturesOperationQueue=[[NSOperationQueue alloc]init];
    
    [super viewDidLoad];
    
}
-(void)loadGestures{
    //Swipe gestures to get other group of events
    UISwipeGestureRecognizer *swipeLeftRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeLeftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    [eventsBgView addGestureRecognizer:swipeLeftRecognizer];
    
    [swipeLeftRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipingForEventGroups:)];
    swipeRightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    [eventsBgView addGestureRecognizer:swipeRightRecognizer];
    
    [swipeRightRecognizer release];
}
-(void)getEventsFromLinkedIn{
    if([lnkd_giftgiv_home isLinkedInAuthorized]){
        [lnkd_giftgiv_home fetchProfile];
        [lnkd_giftgiv_home getMyNetworkUpdatesWithType:@"PRFU"];
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
    //If there are no events stored in the application level, get the events
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"] ){
        
        //Cancel if there are any pending requests
        /*for(FBRequest *request in fb_giftgiv_home.fbRequestsArray){
            [request  cancelConnection];
        }*/
        [fb_giftgiv_home.fbRequestsArray removeAllObjects];
        
       
        if([searchContactsArray count])
            [searchContactsArray removeAllObjects];
        
        if([allupcomingEvents count])
            [allupcomingEvents removeAllObjects];
        if([listOfBirthdayEvents count])
            [listOfBirthdayEvents removeAllObjects];
        if([eventsToCelebrateArray count])
            [eventsToCelebrateArray removeAllObjects];
        if([listOfContactsArray count])
            [listOfContactsArray removeAllObjects];
        
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        [eventsTable reloadData];
        if([FBSession activeSession].isOpen||[FBSession activeSession].state == FBSessionStateCreatedTokenLoaded){
            //If the UserId (referred in giftgiv server) is available, then get the events and contacts from our server.
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]){
                isEventsLoadingFromFB=NO;
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"IsLoadingFromFacebook"];
                
                //Get the events from giftgiv server
                [self performSelector:@selector(makeRequestToGetEvents)];
                isFBContactsLoading=YES;
                //Get the list of contacts for the loggedIn user
                [self performSelector:@selector(makeRequestToGetFacebookContacts)];
                
                //If user is logged in for linkedin, get the list of contacts for linkedIn
                if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
                    [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
                }
                
            }
            
            else{
                if([CheckNetwork connectedToNetwork]){
                    isEventsLoadingFromFB=YES;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"IsLoadingFromFacebook"];
                    
                    //Make request to facebook to get the events, to get the events, will get the list of friends first.
                    [fb_giftgiv_home getAllFriendsWithTheirDetails];
                    
                    //get the list of birthdays
                    [fb_giftgiv_home listOfBirthdayEvents];
                    
                    //If the userId is available, will get the list of contacts, otherwise when the userId received, will make a request to get the contacts.
                    if([[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]){
                        isFBContactsLoading=YES;
                        [self performSelector:@selector(makeRequestToGetFacebookContacts) ];
                        if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
                            [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
                        }
                        
                    }
                    
                }
            }
        }
        //If the user is loggedIn with linkedIn, will make a request to linkedIn to get the updates as our server side implementations is in progress to get those events.
        if([lnkd_giftgiv_home isLinkedInAuthorized]){
            [lnkd_giftgiv_home getMyNetworkUpdatesWithType:@"PRFU"];
        }
        
        
    }
    
    [eventsTable reloadData];
    [super viewWillAppear:YES];
}
-(void)receivedGiftGivUserId{
    
    if(!isFBContactsLoading){
        isFBContactsLoading=YES;
        [self performSelector:@selector(makeRequestToGetFacebookContacts) ];
        
    }
    if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
        [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
    }
}
#pragma mark -
-(void)makeRequestToGetFacebookContacts{
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        //GGLog(@"gift home id..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetFacebookList>\n<tem:userId>%@</tem:userId>\n<tem:facebookAccessToken>%@</tem:facebookAccessToken>\n</tem:GetFacebookList>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //GGLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetFacebookList"];
        
        FacebookContactsReq *fbContacts=[[FacebookContactsReq alloc]init];
        [fbContacts setFbContactsDelegate:self];
        [fbContacts getFBContactsForRequest:theRequest];
        [fbContacts release];
    }
    else{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        AlertWithMessageAndDelegate(@"Network connectivity", @"Please check your network connection", nil);
    }
}
#pragma mark Contacts Delegate
-(void) receivedContacts:(NSMutableArray*)response{
    int friendsCount=[response count];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    //GGLog(@"Received contacts..%d",friendsCount);
    if(friendsCount){
        
        
        for (int i=0;i<friendsCount;i++){
            NSMutableDictionary *contactDict=[[NSMutableDictionary alloc]init];
            [contactDict setObject:[[response objectAtIndex:i]userId] forKey:@"uid"];
            
            [contactDict setObject:[NSString stringWithFormat:@"%@ %@",[[response objectAtIndex:i]firstname],[[response objectAtIndex:i]lastname]] forKey:@"name"];
            
            [contactDict setObject:@"" forKey:@"event_type"];
            
            if([[response objectAtIndex:i]location]==nil)
                [contactDict setObject:@"" forKey:@"FBUserLocation"];
            else
                [contactDict setObject:[[response objectAtIndex:i]location] forKey:@"FBUserLocation"];
            
            if([[response objectAtIndex:i]profilepicUrl]!=nil)
                [contactDict setObject:[[response objectAtIndex:i]profilepicUrl] forKey:@"ProfilePicURLToTake"];
            else
                [contactDict setObject:@"" forKey:@"ProfilePicURLToTake"];
            [listOfContactsArray addObject:contactDict];
            [contactDict release];
            
        }
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        //should sort respected to the friend name
        if([listOfContactsArray count]>1)
            [self sortEvents:listOfContactsArray eventCategory:4];
        
        
        if([globalContactsList count]){
            [globalContactsList removeAllObjects];
            [globalContactsList release];
            globalContactsList=nil;
        }
        globalContactsList=[[NSMutableArray alloc] initWithArray:listOfContactsArray];
        
        int contactsCount=[globalContactsList count];
        
        for(int i=0;i<contactsCount;i++){
            
            NSString *urlStr_id=@"";
            if([[globalContactsList objectAtIndex:i]objectForKey:@"uid"])
                urlStr_id=[[globalContactsList objectAtIndex:i]objectForKey:@"uid"];
            
            // Check if the image is already there in the storage space, if it is not there, then add a request to the queue to donwload the picture
            if (![fm fileExistsAtPath: [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",urlStr_id]]]){
                
                
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithCapacity:2];
                [tempDict setObject:urlStr_id forKey:@"profile_id"];
                
                if([[globalContactsList objectAtIndex:i]objectForKey:@"uid"])
                {
                    
                    [tempDict setObject:[[globalContactsList objectAtIndex:i]objectForKey:@"ProfilePicURLToTake"] forKey:@"profile_url"];
                    
                }
                
                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadProfileImgWithOperation:) object:tempDict];
                
                [tempDict release];
                
                [picturesOperationQueue addOperation:operation];
                
                [operation release];
                
                
            }
            
        }
        
    }
}

#pragma mark - Get Events
-(void)makeRequestToGetEvents{
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        //GGLog(@"gift home id..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetEvents>\n<tem:userId>%@</tem:userId>\n<tem:typeEventList>Display</tem:typeEventList>\n</tem:GetEvents>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //GGLog(@"events request..%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetEvents"];
        
        GetEventsRequest *getEvents=[[GetEventsRequest alloc]init];
        [getEvents setEventsDelegate:self];
        [getEvents getListOfEvents:theRequest];
        [getEvents release];
    }
    else{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        AlertWithMessageAndDelegate(@"Network connectivity", @"Please check your network connection", nil);
    }
}
#pragma -EventsRequest delegate
-(void) receivedAllEvents:(NSMutableArray*)allEvents{
    
    int eventsCount=[allEvents count];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:eventsCount];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    //Check whether it received the events or not, If it not received from gift giv server, will make request to get from facebook/linkedIn. Right now there are no events receiving from gift giv server, so we already made a request to linkedIn to get the events if the user logged In.
    if(eventsCount){
        
        for (int i=0;i<eventsCount;i++){
            NSMutableDictionary *eventDict=[[NSMutableDictionary alloc]init];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_FriendId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"uid"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_EventId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"id"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_Name]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
            
            [eventDict setObject:[[[allEvents objectAtIndex:i]eventName]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_type"];
            [eventDict setObject:[[[[[allEvents objectAtIndex:i]eventdate]componentsSeparatedByString:@"T"]objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_date"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]isEventFromQuery]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"isEventFromQuery"];
            
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_Picture]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"pic_square"];
            
            NSString *eventType=[[[allEvents objectAtIndex:i]eventType]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //Add events to the respective category/group
            
            if([eventType isEqualToString:@"Birthday"]){
                [listOfBirthdayEvents addObject:eventDict];
            }
            
            else if([eventType isEqualToString:@"New Job"]){
                [eventsToCelebrateArray addObject:eventDict];
                
                
            }
            
            else if([eventType isEqualToString:@"Congratulations"]){
                
                [eventsToCelebrateArray addObject:eventDict];
            }
            
            else if([eventType isEqualToString:@"Relationships"] || [eventType isEqualToString:@"relationships"]){
                
                [eventsToCelebrateArray addObject:eventDict];
            }
            
            
            [allupcomingEvents addObject:eventDict];
            
            [eventDict release];
            
        }
        
        //GGLog(@"%@",allupcomingEvents);
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        //sort the events respective the dates (most recent to next recent....)
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([listOfBirthdayEvents count]>1)
            [self sortEvents:listOfBirthdayEvents eventCategory:2];
        
        if([eventsToCelebrateArray count]>1)
            [self sortEvents:eventsToCelebrateArray eventCategory:3];
        
        [[NSUserDefaults standardUserDefaults]setObject:allupcomingEvents forKey:@"AllUpcomingEvents"];
        [self makeRequestToLoadImagesUsingOperations:allupcomingEvents];
        
        [eventsTable reloadData];
        
    }
    else{
        if([CheckNetwork connectedToNetwork]){
            isEventsLoadingFromFB=YES;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"IsLoadingFromFacebook"];
            
            [fb_giftgiv_home getAllFriendsWithTheirDetails];
            [fb_giftgiv_home listOfBirthdayEvents];
            
        }
    }
}
#pragma mark - Download Profile pictures
//download the profile pictures for events with dispatch queue
- (void) loadProfileImgWithOperationForEvents:(NSMutableDictionary*)picDetails {
    
    if(isCancelledImgOperations)
        return;
    dispatch_async(ImageLoader_Q_ForEvents, ^{
        
        if(isCancelledImgOperations)
            return;
        NSString *urlStr=[picDetails objectForKey:@"profile_url"];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            
            
        }
        else {
            
            if(isCancelledImgOperations)
                return;
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[picDetails objectForKey:@"profile_id"]]]; //Add the file name
            [UIImagePNGRepresentation(thumbnail) writeToFile:filePath atomically:YES]; //Write the file
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                NSArray *tableCells=[eventsTable visibleCells];
                //Reload only a particular cell which we received the image/profile picture
                for(int i=0; i<[tableCells count];i++ ){
                    if([[(EventCustomCell*)[tableCells objectAtIndex:i] profileId] isEqualToString:[NSString stringWithFormat:@"%@",[picDetails objectForKey:@"profile_id"]]]){
                        NSIndexPath *indexPath=[eventsTable indexPathForCell:(EventCustomCell*)[tableCells objectAtIndex:i]];
                        [eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                
            });
        }
        
    });
    
}
//download the profilepictures for contacts
- (void) loadProfileImgWithOperation:(NSMutableDictionary*)picDetails {
    
    if(isCancelledImgOperations)
        return;
    dispatch_async(ImageLoader_Q, ^{
        
        if(isCancelledImgOperations)
            return;
        NSString *urlStr=[picDetails objectForKey:@"profile_url"];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *thumbnail = [UIImage imageWithData:data];
        
        if(thumbnail==nil){
            
            
        }
        else {
            
            if(isCancelledImgOperations)
                return;
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[picDetails objectForKey:@"profile_id"]]]; //Add the file name
            [UIImagePNGRepresentation(thumbnail) writeToFile:filePath atomically:YES]; //Write the file
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                NSArray *tableCells=[eventsTable visibleCells];
                for(int i=0; i<[tableCells count];i++ ){
                    if([[(EventCustomCell*)[tableCells objectAtIndex:i] profileId] isEqualToString:[NSString stringWithFormat:@"%@",[picDetails objectForKey:@"profile_id"]]]){
                        NSIndexPath *indexPath=[eventsTable indexPathForCell:(EventCustomCell*)[tableCells objectAtIndex:i]];
                        [eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                
            });
        }
        
    });
    
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
    
    if([categoryTitles count]>=eventGroupNum)
        eventTitleLbl.text=[categoryTitles objectAtIndex:eventGroupNum-1];
    
    
    if([eventTitleLbl.text isEqualToString:events_category_4]){
        eventTitleLbl.text=@"";
        contactsSearchView.frame=CGRectMake(0, 0, 320, 44);
        if(![contactsSearchView superview]){
            
            [self.view addSubview:contactsSearchView];
        }
        [contactsSearchBar becomeFirstResponder];
    }
    else{
        if([contactsSearchView superview]){
            contactsSearchBar.text=@"";
            [contactsSearchBar resignFirstResponder];
            [contactsSearchView removeFromSuperview];
        }
        if([searchContactsArray count]){
            
            [searchContactsArray removeAllObjects];
        }
        if([categoryTitles count]>=eventGroupNum)
            eventTitleLbl.text=[categoryTitles objectAtIndex:eventGroupNum-1];
    }
    [eventsTable reloadData];
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
    
    if([eventsToCelebrateArray count]){
        [categoryTitles addObject:events_category_3];
        totalGroups++;
    }
    if([listOfContactsArray count]){
        [categoryTitles addObject:events_category_4];
        totalGroups++;
    }
    
    
    
    
    pageControlForEventGroups.numberOfPages=totalGroups;
    if(totalGroups==1)
        eventGroupNum=1;
    for(int i=0;i<totalGroups;i++){
        if([[categoryTitles objectAtIndex:i] isEqualToString:eventTitleLbl.text]){
            eventGroupNum=i+1;
            break;
        }
    }
    
    
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
            
            return [eventsToCelebrateArray count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_4] ||[eventTitleLbl.text isEqualToString:@""]){
            
            return [searchContactsArray count];
            
            
        }
        
    }
    
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([tableView isEqual:eventsTable]){
        static NSString *cellIdentifier;
        cellIdentifier=[NSString stringWithFormat:@"Cell%d%d",eventGroupNum,indexPath.row];
        
        EventCustomCell *cell = (EventCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell=[[[NSBundle mainBundle]loadNibNamed:@"EventCustomCell" owner:self options:nil] lastObject];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.bubbleIconForCommentsBtn.tag=indexPath.row;
            [cell.bubbleIconForCommentsBtn addTarget:self action:@selector(eventDetailsAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_1]){
            
            if([allupcomingEvents count]){
                //GGLog(@"upcoming..%@",allupcomingEvents);
                [self loadEventsData:allupcomingEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
            }
            
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
            
            if([listOfBirthdayEvents count]){
                //GGLog(@"list of birthdays..%@",listOfBirthdayEvents);
                [self loadEventsData:listOfBirthdayEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
                
            }
            
            
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
            
            
            if([eventsToCelebrateArray count]){
                //GGLog(@"list of anniversaries..%@",anniversaryEvents);
                [self loadEventsData:eventsToCelebrateArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
                
            }
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4] || [eventTitleLbl.text isEqualToString:@""]){
            
            if([searchContactsArray count]){
                //GGLog(@"upcoming..%@",allupcomingEvents);
                [self loadEventsData:searchContactsArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                
            }
            
            
        }
        
        if([cell.dateLbl.text isEqualToString:@""]){
            cell.eventNameLbl.frame=CGRectMake(cell.eventNameLbl.frame.origin.x,cell.eventNameLbl.frame.origin.y,196,cell.eventNameLbl.frame.size.height);
        }
        else{
            //Dynamic[fit] label width respective to the size of the text
            CGSize eventName_maxSize = CGSizeMake(113, 21);
            CGSize eventName_new_size=[cell.eventNameLbl.text sizeWithFont:cell.eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
            cell.eventNameLbl.frame=CGRectMake(63, 29, eventName_new_size.width, 21);
            
            CGSize eventDate_maxSize = CGSizeMake(90, 21);
            CGSize eventDate_newSize = [cell.dateLbl.text sizeWithFont:cell.dateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
            
            cell.dateLbl.frame= CGRectMake(cell.eventNameLbl.frame.origin.x+3+cell.eventNameLbl.frame.size.width, 30, eventDate_newSize.width, 21);
        }
        
        
        return cell;
    }
    
	return nil;
}
//Load the events information in the table respective to the target cell
-(void)loadEventsData:(NSMutableArray*)sourceArray withCell:(EventCustomCell*)cell inTable:(UITableView*)table forIndexPath:(NSIndexPath*)indexPath{
    
    NSMutableDictionary *sourceEventsDict=[sourceArray objectAtIndex:indexPath.row];
    
    if([sourceEventsDict objectForKey:@"from"]){
        cell.bubbleIconForCommentsBtn.hidden=NO;
        cell.profileNameLbl.text=[[sourceEventsDict objectForKey:@"from"] objectForKey:@"name"];
        
    }
    else if([sourceEventsDict  objectForKey:@"FBID"]){
        cell.bubbleIconForCommentsBtn.hidden=NO;
        cell.profileNameLbl.text=[sourceEventsDict objectForKey:@"FBName"];
    }
    else{
        cell.profileNameLbl.text=[sourceEventsDict objectForKey:@"name"];
        if([sourceEventsDict  objectForKey:@"isEventFromQuery"]){
            if([[sourceEventsDict  objectForKey:@"isEventFromQuery"]isEqualToString:@"true"])
                cell.bubbleIconForCommentsBtn.hidden=NO;
            else
                cell.bubbleIconForCommentsBtn.hidden=YES;
        }
        else {
            cell.bubbleIconForCommentsBtn.hidden=YES;
        }
    }
    if([sourceEventsDict  objectForKey:@"linkedIn_id"]){
        cell.bubbleIconForCommentsBtn.hidden=NO;
    }
    if([sourceEventsDict  objectForKey:@"FBUserLocation"])
        cell.eventNameLbl.text=[sourceEventsDict  objectForKey:@"FBUserLocation"];
    else
        cell.eventNameLbl.text=[sourceEventsDict  objectForKey:@"event_type"];
    
    if([sourceEventsDict  objectForKey:@"from"]){
        cell.profileId=[NSString stringWithFormat:@"%@",[[sourceEventsDict  objectForKey:@"from"]objectForKey:@"id"]];
        
    }
    else if([sourceEventsDict  objectForKey:@"FBID"]){
        cell.profileId=[NSString stringWithFormat:@"%@",[sourceEventsDict  objectForKey:@"FBID"]];
    }
    else{
        if([sourceEventsDict  objectForKey:@"uid"])
            cell.profileId=[NSString stringWithFormat:@"%@",[sourceEventsDict  objectForKey:@"uid"]];
        
        else if([sourceEventsDict  objectForKey:@"linkedIn_id"])
            cell.profileId=[NSString stringWithFormat:@"%@",[sourceEventsDict  objectForKey:@"linkedIn_id"]];
    }
    
    
    
    if(![sourceEventsDict  objectForKey:@"FBUserLocation"]){
        NSString *dateDisplay=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[sourceEventsDict  objectForKey:@"event_date"]];
        if([dateDisplay isEqualToString:@"Today"]||[dateDisplay isEqualToString:@"Yesterday"]||[dateDisplay isEqualToString:@"Tomorrow"]||[dateDisplay isEqualToString:@"Recent"]){
            cell.dateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
            
        }
        else{
            
            cell.dateLbl.textColor=[UIColor blackColor];
        }
        cell.dateLbl.text=dateDisplay;
    }
    
    if([sourceEventsDict  objectForKey:@"from"]){
        
        NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[[sourceEventsDict  objectForKey:@"from"]objectForKey:@"id"]]];
        
        if([fm fileExistsAtPath:filePath]){
            cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
        }
        
        
    }
    else if([sourceEventsDict  objectForKey:@"FBID"]){
        
        NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[sourceEventsDict  objectForKey:@"FBID"]]];
        
        if([fm fileExistsAtPath:filePath]){
            cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
        }
        
        
    }
    else{
        if([sourceEventsDict  objectForKey:@"uid"]){
            
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[sourceEventsDict  objectForKey:@"uid"]]];
            
            if([fm fileExistsAtPath:filePath]){
                cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
            }
            
        }
        
        else if([sourceEventsDict  objectForKey:@"linkedIn_id"]){
            NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",[sourceEventsDict  objectForKey:@"linkedIn_id"]]];
            
            if([fm fileExistsAtPath:filePath]){
                cell.profileImg.image=[UIImage imageWithContentsOfFile:filePath];
            }
            
        }
        
    }
    
    
    
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([tableView isEqual:eventsTable]){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
        }
        //Gift options screen
        GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
        
        //Store the selected event information to display in all other screens
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
        
        if([eventTitleLbl.text isEqualToString:events_category_1]){
            
            if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
            }
            else{
                if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"])
                    [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                else if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                    [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            if([[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
            if([[allupcomingEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            
        }
        
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
                      
            
            if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
            }
            else{
                if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"uid"])
                    [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                else if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                    [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            if([[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
            
            if([[listOfBirthdayEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
                        
            if([[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else if([[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
            }
            else{
                if([[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"uid"])
                    [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                else if([[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                    [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                
                [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            
            if([[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
            if([[eventsToCelebrateArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4] || [eventTitleLbl.text isEqualToString:@""]){
                       
            
            if([[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
                [tempInfoDict setObject:[[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                [tempInfoDict setObject:[[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            }
            else{
                if([[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"uid"])
                    [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                else if([[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                    [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                
                [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
            }
            
            if([[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"FBUserLocation"])
                [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"FBUserLocation"] forKey:@"FBUserLocation"];
            [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
            if([[searchContactsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            else{
                [tempInfoDict setObject:[[searchContactsArray objectAtIndex:indexPath.row]objectForKey:@"ProfilePicURLToTake"] forKey:@"FBProfilePic"];
            }
            
        }
        //GGLog(@"%@",tempInfoDict);
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        [self.navigationController pushViewController:giftOptions animated:YES];
        [giftOptions release];
    }
    
}

#pragma mark - Search
- (IBAction)showSearchView:(id)sender {
    
    if([listOfContactsArray count]&& eventGroupNum!=totalGroups){
        
        eventGroupNum=totalGroups;
        pageControlForEventGroups.currentPage=eventGroupNum-1;
        [self swiping:1];
    }
    
    
    
}


/*- (IBAction)searchCancelAction:(id)sender {
    [searchBar resignFirstResponder];
    searchBar.text=@"";
    [searchBgView removeFromSuperview];
    isSearchEnabled=NO;
    [self performSelector:@selector(checkTotalNumberOfGroups)];
    
    [eventsTable reloadData];
}*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_1{
    
    /*if([searchBar_1 isEqual:searchBar]){
        [searchBar resignFirstResponder];
        searchBgView.frame=CGRectMake(0, 0, 320, 44);
        
    }
    else{*/
        [contactsSearchBar resignFirstResponder];
        if(![searchContactsArray count]){
            eventTitleLbl.text=@"No results found";
        }
    //}
    
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_1{
    /*if([searchBar_1 isEqual:searchBar]){
        searchBgView.frame=CGRectMake(0, 0, 320, 44);
        [searchBar becomeFirstResponder];
    }
    else{*/
        [contactsSearchBar becomeFirstResponder];
    //}
}
- (void)searchBar:(UISearchBar *)searchBar_1 textDidChange:(NSString *)searchText{
    
    /*if([searchBar_1 isEqual:searchBar]){
        isSearchEnabled=YES;
        if([searchText isEqualToString:@""]){
            isSearchEnabled=NO;
            
        }
        else{
            
            if([listOfContactsArray count]){
                [searchContactsArray removeAllObjects];
                for (NSMutableDictionary *event in listOfContactsArray)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                       
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchContactsArray addObject:event];
                            
                        }
                    }
                    else{
                       
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchContactsArray addObject:event];
                            
                            
                        }
                    }
                    
                }
            }
        
        }
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
    }*/
    /*else{*/
        if([contactsSearchBar.text isEqualToString:@""]){
            if([searchContactsArray count])
                [searchContactsArray removeAllObjects];
        }
        if([listOfContactsArray count]){
            [searchContactsArray removeAllObjects];
            for (NSMutableDictionary *event in listOfContactsArray)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"(SELF contains[cd] %@)", contactsSearchBar.text];
                
                if([event objectForKey:@"from"]){
                    
                    [[[event objectForKey:@"from"] objectForKey:@"name"] compare:contactsSearchBar.text options:NSCaseInsensitiveSearch];
                    BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                    
                    if(resultName)
                    {
                        [searchContactsArray addObject:event];
                        
                    }
                }
                else{
                    //GGLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                    [[event objectForKey:@"name"] compare:contactsSearchBar.text options:NSCaseInsensitiveSearch];
                    BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                    if(resultName)
                        
                    {
                        [searchContactsArray addObject:event];
                        
                        
                    }
                }
                
            }
            if([searchContactsArray count]){
                eventTitleLbl.text=events_category_4;
            }
            else
                eventTitleLbl.text=@"";
        }
    //}
    [eventsTable reloadData];
}

#pragma mark - EventDetails
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
    
    if([eventTitleLbl.text isEqualToString:events_category_1]){
        
        if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        
        
        if([[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]forKey:@"userID"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]forKey:@"userID"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
            
        }
        if([[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"EventID"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
        else if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"update_key"]){
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
        }
        else
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        //GGLog(@" temp dict..%@",tempInfoDict);
        if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
            [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        
    }
    
    else if([eventTitleLbl.text isEqualToString:events_category_2]){
        
        if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        
        
        if([[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"] forKey:@"userID"];
        }
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
        }
        if([[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        
        if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
        else if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"id"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        if([[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
            [tempInfoDict setObject:[[listOfBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        
        
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_3]){
        
        
        if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
            details.isPhotoTagged=YES;
        }
        else
            details.isPhotoTagged=NO;
        
        
        if([[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
            [tempInfoDict setObject:[[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"uid"]){
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
        }
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"] forKey:@"userID"];
        }
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
        }
        if([[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
            [tempInfoDict setObject:[[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"name"])
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBName"])
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
        
        [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
        [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
        if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"])
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
        else if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"id"])
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
        
        if([[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
            [tempInfoDict setObject:[[eventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        
        
    }
    [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
    
    [tempInfoDict release];
    
    [self.navigationController pushViewController:details animated:YES];
    [details release];
    
}
//Setting screen
- (IBAction)settingsAction:(id)sender {
    SettingsVC *settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    settings.showAboutUs=NO;
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
    
}
- (IBAction)showContactUsScreen:(id)sender{
    SettingsVC *settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    settings.showAboutUs=YES;
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}
#pragma mark - Pagecontrol
- (IBAction)pageControlActionForEventGroups:(id)sender {
    
    //if(currentiOSVersion<6.0){
        for (int i = 0; i < [pageControlForEventGroups.subviews count]; i++)
        {
            UIImageView* dot = [pageControlForEventGroups.subviews objectAtIndex:i];
            if (i == pageControlForEventGroups.currentPage)
                dot.image = pageActiveImage;
            else
                dot.image = pageInactiveImage;
        }
    //}
    
    if(pageControlForEventGroups.currentPage>eventGroupNum-1){
        eventGroupNum=pageControlForEventGroups.currentPage+1;
        [self swiping:1];
    }
    else{
        eventGroupNum=pageControlForEventGroups.currentPage+1;
        [self swiping:0];
    }
    
}
#pragma mark -
- (IBAction)showListOfOrders:(id)sender {
    OrderHistoryListVC *orders=[[OrderHistoryListVC alloc]initWithNibName:@"OrderHistoryListVC" bundle:nil];
    [self.navigationController pushViewController:orders animated:YES];
    [orders release];
    
}
#pragma mark - Facebook Events delegate
- (void)receivedBirthDayEvents:(NSMutableArray*)listOfBirthdays{
    
    if(!isEventsLoadingFromFB)
        return;
    
    
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
            
            [listOfBirthdayEvents replaceObjectAtIndex:i withObject:tempDict];
        }
        [allupcomingEvents addObjectsFromArray:listOfBirthdayEvents];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        [eventsTable reloadData];
        
        birthdayEventUserNoToAddAsUser=1;
        
        
        //Store the events to show in success screen
        [self storeAllupcomingsForSuccessScreen];
        
        [self makeRequestToLoadImagesUsingOperations:listOfBirthdayEvents];
        
        //Add these event users as users in giftgiv server
        [self makeRequestToAddUserForFB:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];
    }
    
    
}
-(void)checkAndStartOperationToDownloadPicForTheEvent:(NSDictionary*)eventData{
    
    NSString *urlStr_id=nil;
    if([eventData objectForKey:@"uid"])
        urlStr_id=[eventData objectForKey:@"uid"];
    else if([eventData objectForKey:@"from"])
        urlStr_id=[[eventData objectForKey:@"from"] objectForKey:@"id"];
    else if([eventData objectForKey:@"linkedIn_id"])
        urlStr_id=[eventData objectForKey:@"linkedIn_id"];
    else if([eventData objectForKey:@"FBID"])
        urlStr_id=[eventData objectForKey:@"FBID"];
    
    if(urlStr_id){
        
        if (![fm fileExistsAtPath: [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",urlStr_id]]]){
            
            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithCapacity:2];
            [tempDict setObject:urlStr_id forKey:@"profile_id"];
            
            if([eventData objectForKey:@"uid"])
            {
                if([eventData objectForKey:@"pic_square"])
                    [tempDict setObject:[eventData objectForKey:@"pic_square"] forKey:@"profile_url"];
                else
                    [tempDict setObject:FacebookPicURL([eventData objectForKey:@"uid"]) forKey:@"profile_url"];
                
            }
            else if([eventData objectForKey:@"from"])
            {
                if([eventData objectForKey:@"pic_square"])
                    [tempDict setObject:[eventData objectForKey:@"pic_square"] forKey:@"profile_url"];
                else
                    [tempDict setObject:FacebookPicURL([[eventData objectForKey:@"from"] objectForKey:@"id"]) forKey:@"profile_url"];
                
                
            }
            else if([eventData objectForKey:@"FBID"])
            {
                if([eventData objectForKey:@"pic_square"])
                    [tempDict setObject:[eventData objectForKey:@"pic_square"] forKey:@"profile_url"];
                else
                    [tempDict setObject:FacebookPicURL([eventData objectForKey:@"FBID"]) forKey:@"profile_url"];
                
                
            }
            else if([eventData objectForKey:@"linkedIn_id"])
            {
                [tempDict setObject:[eventData objectForKey:@"pic_url"] forKey:@"profile_url"];
                
            }
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadProfileImgWithOperationForEvents:) object:tempDict];
            
            [tempDict release];
            
            [picturesOperationQueue addOperation:operation];
            
            [operation release];
            
            
        }
        
    }
    
}
-(void) makeRequestToLoadImagesUsingOperations:(id)source{
    
    if([source isKindOfClass:[NSMutableArray class]]){
        int upcomingsCount=[allupcomingEvents count];
        for(int i=0;i<upcomingsCount;i++){
            [self checkAndStartOperationToDownloadPicForTheEvent:(NSDictionary*)[source objectAtIndex:i]];
        }
    }
    else{
        [self checkAndStartOperationToDownloadPicForTheEvent:(NSDictionary*)source];
    }
    
    
}

-(void)makeRequestToAddUserForFB:(NSMutableDictionary*)userDetails{
    
    if([CheckNetwork connectedToNetwork]){
        
        NSString *picURL;
        if([userDetails objectForKey:@"pic_square"]){
            picURL=[userDetails objectForKey:@"pic_square"];
        }
        else
            picURL=FacebookPicURL([userDetails objectForKey:@"uid"]);
        
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddNormalUser>\n<tem:fbId>%@</tem:fbId>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>%@</tem:profilePictureUrl>\n</tem:AddNormalUser>",[userDetails objectForKey:@"uid"],[userDetails objectForKey:@"first_name"],[userDetails objectForKey:@"last_name"],picURL];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //GGLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddNormalUser"];
        
        AddUserRequest *addUser=[[AddUserRequest alloc]init];
        [addUser setAddUserDelegate:self];
        [addUser addUserServiceRequest:theRequest];
        [addUser release];
    }
    else{
        AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network connection", nil);
    }
    
}
- (void)facebookDidRequestFailed{
    GGLog(@"facebook did request failed..");
    
}
#pragma mark - Events from statuses
- (void)birthdayEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(!isEventsLoadingFromFB)
        return;
    for (NSDictionary *existEvents in listOfBirthdayEvents){
        NSString *existEventUserIDStr=@"";
        if([existEvents objectForKey:@"uid"])
            existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
        else if([existEvents objectForKey:@"FBID"])
            existEventUserIDStr=[existEvents objectForKey:@"FBID"];
        NSString *eventDetailsUserIDStr;
        if([eventDetails objectForKey:@"FBID"]){
            if([[eventDetails objectForKey:@"FBID"] isKindOfClass:[NSDecimalNumber class]])
                [eventDetails setObject:[NSString stringWithFormat:@"%@",[eventDetails objectForKey:@"FBID"]] forKey:@"FBID"];
            
            eventDetailsUserIDStr=[eventDetails objectForKey:@"FBID"];
        }
        else
            eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventDetails objectForKey:@"from"]objectForKey:@"id"]];
        if([[NSString stringWithFormat:@"%@",existEventUserIDStr] isEqualToString:[NSString stringWithFormat:@"%@",eventDetailsUserIDStr]]){
            //GGLog(@"same..");
            return ;
        }
        else{
            //GGLog(@"%@,%@,not same..",[NSString stringWithFormat:@"%@",existEventUserIDStr],[NSString stringWithFormat:@"%@",eventDetailsUserIDStr]);
        }
    }
    
    
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    if([eventDetails objectForKey:@"PhotoCreatedDate"])
        [customDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    else
        [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSDate *convertedDateFromString;
    if([eventDetails objectForKey:@"PhotoCreatedDate"]){
        convertedDateFromString=[eventDetails objectForKey:@"PhotoCreatedDate"];
        
    }
    else{
        convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
    }
    
    [customDateFormat setDateFormat:@"yyyy-MM-dd"];
    
    [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
    [eventDetails setObject:@"birthday" forKey:@"event_type"];
    
    
    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:eventDetails];
    if([eventDetails objectForKey:@"FBID"]){
        [tempDict setObject:[eventDetails objectForKey:@"FBID"] forKey:@"uid"];
        NSArray *fbnameComponents=[[eventDetails objectForKey:@"FBName"]componentsSeparatedByString:@" "];
        if([fbnameComponents count]>1){
            [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
            [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
        }
        else{
            [tempDict setObject:[eventDetails objectForKey:@"FBName"] forKey:@"first_name"];
            [tempDict setObject:@"" forKey:@"last_name"];
        }
    }
    else{
        [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"id"] forKey:@"uid"];
        NSArray *fbnameComponents=[[[eventDetails objectForKey:@"from"] objectForKey:@"name"]componentsSeparatedByString:@" "];
        if([fbnameComponents count]>1){
            [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
            [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
        }
        else{
            [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"name"] forKey:@"first_name"];
            [tempDict setObject:@"" forKey:@"last_name"];
        }
    }
    //Add these event users as users in giftgiv server
    [self makeRequestToAddUserForFB:tempDict];
    [tempDict release];
    
    [listOfBirthdayEvents addObject:eventDetails];
    [allupcomingEvents addObject:eventDetails];
    [self performSelector:@selector(checkTotalNumberOfGroups)];
    
    
    if([allupcomingEvents count]>1)
        [self sortEvents:allupcomingEvents eventCategory:1];
    if([listOfBirthdayEvents count]>1)
        [self sortEvents:listOfBirthdayEvents eventCategory:2];
    [eventsTable reloadData];
    [self storeAllupcomingsForSuccessScreen];
    [self makeRequestToLoadImagesUsingOperations:eventDetails];
}
-(void)storeAllupcomingsForSuccessScreen{
    
    NSMutableArray *tempArray=[[NSMutableArray alloc]initWithArray:allupcomingEvents];
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AllUpcomingEvents"];
    }
    [[NSUserDefaults standardUserDefaults]setObject:tempArray forKey:@"AllUpcomingEvents"];
    
    [tempArray release];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[allupcomingEvents count]];
    
}
- (void)newJobEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(!isEventsLoadingFromFB)
        return;
    [eventDetails setObject:@"new job" forKey:@"event_type"];
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        if([eventDetails objectForKey:@"PhotoCreatedDate"])
            [customDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        else
            [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"PhotoCreatedDate"]){
            convertedDateFromString=[eventDetails objectForKey:@"PhotoCreatedDate"];
            
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        
        
        NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:eventDetails];
        if([eventDetails objectForKey:@"FBID"]){
            [tempDict setObject:[eventDetails objectForKey:@"FBID"] forKey:@"uid"];
            NSArray *fbnameComponents=[[eventDetails objectForKey:@"FBName"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[eventDetails objectForKey:@"FBName"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        else{
            [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"id"] forKey:@"uid"];
            NSArray *fbnameComponents=[[[eventDetails objectForKey:@"from"] objectForKey:@"name"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"name"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        
        //Add this event's user as users in giftgiv server
        [self makeRequestToAddUserForFB:tempDict];
        
        [tempDict release];
        
        [eventsToCelebrateArray addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        if([allupcomingEvents count])
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([eventsToCelebrateArray count])
            [self sortEvents:eventsToCelebrateArray eventCategory:3];
        
        [eventsTable reloadData];
        [self storeAllupcomingsForSuccessScreen];
        [self makeRequestToLoadImagesUsingOperations:eventDetails];
        
        
    }
    
}
- (void)anniversaryEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(!isEventsLoadingFromFB)
        return;
    
    [eventDetails setObject:@"relationships" forKey:@"event_type"];
    
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        if([eventDetails objectForKey:@"PhotoCreatedDate"])
            [customDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        else
            [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"PhotoCreatedDate"]){
            convertedDateFromString=[eventDetails objectForKey:@"PhotoCreatedDate"];
            
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        
        
        NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:eventDetails];
        if([eventDetails objectForKey:@"FBID"]){
            [tempDict setObject:[eventDetails objectForKey:@"FBID"] forKey:@"uid"];
            NSArray *fbnameComponents=[[eventDetails objectForKey:@"FBName"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[eventDetails objectForKey:@"FBName"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        else{
            [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"id"] forKey:@"uid"];
            NSArray *fbnameComponents=[[[eventDetails objectForKey:@"from"] objectForKey:@"name"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"name"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        
        //Add this event's user as users in giftgiv server
        [self makeRequestToAddUserForFB:tempDict];
        [tempDict release];
        
        
        [eventsToCelebrateArray addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([eventsToCelebrateArray count]>1)
            [self sortEvents:eventsToCelebrateArray eventCategory:3];
        
        [eventsTable reloadData];
        [self storeAllupcomingsForSuccessScreen];
        [self makeRequestToLoadImagesUsingOperations:eventDetails];
    }
}
- (void)congratsEventDetailsFromStatusOrPhoto:(NSMutableDictionary*)eventDetails{
    
    if(!isEventsLoadingFromFB)
        return;
    [eventDetails setObject:@"congratulations" forKey:@"event_type"];
    
    if(![self checkWhetherEventExistInTheListOfEvents:eventDetails]){
        
        if(customDateFormat==nil){
            customDateFormat=[[NSDateFormatter alloc]init];
        }
        
        if([eventDetails objectForKey:@"PhotoCreatedDate"])
            [customDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        else
            [customDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        
        NSDate *convertedDateFromString;
        if([eventDetails objectForKey:@"PhotoCreatedDate"]){
            convertedDateFromString=[eventDetails objectForKey:@"PhotoCreatedDate"];
            
        }
        else{
            convertedDateFromString=[customDateFormat dateFromString:[eventDetails objectForKey:@"updated_time"]];
        }
        
        [eventDetails setObject:[customDateFormat stringFromDate:convertedDateFromString]forKey:@"event_date"];
        
        [eventsToCelebrateArray addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        
        
        NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:eventDetails];
        if([eventDetails objectForKey:@"FBID"]){
            [tempDict setObject:[eventDetails objectForKey:@"FBID"] forKey:@"uid"];
            NSArray *fbnameComponents=[[eventDetails objectForKey:@"FBName"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[eventDetails objectForKey:@"FBName"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        else{
            [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"id"] forKey:@"uid"];
            NSArray *fbnameComponents=[[[eventDetails objectForKey:@"from"] objectForKey:@"name"]componentsSeparatedByString:@" "];
            if([fbnameComponents count]>1){
                [tempDict setObject:[fbnameComponents objectAtIndex:0] forKey:@"first_name"];
                [tempDict setObject:[fbnameComponents objectAtIndex:1] forKey:@"last_name"];
            }
            else{
                [tempDict setObject:[[eventDetails objectForKey:@"from"] objectForKey:@"name"] forKey:@"first_name"];
                [tempDict setObject:@"" forKey:@"last_name"];
            }
        }
        
        //Add this event's user as users in giftgiv server
        [self makeRequestToAddUserForFB:tempDict];
        [tempDict release];
        
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([eventsToCelebrateArray count]>1)
            [self sortEvents:eventsToCelebrateArray eventCategory:3];
        
        [eventsTable reloadData];
        [self storeAllupcomingsForSuccessScreen];
        [self makeRequestToLoadImagesUsingOperations:eventDetails];
        
    }
}
#pragma  mark - Sorting
- (void)sortEvents:(NSMutableArray*)listOfEvents eventCategory:(int)catNum{
	
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
	int eventsCount=[listOfEvents count];
    
    //Sort the events respective to the event date
	for (int i=0; i<eventsCount;i++) {
        
        if([[[listOfEvents objectAtIndex:i] objectForKey:@"event_date"] isKindOfClass:[NSString class]]&& ![[[listOfEvents objectAtIndex:i] objectForKey:@"event_date"] isEqualToString:@""]){
            
            
            if([[[[listOfEvents objectAtIndex:i]objectForKey:@"event_date"] componentsSeparatedByString:@"T"] count]>1){
                [[listOfEvents objectAtIndex:i]setObject:[[[[listOfEvents objectAtIndex:i]objectForKey:@"event_date"] componentsSeparatedByString:@"T"]objectAtIndex:0] forKey:@"event_date"];
            }
            if([[[[listOfEvents objectAtIndex:i]objectForKey:@"event_date"] componentsSeparatedByString:@" "] count]>1){
                [[listOfEvents objectAtIndex:i]setObject:[[[[listOfEvents objectAtIndex:i]objectForKey:@"event_date"] componentsSeparatedByString:@" "]objectAtIndex:0] forKey:@"event_date"];
                
            }
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
            //events to celebrate
        case 3:
            
            [eventsToCelebrateArray replaceObjectsInRange:NSMakeRange(0, [eventsToCelebrateArray count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            
            
            break;
            //contacts
        case 4:
        {
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [listOfContactsArray replaceObjectsInRange:NSMakeRange(0, [listOfContactsArray count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]]];
            [nameSortDescriptor release];
        }
            
            break;
            
    }
    
    
    [sortDescriptor release];
    
	
}
#pragma mark - Check Event existance
-(BOOL)checkWhetherEventExistInTheListOfEvents:(NSMutableDictionary*)eventsData{
    
    for (NSDictionary *existEvents in eventsToCelebrateArray){
        
        NSString *existEventUserIDStr=@"";
        if([existEvents objectForKey:@"from"]){
            existEventUserIDStr=[NSString stringWithFormat:@"%@",[[existEvents objectForKey:@"from"]objectForKey:@"id"]];
            
        }
        else if([existEvents objectForKey:@"FBID"]){
            existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"FBID"]];
        }
        else{
            if([existEvents objectForKey:@"uid"])
                existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"uid"]];
            
            else if([existEvents objectForKey:@"linkedIn_id"])
                existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"linkedIn_id"]];
            
            
        }
        
        NSString *eventDetailsUserIDStr;
        if([eventsData objectForKey:@"FBID"])
            eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[eventsData objectForKey:@"FBID"]];
        else
            eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[[eventsData objectForKey:@"from"]objectForKey:@"id"]];
        
        
        //right now, If the user is having two different events, it shows only one, to avoid that just uncomment the below if and else block
        
        if([[NSString stringWithFormat:@"%@",existEventUserIDStr] isEqualToString:[NSString stringWithFormat:@"%@",eventDetailsUserIDStr]]){
            //if([[existEvents objectForKey:@"event_type"] isEqualToString:[eventsData objectForKey:@"event_type"]])
            return YES;
            //else
            //  return NO;
        }
        
    }
    return NO;
}
-(BOOL)checkWhetherLinkedInEventExist:(NSMutableDictionary*)linkedInDict{
    
    //All linkedIn events related to newJob category only, so we no need to check with other categories as we have with facebook
    
    for (NSDictionary *existEvents in eventsToCelebrateArray){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"linkedIn_id"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[linkedInDict objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return YES;
    }
    return NO;
}
#pragma mark - LinkedIn delegate

- (void)linkedInLoggedInWithUserDetails:(NSMutableDictionary*)userDetails{
    
    [[NSUserDefaults standardUserDefaults]setObject:userDetails forKey:@"MyLinkedInDetails"];
    
    if([CheckNetwork connectedToNetwork]){
        
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>%@</tem:fbId>\n<tem:lid>%@</tem:lid>\n<tem:lnAccessToken>%@</tem:lnAccessToken>\n<tem:lnSecretKey>%@</tem:lnSecretKey>\n<tem:lnTokenVerifier>%@</tem:lnTokenVerifier>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>%@/picture</tem:profilePictureUrl>\n</tem:AddUser>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"uid"],[userDetails objectForKey:@"id"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInAccessToken"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInSecretKey"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInOauthVerifier"],[userDetails objectForKey:@"first-name"],[userDetails objectForKey:@"last-name"],[userDetails objectForKey:@"picture-url"]];
        [self performSelector:@selector(makeRequestToAddUserForLinkedIn:)withObject:soapmsgFormat];
        
    }
}
-(void)makeRequestToAddUserForLinkedIn:(NSString*)requestString{
    NSString *soapRequestString=SOAPRequestMsg(requestString);
    GGLog(@"soap message..%@",soapRequestString);
    NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddUser"];
    
    AddUser_LinkedInRequest *addUser=[[AddUser_LinkedInRequest alloc]init];
    [addUser setAddLnUserDelegate:self];
    [addUser addLnUserServiceRequest:theRequest];
    [addUser release];
}
- (void)linkedInDidRequestFailed{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
- (void)receivedLinkedInNewEvent:(NSMutableDictionary*)result{
    
    if(![self checkWhetherLinkedInEventExist:result]){
        
        NSMutableDictionary *linkedInEvent=[[NSMutableDictionary alloc]init];
        [linkedInEvent setObject:[result objectForKey:@"id"] forKey:@"linkedIn_id"];
        [linkedInEvent setObject:[NSString stringWithFormat:@"%@ %@",[result objectForKey:@"first-name"],[result objectForKey:@"last-name"]] forKey:@"name"];
        [linkedInEvent setObject:[[[result objectForKey:@"positions"]objectForKey:@"position"]objectForKey:@"title"] forKey:@"positionTitle"];
        [linkedInEvent setObject:[[[[result objectForKey:@"positions"]objectForKey:@"position"]objectForKey:@"company"]objectForKey:@"name"] forKey:@"companyName"];
        [linkedInEvent setObject:[result objectForKey:@"update_key"] forKey:@"update_key"];
        [linkedInEvent setObject:@"new job" forKey:@"event_type"];
        NSMutableDictionary *startDateDict=[[[result objectForKey:@"positions"]objectForKey:@"position"] objectForKey:@"start-date"];
        NSString *convertedDateString=[startDateDict objectForKey:@"year"];
        if([startDateDict objectForKey:@"month"])
            convertedDateString=[convertedDateString stringByAppendingFormat:@"-%@-01",[startDateDict objectForKey:@"month"]];
        else
            convertedDateString=[convertedDateString stringByAppendingString:@"-01-01"];
        [linkedInEvent setObject:convertedDateString forKey:@"event_date"];
        if([result objectForKey:@"picture-url"])
            [linkedInEvent setObject:[result objectForKey:@"picture-url"] forKey:@"pic_url"];
        else
            [linkedInEvent setObject:@"" forKey:@"pic_url"];
        
        
        [eventsToCelebrateArray addObject:linkedInEvent];
        [allupcomingEvents addObject:linkedInEvent];
        [linkedInEvent release];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        if([allupcomingEvents count]>1)
            [self sortEvents:allupcomingEvents eventCategory:1];
        if([eventsToCelebrateArray count]>1)
            [self sortEvents:eventsToCelebrateArray eventCategory:3];
        [eventsTable reloadData];
        [self storeAllupcomingsForSuccessScreen];
        [self makeRequestToLoadImagesUsingOperations:linkedInEvent];
        
        //Add this event's user to giftgiv server (AddUser--> LinkedIn loggedInuser or event's user)
        if([CheckNetwork connectedToNetwork]){
            
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>null</tem:fbId>\n<tem:lid>%@</tem:lid>\n<tem:lnAccessToken>null</tem:lnAccessToken>\n<tem:lnSecretKey>null</tem:lnSecretKey>\n<tem:lnTokenVerifier>null</tem:lnTokenVerifier>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>%@/picture</tem:profilePictureUrl>\n</tem:AddUser>",[result objectForKey:@"id"],[result objectForKey:@"first-name"],[result objectForKey:@"last-name"],[result objectForKey:@"picture-url"]];
            [self performSelector:@selector(makeRequestToAddUserForLinkedIn:)withObject:soapmsgFormat];
            
        }
        
    }
    
}

#pragma mark - Add User Request delegate
-(void) responseForLnAddUser:(NSMutableDictionary*)response{
    GGLog(@"added user..%@",response);
    if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
        [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
    }
    
}
-(void)makeRequestToGetContactsForLinkedIn{
    if(!isLnContactsLoading){
        if([CheckNetwork connectedToNetwork]){
            isLnContactsLoading=YES;
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetLinkedInList>\n<tem:userId>%@</tem:userId>\n<tem:linkedInAccessToken>%@</tem:linkedInAccessToken>\n<tem:linkedInSecretKey>%@</tem:linkedInSecretKey>\n<tem:tokenVerifier>%@</tem:tokenVerifier>\n</tem:GetLinkedInList>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInAccessToken"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInSecretKey"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInOauthVerifier"]];
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            //GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetLinkedInList"];
            
            LinkedInContactsRequest *lnContacts=[[LinkedInContactsRequest alloc]init];
            [lnContacts setLnContactsDelegate:self];
            [lnContacts getLnContactsForRequest:theRequest];
            [lnContacts release];
            
        }
    }
}
-(void) responseForAddUser:(NSMutableDictionary*)response{
    // Related to facebook users
    if([response objectForKey:@"NormalUser"]){
        
        //response will return userID.
        if(birthdayEventUserNoToAddAsUser<[listOfBirthdayEvents count]){
            birthdayEventUserNoToAddAsUser++;
            [self makeRequestToAddUserForFB:[listOfBirthdayEvents objectAtIndex:birthdayEventUserNoToAddAsUser-1]];
        }
    }
    
}
-(void) requestFailed{
    //AlertWithMessageAndDelegate(@"GiftGiv", @"Request has failed. Please try again later", nil);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
-(void)logoutFromAllAccounts{
    
    [fb_giftgiv_home setFbGiftGivDelegate:nil];
    [lnkd_giftgiv_home setLnkInGiftGivDelegate:nil];
    
    
    [picturesOperationQueue cancelAllOperations];
    //[eventProfilePicOpQueue cancelAllOperations];
    isCancelledImgOperations=YES;
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
    
    [self setContactsSearchView:nil];
    [self setContactsSearchBar:nil];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:picturesOperationQueue name:UIApplicationWillTerminateNotification object:nil];
    
    [picturesOperationQueue cancelAllOperations];
    [picturesOperationQueue release];
    
    
    dispatch_release(ImageLoader_Q);
    dispatch_release(ImageLoader_Q_ForEvents);
    [fb_giftgiv_home setFbGiftGivDelegate:nil];
    [lnkd_giftgiv_home setLnkInGiftGivDelegate:nil];
    
    [searchContactsArray release];
   
    [pageActiveImage release];
    [pageInactiveImage release];
   
    if([globalContactsList count]){
        [globalContactsList removeAllObjects];
        [globalContactsList release];
        globalContactsList=nil;
    }
    [listOfBirthdayEvents release];
    [eventsToCelebrateArray release];
    [listOfContactsArray release];
    
    [allupcomingEvents release];
    
    [categoryTitles release];
    [eventsBgView release];
    [eventTitleLbl release];
    [pageControlForEventGroups release];
    [eventsTable release];
      
    [contactsSearchView release];
    [contactsSearchBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftGivUserIDReceived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoggedOut" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LinkedInLoggedIn" object:nil];
    [super dealloc];
}

@end
