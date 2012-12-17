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
@synthesize pageControlForEventGroups;
@synthesize listOfContactsArray;

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
    
   _searchBgImg.image=[[ImageAllocationObject loadImageObjectName:@"strip" ofType:@"png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    searchContactsArray=[[NSMutableArray alloc]init];
    
    pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive2" ofType:@"png"] retain];
    pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive2" ofType:@"png"] retain];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:picturesOperationQueue selector:@selector(cancelAllOperations) name:UIApplicationWillTerminateNotification object:nil];
    
    //[self performSelector:@selector(loadGestures)withObject:nil afterDelay:0.1];
    
    //To update the page dot and group which currently viewing.
    eventGroupNum=1;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    //Create an operation for profile picture downloads
    picturesOperationQueue=[[NSOperationQueue alloc]init];
    
    [super viewDidLoad];
    
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
        GGLog(@"%@",soapRequestString);
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
        GGLog(@"events request..%@",soapRequestString);
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
    GGLog(@"Events receied from server..%@",allEvents);
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
            GGLog(@"Event type..%@",eventType);
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
                
                //need to reload the table
                for (id subview in [_eventsBgScroll subviews]){
                    if([subview isKindOfClass:[UITableView class]]){
                        [(UITableView*)subview reloadData];
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
                
                
                
            });
        }
        
    });
    
}
#pragma mark -

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
    _eventsBgScroll.contentSize=CGSizeMake(320*(totalGroups+2), _eventsBgScroll.bounds.size.height);
    if([[_eventsBgScroll subviews] count]){
        for(id subView in [_eventsBgScroll subviews]){
            if([subView isKindOfClass:[UILabel class]] || [subView isKindOfClass:[UITableView class]]){
                [subView removeFromSuperview];
            }
        }
    }
    if(totalGroups>0){
        eventsPopulated=YES;
        //int tagIndexForTitle=0;
        for(int i=0;i<totalGroups;i++){
            UILabel *eventHeadingLbl=[[UILabel alloc]initWithFrame:CGRectMake(13+(320*(i+1)),8,297,47)];
            eventHeadingLbl.autoresizesSubviews=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            //GGLog(@"count %d and %d",totalGroups,i);
           
            eventHeadingLbl.tag=i+1;
            [eventHeadingLbl setText:[categoryTitles objectAtIndex:i]];
            [eventHeadingLbl setTextColor:[UIColor colorWithRed:0 green:0.647 blue:0.647 alpha:1.0]];
            [eventHeadingLbl setFont:[UIFont fontWithName:@"Helvetica-Light" size:27]];
            [eventHeadingLbl setBackgroundColor:[UIColor clearColor]];
            
            
            [_eventsBgScroll addSubview:eventHeadingLbl];
            [eventHeadingLbl release];
            
            UITableView *tempEventsTable=[[UITableView alloc]initWithFrame:CGRectMake(10+(320*(i+1)), 59, 300, _eventsBgScroll.bounds.size.height-59)];
            tempEventsTable.autoresizesSubviews=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [tempEventsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            
            tempEventsTable.tag=i+51;
            
            [tempEventsTable setDataSource:self];
            [tempEventsTable setDelegate:self];
            [_eventsBgScroll addSubview:tempEventsTable];
            [tempEventsTable release];
        }
    }
    pageControlForEventGroups.numberOfPages=totalGroups;
    if(totalGroups==1)
        eventGroupNum=1;
    if(totalGroups==1 && [[categoryTitles objectAtIndex:0] isEqualToString:events_category_4]){
        contactsSearchView.frame=CGRectMake(0, 0, 320, 44);
        if(![contactsSearchView superview]){
            
            [self.view addSubview:contactsSearchView];
        }
        [contactsSearchBar becomeFirstResponder];
    }
    if(!eventsPopulated){
        [_eventsBgScroll scrollRectToVisible:CGRectMake(320,0,320,416) animated:NO];
        
    }
    if([listOfContactsArray count]){
        pageControlForEventGroups.currentPage=eventGroupNum;
    }
    else
        pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    
    
    
}
#pragma mark - Transition

#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	

    if([allupcomingEvents count]){
        if(tableView.tag==51)
            return [allupcomingEvents count];
    }
    if([listOfBirthdayEvents count]){
        if(tableView.tag==52)
            return [listOfBirthdayEvents count];
    }
    if([eventsToCelebrateArray count]){
        if([listOfBirthdayEvents count]){
            if(tableView.tag==53)
                return [eventsToCelebrateArray count];
        }
        
        else{
            if(tableView.tag==52)
                return [eventsToCelebrateArray count];
        }
    }
    if([searchContactsArray count]){
        if([allupcomingEvents count]){
            if((![listOfBirthdayEvents count] && [eventsToCelebrateArray count]) || ([listOfBirthdayEvents count] && ![eventsToCelebrateArray count])){
                if(tableView.tag==53){
                    return [searchContactsArray count];
                }
            }
            else{
                if(tableView.tag==54)
                    return [searchContactsArray count];
            }
        }
        else{
            if(tableView.tag==51)
                return [searchContactsArray count];
        }
    }
    

    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier;
    cellIdentifier=[NSString stringWithFormat:@"Cell%d%d",eventGroupNum,indexPath.row];
    
    EventCustomCell *cell = (EventCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"EventCustomCell" owner:self options:nil] lastObject];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.bubbleIconForCommentsBtn.tag=indexPath.row;
        [cell.bubbleIconForCommentsBtn addTarget:self action:@selector(eventDetailsAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    if([allupcomingEvents count]){
        if(tableView.tag==51)
            [self loadEventsData:allupcomingEvents withCell:cell inTable:tableView forIndexPath:indexPath];
    }
    if([listOfBirthdayEvents count]){
        if(tableView.tag==52)
            [self loadEventsData:listOfBirthdayEvents withCell:cell inTable:tableView forIndexPath:indexPath];
    }
    if([eventsToCelebrateArray count]){
        if([listOfBirthdayEvents count]){
            if(tableView.tag==53)
                [self loadEventsData:eventsToCelebrateArray withCell:cell inTable:tableView forIndexPath:indexPath];
        }
        
        else{
            if(tableView.tag==52)
                [self loadEventsData:eventsToCelebrateArray withCell:cell inTable:tableView forIndexPath:indexPath];
        }
    }
    if([searchContactsArray count]){
        if([allupcomingEvents count]){
            if((![listOfBirthdayEvents count] && [eventsToCelebrateArray count]) || ([listOfBirthdayEvents count] && ![eventsToCelebrateArray count])){
                if(tableView.tag==53){
                    [self loadEventsData:searchContactsArray withCell:cell inTable:tableView forIndexPath:indexPath];
                }
            }
            else{
                if(tableView.tag==54)
                    [self loadEventsData:searchContactsArray withCell:cell inTable:tableView forIndexPath:indexPath];
            }
        }
        else{
            if(tableView.tag==51)
                [self loadEventsData:searchContactsArray withCell:cell inTable:tableView forIndexPath:indexPath];
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
    
    //if([tableView isEqual:eventsTable]){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
        }
        //Gift options screen
        GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
        
        //Store the selected event information to display in all other screens
    
    if([allupcomingEvents count]){
        if(tableView.tag==51)
        {
            NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[allupcomingEvents objectAtIndex:indexPath.row]];
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
        }
    }
    if([listOfBirthdayEvents count]){
        if(tableView.tag==52)
        {
            NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[listOfBirthdayEvents objectAtIndex:indexPath.row]];
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                  
        }
    }
    if([eventsToCelebrateArray count]){
        if([listOfBirthdayEvents count]){
            if(tableView.tag==53)
            {
                NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[eventsToCelebrateArray objectAtIndex:indexPath.row]];
                [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                
            }
        }
        
        else{
            if(tableView.tag==52)
            {
                NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[eventsToCelebrateArray objectAtIndex:indexPath.row]];
                [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                
            }
        }
    }
    if([searchContactsArray count]){
        if([allupcomingEvents count]){
            if((![listOfBirthdayEvents count] && [eventsToCelebrateArray count]) || ([listOfBirthdayEvents count] && ![eventsToCelebrateArray count])){
                if(tableView.tag==53){
                    {
                        NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[searchContactsArray objectAtIndex:indexPath.row]];
                        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                        
                    }
                }
            }
            else{
                if(tableView.tag==54)
                {
                    NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[searchContactsArray objectAtIndex:indexPath.row]];
                    [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                    
                }
            }
        }
        else{
            if(tableView.tag==51)
            {
                NSMutableDictionary *tempInfoDict=[self collectTheDetailsOfSelectedEvent:[searchContactsArray objectAtIndex:indexPath.row]];
                [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
                
            }
        }
    }
        
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
    
    
}
-(NSMutableDictionary*)collectTheDetailsOfSelectedEvent:(NSMutableDictionary*)sourceDict{
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"DummyUserId"])
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DummyUserId"];
   
    if([sourceDict objectForKey:@"uid"]){
        if([[NSString stringWithFormat:@"%@",[sourceDict objectForKey:@"uid"]] isEqualToString:@"0"]){
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddNormalUserv2>\n<tem:fbId></tem:fbId>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName></tem:lastName>\n<tem:profilePictureUrl></tem:profilePictureUrl>\n</tem:AddNormalUserv2>",[sourceDict objectForKey:@"name"]];
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            //GGLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"AddNormalUserv2"];
            
            AddNormalUserv_2_Request *addUser=[[AddNormalUserv_2_Request alloc]init];
            [addUser setAddNormalUserDelegate:self];
            [addUser makeReqToAddNormalUserv2:theRequest];
            [addUser release];
            
        }
    }
    
    
    NSMutableDictionary *targetDict=[[NSMutableDictionary alloc]initWithCapacity:5];
    if([sourceDict objectForKey:@"from"]){
        [targetDict setObject:[[sourceDict objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
        [targetDict setObject:[[sourceDict objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
    }
    else if([sourceDict objectForKey:@"FBID"]){
        [targetDict setObject:[sourceDict objectForKey:@"FBID"] forKey:@"userID"];
        [targetDict setObject:[sourceDict objectForKey:@"FBName"] forKey:@"userName"];
    }
    else{
        if([sourceDict objectForKey:@"uid"])
            [targetDict setObject:[sourceDict objectForKey:@"uid"]forKey:@"userID"];
        else if([sourceDict objectForKey:@"linkedIn_id"])
            [targetDict setObject:[sourceDict objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
        [targetDict setObject:[sourceDict objectForKey:@"name"] forKey:@"userName"];
    }
    
    
    [targetDict setObject:[sourceDict objectForKey:@"event_type"] forKey:@"eventName"];
    if([sourceDict objectForKey:@"pic_square"])
        [targetDict setObject:[sourceDict objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
    
    if([sourceDict objectForKey:@"pic_url"])
        [targetDict setObject:[sourceDict objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
    if([sourceDict objectForKey:@"ProfilePicURLToTake"]){
        [targetDict setObject:[sourceDict objectForKey:@"ProfilePicURLToTake"] forKey:@"FBProfilePic"];
    }
    if([sourceDict objectForKey:@"FBUserLocation"])
        [targetDict setObject:[sourceDict objectForKey:@"FBUserLocation"] forKey:@"FBUserLocation"];
    
    return [targetDict autorelease];
}
#pragma mark - Search
- (IBAction)showSearchView:(id)sender {
    
    if([listOfContactsArray count]&& eventGroupNum!=totalGroups){
        
        eventGroupNum=totalGroups;
        
        contactsSearchView.frame=CGRectMake(0, 0, 320, 44);
        if(![contactsSearchView superview]){
            
            [self.view addSubview:contactsSearchView];
        }
        [contactsSearchBar becomeFirstResponder];
        
        pageControlForEventGroups.currentPage=eventGroupNum;
                
        GGLog(@"updated page control number..%d",eventGroupNum);
        CGRect frame = _eventsBgScroll.frame;
        frame.origin.x = frame.size.width *( pageControlForEventGroups.currentPage+1);
        frame.origin.y = 0;
        [_eventsBgScroll scrollRectToVisible:frame animated:YES];
        
        
    }
    
    
    
}

- (IBAction)cancelTheSearch:(id)sender {
    [contactsSearchBar setText:@""];
    [contactsSearchBar resignFirstResponder];
    if([searchContactsArray count])
        [searchContactsArray removeAllObjects];
    
    [(UITableView*)[[_eventsBgScroll subviews] objectAtIndex:[[_eventsBgScroll subviews]count]-1] reloadData];
    [_eventsBgScroll scrollRectToVisible:CGRectMake(320,_eventsBgScroll.frame.origin.y ,320,339) animated:NO];
    pageControlForEventGroups.currentPage=1;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_1{
    
    [contactsSearchBar resignFirstResponder];
      
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_1{
   
    [contactsSearchBar becomeFirstResponder];
   
}
- (void)searchBar:(UISearchBar *)searchBar_1 textDidChange:(NSString *)searchText{
    
    
    if([contactsSearchBar.text isEqualToString:@""]){
        if([searchContactsArray count])
            [searchContactsArray removeAllObjects];
//        isSearchSringAvailable=NO;
//        [self checkTotalNumberOfGroups];
    }
    if([listOfContactsArray count]){
        [searchContactsArray removeAllObjects];
//        isSearchSringAvailable=YES;
//        [self checkTotalNumberOfGroups];
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
                [[event objectForKey:@"name"] compare:contactsSearchBar.text options:NSCaseInsensitiveSearch];
                BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                if(resultName)
                    
                {
                    [searchContactsArray addObject:event];
                    
                    
                }
            }
            
        }
        //int tagNum=[[[_eventsBgScroll subviews] objectAtIndex:[[_eventsBgScroll subviews] count]-1] tag];
        //int tagForHeader=tagNum%10;
        
        if([searchContactsArray count]){
            
            /*if([[_eventsBgScroll viewWithTag:tagForHeader] isKindOfClass:[UIButton class]]){
                [(UIButton*)[_eventsBgScroll viewWithTag:tagForHeader]setTitle:[categoryTitles objectAtIndex:totalGroups-1] forState:UIControlStateNormal];
            }
            else
                [(UILabel*)[_eventsBgScroll viewWithTag:tagForHeader] setText:[categoryTitles objectAtIndex:totalGroups-1]];*/
        }
        else
        {
            searchText=[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(searchText.length>0){
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithCapacity:3];
                [tempDict setObject:@"0" forKey:@"uid"];
                [tempDict setObject:searchText forKey:@"name"];
                [tempDict setObject:@"" forKey:@"event_type"];
                [tempDict setObject:@"Send a gift" forKey:@"FBUserLocation"];
                [searchContactsArray addObject:tempDict];
                [tempDict release];
            }
            
            
            /*if([[_eventsBgScroll viewWithTag:tagForHeader] isKindOfClass:[UIButton class]]){
                [(UIButton*)[_eventsBgScroll viewWithTag:tagForHeader]setTitle:@"" forState:UIControlStateNormal];
            }
            else
                [(UILabel*)[_eventsBgScroll viewWithTag:tagForHeader] setText:@""];*/
        }
    }
    
    if([[_eventsBgScroll subviews]count])
        [(UITableView*)[[_eventsBgScroll subviews] objectAtIndex:[[_eventsBgScroll subviews]count]-1] reloadData];
}

#pragma mark - EventDetails
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    
    if(eventGroupNum==1){
        
        if([allupcomingEvents count]){
            NSMutableDictionary *targetDict;
            targetDict=[self collectDetailsToGetEventDetailsForTheSelectedEvent:[allupcomingEvents objectAtIndex:[sender tag]]];
            [[NSUserDefaults standardUserDefaults]setObject:targetDict forKey:@"SelectedEventDetails"];
        }
        
        
    }
    else if(eventGroupNum==2){
        if([listOfBirthdayEvents count]){
            NSMutableDictionary *targetDict=[self collectDetailsToGetEventDetailsForTheSelectedEvent:[listOfBirthdayEvents objectAtIndex:[sender tag]]];
            [[NSUserDefaults standardUserDefaults]setObject:targetDict forKey:@"SelectedEventDetails"];
        }
        else if([eventsToCelebrateArray count]){
            NSMutableDictionary *targetDict=[self collectDetailsToGetEventDetailsForTheSelectedEvent:[eventsToCelebrateArray objectAtIndex:[sender tag]]];
            [[NSUserDefaults standardUserDefaults]setObject:targetDict forKey:@"SelectedEventDetails"];
        }
    }
    else if(eventGroupNum==3){
        if([eventsToCelebrateArray count]){
            NSMutableDictionary *targetDict=[self collectDetailsToGetEventDetailsForTheSelectedEvent:[eventsToCelebrateArray objectAtIndex:[sender tag]]];
            [[NSUserDefaults standardUserDefaults]setObject:targetDict forKey:@"SelectedEventDetails"];
        }
    }
    
    
        
    [self.navigationController pushViewController:details animated:YES];
    [details release];
    
}
-(NSMutableDictionary*)collectDetailsToGetEventDetailsForTheSelectedEvent:(NSMutableDictionary*)souceDict{
    NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
     
    
    if([[souceDict objectForKey:@"from"]objectForKey:@"id"])
        [tempInfoDict setObject:[[souceDict objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
    else if([souceDict objectForKey:@"uid"]){
        [tempInfoDict setObject:[souceDict objectForKey:@"uid"] forKey:@"userID"];
    }
    else if([souceDict objectForKey:@"FBID"]){
        [tempInfoDict setObject:[souceDict objectForKey:@"FBID"] forKey:@"userID"];
    }
    else if([souceDict objectForKey:@"linkedIn_id"]){
        [tempInfoDict setObject:[souceDict objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
        [tempInfoDict setObject:[souceDict objectForKey:@"update_key"]forKey:@"position_update_key"];
        [tempInfoDict setObject:[souceDict objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
        [tempInfoDict setObject:[souceDict objectForKey:@"companyName"]forKey:@"CompanyName"];
    }
    if([[souceDict objectForKey:@"from"]objectForKey:@"name"])
        [tempInfoDict setObject:[[souceDict objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
    else if([souceDict objectForKey:@"name"])
        [tempInfoDict setObject:[souceDict objectForKey:@"name"] forKey:@"userName"];
    else if([souceDict objectForKey:@"FBName"])
        [tempInfoDict setObject:[souceDict objectForKey:@"FBName"] forKey:@"userName"];
    
    [tempInfoDict setObject:[souceDict objectForKey:@"event_type"] forKey:@"eventName"];
    [tempInfoDict setObject:[souceDict objectForKey:@"event_date"] forKey:@"eventDate"];
    if([souceDict objectForKey:@"FBID"])
        [tempInfoDict setObject:[souceDict objectForKey:@"EventID"] forKey:@"msgID"];
    else if([souceDict objectForKey:@"id"])
        [tempInfoDict setObject:[souceDict objectForKey:@"id"] forKey:@"msgID"];
    
    if([souceDict objectForKey:@"pic_square"])
        [tempInfoDict setObject:[souceDict objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
    return [tempInfoDict autorelease];
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
        
    for (int i = 0; i < [pageControlForEventGroups.subviews count]; i++)
    {
        
        if(i==0 && [listOfContactsArray count]){
            UIImageView* dot = [pageControlForEventGroups.subviews objectAtIndex:i];
           
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 12, 12);
            
            if (i == pageControlForEventGroups.currentPage){
                
                dot.image =[ImageAllocationObject loadImageObjectName:@"searchdotactive2" ofType:@"png"] ;
            }
            else{
                
                dot.image = [ImageAllocationObject loadImageObjectName:@"searchdotinactive2" ofType:@"png"] ;
            }
            
            
        }
        else{
            UIImageView* dot = [pageControlForEventGroups.subviews objectAtIndex:i];
            
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 8, 12);
            if (i == pageControlForEventGroups.currentPage)
                dot.image = pageActiveImage;
            else
                dot.image = pageInactiveImage;
        }
    }
    
    CGRect frame = _eventsBgScroll.frame;
    frame.origin.y = 0;
    if([listOfContactsArray count]){
        //GGLog(@"before...%d,%d",eventGroupNum,pageControlForEventGroups.currentPage);
      
        if(pageControlForEventGroups.currentPage==0){
            eventGroupNum=totalGroups;
            frame.origin.x = frame.size.width * (totalGroups);
            [_eventsBgScroll scrollRectToVisible:frame animated:NO];
            return;
        }
        else
            frame.origin.x = frame.size.width * (pageControlForEventGroups.currentPage);
    }
    else
        frame.origin.x = frame.size.width * (pageControlForEventGroups.currentPage+1);
    frame.origin.y = 0;
    [_eventsBgScroll scrollRectToVisible:frame animated:YES];
    
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //GGLog(@"content offset %f",_eventsBgScroll.contentOffset.x);
    if (_eventsBgScroll.contentOffset.x == 0) {
		// user is scrolling to the left from view 1 to view 4
		// reposition offset to show view 4 that is on the right in the scroll view
		[_eventsBgScroll scrollRectToVisible:CGRectMake(320*totalGroups,_eventsBgScroll.frame.origin.y ,320,339) animated:NO];
	}
	else if (_eventsBgScroll.contentOffset.x == 320*(totalGroups+1)) {
		// user is scrolling to the right from view 4 to view 1
		// reposition offset to show view 1 that is on the left in the scroll view
		[_eventsBgScroll scrollRectToVisible:CGRectMake(320,_eventsBgScroll.frame.origin.y,320,339) animated:NO];
	}
    

}
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    // The key is repositioning without animation
    if([sender isEqual:_eventsBgScroll]){
        CGFloat pageWidth = sender.frame.size.width;
        int pagenum = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth);
        if(pagenum==totalGroups-1 && [listOfContactsArray count]){
            pageControlForEventGroups.currentPage=0;
            eventGroupNum=totalGroups;
        }
        else if(pagenum!=totalGroups-1 && [listOfContactsArray count]){
            pageControlForEventGroups.currentPage = pagenum+1;
            eventGroupNum=pageControlForEventGroups.currentPage;
        }
        else{
            pageControlForEventGroups.currentPage = pagenum;
            eventGroupNum=pageControlForEventGroups.currentPage+1;
        }
        if(eventGroupNum!=totalGroups){
            
            if([contactsSearchView superview]){
                contactsSearchBar.text=@"";
                [contactsSearchBar resignFirstResponder];
                [contactsSearchView removeFromSuperview];
            }
            if([searchContactsArray count]){
                
                [searchContactsArray removeAllObjects];
            }
            if([[_eventsBgScroll subviews]count])
                [(UITableView*)[[_eventsBgScroll subviews] objectAtIndex:[[_eventsBgScroll subviews] count]-1] reloadData];
            
        }
        else if(eventGroupNum==totalGroups && [listOfContactsArray count]){
            contactsSearchView.frame=CGRectMake(0, 0, 320, 44);
            if(![contactsSearchView superview]){
                
                [self.view addSubview:contactsSearchView];
            }
            [contactsSearchBar becomeFirstResponder];
            /*int tagNum=[[[_eventsBgScroll subviews] objectAtIndex:[[_eventsBgScroll subviews] count]-1] tag];
            int tagForHeader=tagNum%10;
            
            if([[_eventsBgScroll viewWithTag:tagForHeader] isKindOfClass:[UIButton class]])
                [(UIButton*)[_eventsBgScroll viewWithTag:tagForHeader] setTitle:@"" forState:UIControlStateNormal];
            else{
                [(UILabel*)[_eventsBgScroll viewWithTag:tagForHeader] setText:@""];
            }*/
            
        }
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
-(void) responseForAddNormalUserv2:(NSMutableString*)userId{
    GGLog(@"received..Id..%@",userId);
    [[NSUserDefaults standardUserDefaults]setObject:userId forKey:@"DummyUserId"];
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
    
}
-(void)logoutFromAllAccounts{
    
    [fb_giftgiv_home setFbGiftGivDelegate:nil];
    [lnkd_giftgiv_home setLnkInGiftGivDelegate:nil];
    
    
    [picturesOperationQueue cancelAllOperations];
    //[eventProfilePicOpQueue cancelAllOperations];
    isCancelledImgOperations=YES;
}
#pragma mark -
- (void)viewDidUnload
{
    
    
    [self setPageControlForEventGroups:nil];
        
    [self setContactsSearchView:nil];
    [self setContactsSearchBar:nil];
    [self setEventsBgScroll:nil];
    [self setSearchBgImg:nil];
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
    
    [pageControlForEventGroups release];
          
    [contactsSearchView release];
    [contactsSearchBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftGivUserIDReceived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoggedOut" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LinkedInLoggedIn" object:nil];
    if([[_eventsBgScroll subviews] count]){
        for(id subView in [_eventsBgScroll subviews]){
            if([subView isKindOfClass:[UILabel class]] || [subView isKindOfClass:[UITableView class]]){
                [subView removeFromSuperview];
            }
        }
    }
    [_eventsBgScroll release];
    [_searchBgImg release];
    [super dealloc];
}

@end
