//
//  HomeScreenVC.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "HomeScreenVC.h"

@implementation HomeScreenVC
@synthesize searchBar;
@synthesize searchBgView;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedGiftGivUserId) name:@"GiftGivUserIDReceived" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventsFromLinkedIn) name:@"LinkedInLoggedIn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutFromAllAccounts) name:@"UserLoggedOut" object:nil];
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{

    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"AllUpcomingEvents"];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    fm=[NSFileManager defaultManager];
    fb_giftgiv_home=[[Facebook_GiftGiv alloc]init];
    fb_giftgiv_home.fbGiftGivDelegate=self;
    
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
    
    
    searchUpcomingEventsArray=[[NSMutableArray alloc]init];
    searchBirthdayEvents=[[NSMutableArray alloc]init];
    searchEventsToCelebrateArray=[[NSMutableArray alloc]init];
    searchContactsArray=[[NSMutableArray alloc]init];
    //searchLkdContactsArray=[[NSMutableArray alloc]init];
    
    
    
    if(currentiOSVersion<6.0){
        pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive" ofType:@"png"] retain];
        pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive" ofType:@"png"] retain];
    }
    
    if(currentiOSVersion>=6.0){
        
        //Enable the below statements when the project is compiled with iOS 6.0 and change the colors for the dots
        [pageControlForEventGroups setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0.5255 green:0.8392 blue:0.83529 alpha:1.0]];
        [pageControlForEventGroups setPageIndicatorTintColor:[UIColor colorWithRed:0.5255 green:0.8392 blue:0.8353 alpha:0.5]];
    }
    //[[NSNotificationCenter defaultCenter] addObserver:picturesOperationQueue selector:@selector(cancelAllOperations) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:picturesOperationQueue selector:@selector(cancelAllOperations) name:UIApplicationWillTerminateNotification object:nil];
    
    [self performSelector:@selector(loadGestures)withObject:nil afterDelay:0.1];
    
    
    eventGroupNum=1;
    pageControlForEventGroups.currentPage=eventGroupNum-1;
    
    
    picturesOperationQueue=[[NSOperationQueue alloc]init];
   
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
-(void)getEventsFromLinkedIn{
    if([lnkd_giftgiv_home isLinkedInAuthorized]){
        [lnkd_giftgiv_home fetchProfile];
        [lnkd_giftgiv_home getMyNetworkUpdatesWithType:@"PRFU"];
        //[lnkd_giftgiv_home setLnkInGiftGivDelegate:self];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"] ){
        for(FBRequest *request in fb_giftgiv_home.fbRequestsArray){
            [request  cancelConnection];
        }
        [fb_giftgiv_home.fbRequestsArray removeAllObjects];
        //[picturesOperationQueue cancelAllOperations];
        //[fm removeItemAtPath:[GetCachesPathForTargetFile cachePathForProfilePicFileName:@""] error:nil];
        if([searchBgView superview]){
            [searchBgView removeFromSuperview];
            isSearchEnabled=NO;
        }
        if([searchBirthdayEvents count])
            [searchBirthdayEvents removeAllObjects];
        if([searchUpcomingEventsArray count])
            [searchUpcomingEventsArray removeAllObjects];
        if([searchEventsToCelebrateArray count])
            [searchEventsToCelebrateArray removeAllObjects];
        if([searchContactsArray count])
            [searchContactsArray removeAllObjects];
        //if([searchLkdContactsArray count])
          //  [searchLkdContactsArray removeAllObjects];
        
        
        if([allupcomingEvents count])
            [allupcomingEvents removeAllObjects];
        if([listOfBirthdayEvents count])
            [listOfBirthdayEvents removeAllObjects];
        if([eventsToCelebrateArray count])
            [eventsToCelebrateArray removeAllObjects];
        if([listOfContactsArray count])
            [listOfContactsArray removeAllObjects];
        //if([linkedInContactsArray count])
          //  [linkedInContactsArray removeAllObjects];
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        [eventsTable reloadData]; 
        if([[fb_giftgiv_home facebook]isSessionValid]){
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]){
                isEventsLoadingFromFB=NO;
                //[self showProgressHUD:self.view withMsg:nil];
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"IsLoadingFromFacebook"];
                [self performSelector:@selector(makeRequestToGetEvents)];
                [self performSelector:@selector(makeRequestToGetFacebookContacts)];
                if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
                    [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
                }
            
            }
            
            else{
                if([CheckNetwork connectedToNetwork]){
                    isEventsLoadingFromFB=YES;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"IsLoadingFromFacebook"];
                    
                    [fb_giftgiv_home getAllFriendsWithTheirDetails];
                    [fb_giftgiv_home listOfBirthdayEvents];
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
        if([lnkd_giftgiv_home isLinkedInAuthorized]){
            [lnkd_giftgiv_home getMyNetworkUpdatesWithType:@"PRFU"];
            //[lnkd_giftgiv_home setLnkInGiftGivDelegate:self];
        }
                
        
    }
    
    [eventsTable reloadData];
    [super viewWillAppear:YES];
}
-(void)receivedGiftGivUserId{
    if(!isFBContactsLoading){
        [self performSelector:@selector(makeRequestToGetFacebookContacts) ];
        isFBContactsLoading=YES;
    }
    if([lnkd_giftgiv_home isLinkedInAuthorized] && !isLnContactsLoading){
        [self performSelector:@selector(makeRequestToGetContactsForLinkedIn) ];
    }
}
#pragma mark -
-(void)makeRequestToGetFacebookContacts{
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        //NSLog(@"gift home id..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetFacebookList>\n<tem:userId>%@</tem:userId>\n<tem:facebookAccessToken>%@</tem:facebookAccessToken>\n</tem:GetFacebookList>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"],[[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
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
    //NSLog(@"Received contacts..%d",friendsCount);
    if(friendsCount){
        //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        
       
        /*if([listOfContactsArray count])
            [listOfContactsArray removeAllObjects];*/
        
        
        for (int i=0;i<friendsCount;i++){
            NSMutableDictionary *contactDict=[[NSMutableDictionary alloc]init];
            [contactDict setObject:[[response objectAtIndex:i]userId] forKey:@"uid"];
            
            [contactDict setObject:[NSString stringWithFormat:@"%@ %@",[[response objectAtIndex:i]firstname],[[response objectAtIndex:i]lastname]] forKey:@"name"];
            
            [contactDict setObject:@"" forKey:@"event_type"];
            //[contactDict setObject:[[response objectAtIndex:i]dob] forKey:@"event_date"];
            if([[response objectAtIndex:i]location]==nil)
                [contactDict setObject:@"" forKey:@"FBUserLocation"];
            else
                [contactDict setObject:[[response objectAtIndex:i]location] forKey:@"FBUserLocation"];
            //[contactDict setObject:@"" forKey:@"ProfilePicture"];
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
        
        /*if([searchBgView superview]){
            
            if([eventTitleLbl.text isEqualToString:events_category_4]){
                if([tempSearchArray count]){
                    [tempSearchArray removeAllObjects];
                    [tempSearchArray release];
                    tempSearchArray=nil;
                }
                tempSearchArray=[[NSMutableArray alloc]initWithArray:listOfContactsArray];
            }
        }*/
        if([globalContactsList count]){
            [globalContactsList removeAllObjects];
            [globalContactsList release];
            globalContactsList=nil;
        }
        globalContactsList=[[NSMutableArray alloc] initWithArray:listOfContactsArray];
                       
        int facebookContactsCount=[globalContactsList count];
        
        for(int i=0;i<facebookContactsCount;i++){
            
            NSString *urlStr_id=@"";
            if([[globalContactsList objectAtIndex:i]objectForKey:@"uid"])
                urlStr_id=[[globalContactsList objectAtIndex:i]objectForKey:@"uid"];              
                
                
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
        //NSLog(@"gift home id..%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyGiftGivUserId"]);
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetEvents>\n<tem:userId>%@</tem:userId>\n<tem:typeEventList>Display</tem:typeEventList>\n</tem:GetEvents>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"events request..%@",soapRequestString);
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
    /*if([allupcomingEvents count])
        [allupcomingEvents removeAllObjects];
    if([listOfBirthdayEvents count])
        [listOfBirthdayEvents removeAllObjects];
   
    if([eventsToCelebrateArray count])
        [eventsToCelebrateArray removeAllObjects];*/
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:eventsCount];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    if(eventsCount){
        
        //[self stopHUD];
        
        
        for (int i=0;i<eventsCount;i++){
            NSMutableDictionary *eventDict=[[NSMutableDictionary alloc]init];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_FriendId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"uid"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_EventId]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"id"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_Name]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
                        
            [eventDict setObject:[[[allEvents objectAtIndex:i]eventName]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_type"];
            [eventDict setObject:[[[[[allEvents objectAtIndex:i]eventdate]componentsSeparatedByString:@"T"]objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"event_date"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]isEventFromQuery]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"isEventFromQuery"];
            //[eventDict setObject:@"" forKey:@"ProfilePicture"];
            [eventDict setObject:[[[allEvents objectAtIndex:i]fb_Picture]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"pic_square"];
            
            NSString *eventType=[[[allEvents objectAtIndex:i]eventType]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
           
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
        
        //NSLog(@"%@",allupcomingEvents);
        [self performSelector:@selector(checkTotalNumberOfGroups)];
       
        
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
            //[[Facebook_GiftGiv sharedSingleton]setFbGiftGivDelegate:self];
            [fb_giftgiv_home getAllFriendsWithTheirDetails];
            [fb_giftgiv_home listOfBirthdayEvents];
            
        }
    }
}
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
    
    //[self performSelector:@selector(updateNextColumnTitle)];
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
    ////[events_2_Table reloadData];
}
-(void)checkTotalNumberOfGroups{
    totalGroups=0;
    if([categoryTitles count])
        [categoryTitles removeAllObjects];
    
    if([searchBgView superview]){
        if([searchUpcomingEventsArray count]){
            
            [categoryTitles addObject:events_category_1];
            totalGroups++;
        }
        if([searchBirthdayEvents count]){
            
            [categoryTitles addObject:events_category_2];
            totalGroups++;
        }
        
        if([searchEventsToCelebrateArray count]){
            [categoryTitles addObject:events_category_3];
            totalGroups++;
        }
        if([searchContactsArray count]){
            [categoryTitles addObject:events_category_4];
            totalGroups++;
        }
    
    }
    else{
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
            if(isSearchEnabled)
                return [searchUpcomingEventsArray count];
            return [allupcomingEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_2]){
            if(isSearchEnabled)
                return [searchBirthdayEvents count];
            return [listOfBirthdayEvents count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_3]){
            if(isSearchEnabled)
                return [searchEventsToCelebrateArray count];
            return [eventsToCelebrateArray count];
            
        }
        if([eventTitleLbl.text isEqualToString:events_category_4] ||[eventTitleLbl.text isEqualToString:@""]){
            //if(isSearchEnabled)
                return [searchContactsArray count];
            //return [listOfContactsArray count];
            
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
            if(isSearchEnabled){
                if([searchUpcomingEventsArray count]){
                    //NSLog(@"upcoming..%@",allupcomingEvents);
                    [self loadEventsData:searchUpcomingEventsArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                }
            }
            else{
                if([allupcomingEvents count]){
                    //NSLog(@"upcoming..%@",allupcomingEvents);
                    [self loadEventsData:allupcomingEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                }
            }
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
            if(isSearchEnabled){
                if([searchBirthdayEvents count]){
                    //NSLog(@"upcoming..%@",allupcomingEvents);
                    [self loadEventsData:searchBirthdayEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                }
            }
            else{
                if([listOfBirthdayEvents count]){
                    //NSLog(@"list of birthdays..%@",listOfBirthdayEvents);
                    [self loadEventsData:listOfBirthdayEvents withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                    
                }
            }
            
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
            
            if(isSearchEnabled){
                if([searchEventsToCelebrateArray count]){
                    //NSLog(@"upcoming..%@",allupcomingEvents);
                    [self loadEventsData:searchEventsToCelebrateArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                }
            }
            else{
                if([eventsToCelebrateArray count]){
                    //NSLog(@"list of anniversaries..%@",anniversaryEvents);
                    [self loadEventsData:eventsToCelebrateArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                    
                }
            }
            
            
            
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4] || [eventTitleLbl.text isEqualToString:@""]){
            //if(isSearchEnabled){
                if([searchContactsArray count]){
                    //NSLog(@"upcoming..%@",allupcomingEvents);
                    [self loadEventsData:searchContactsArray withCell:cell inTable:eventsTable forIndexPath:indexPath];
                    
                }
            //}
            else{
                if([listOfContactsArray count]){
                    //NSLog(@"list of newJobEvents..%@",newJobEvents);
                    [self loadEventsData:listOfContactsArray withCell:cell inTable:eventsTable forIndexPath:indexPath];   
                }
            }
            
            
        }
        
        if([cell.dateLbl.text isEqualToString:@""]){
            cell.eventNameLbl.frame=CGRectMake(cell.eventNameLbl.frame.origin.x,cell.eventNameLbl.frame.origin.y,196,cell.eventNameLbl.frame.size.height);
        }
        else{
            //Dynamic[fit] label width respected to the size of the text
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
        NSString *dateDisplay=[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:[sourceEventsDict  objectForKey:@"event_date"]];//[self updatedDateToBeDisplayedForTheEvent:[[congratsEvents objectAtIndex:indexPath.row] objectForKey:@"event_date"]];
        if([dateDisplay isEqualToString:@"Today"]||[dateDisplay isEqualToString:@"Yesterday"]||[dateDisplay isEqualToString:@"Tomorrow"]||[dateDisplay isEqualToString:@"Recent"]){
            cell.dateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
            //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica-Bold" size:7.0];
        }
        else{
            //cell.dateLbl.font=[UIFont fontWithName:@"Helvetica" size:7.0];
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
            
            if(isSearchEnabled){
                if([[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
                    [tempInfoDict setObject:[[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                    [tempInfoDict setObject:[[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
                }
                else if([[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                    [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                    [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
                }
                else{
                    if([[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"uid"])
                        [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                    else if([[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                        [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                    [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
                }
                
                
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
                               
                if([[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                    [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
                if([[searchUpcomingEventsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                    [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            }
            else{
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
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
            
        }
        
        else if([eventTitleLbl.text isEqualToString:events_category_2]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            
            if(isSearchEnabled){
                if([[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]){
                    [tempInfoDict setObject:[[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                    [tempInfoDict setObject:[[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
                }
                else if([[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                    [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                    [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
                }
                else{
                    if([[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"uid"])
                        [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                    else if([[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                        [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                    
                    [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
                }
                
                
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
                if([[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                    [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
                
                if([[searchBirthdayEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                    [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            }
            else{
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
            
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        else if([eventTitleLbl.text isEqualToString:events_category_3]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            
            if(isSearchEnabled){
                if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
                    [tempInfoDict setObject:[[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                    [tempInfoDict setObject:[[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
                }
                else if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBID"]){
                    [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBID"] forKey:@"userID"];
                    [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"FBName"] forKey:@"userName"];
                }
                else{
                    if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"uid"])
                        [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                    else if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                        [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                    
                    [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
                }
                
                
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
                
                if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"])
                    [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
                if([[searchEventsToCelebrateArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                    [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            }
            else{
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
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
        else if([eventTitleLbl.text isEqualToString:events_category_4] || [eventTitleLbl.text isEqualToString:@""]){
            NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
            
            //if(isSearchEnabled){
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
            //}
            
            /*else{
                if([[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]){
                    [tempInfoDict setObject:[[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
                    [tempInfoDict setObject:[[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
                }
                else{
                    if([[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"uid"])
                        [tempInfoDict setObject:[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"uid"]forKey:@"userID"];
                    else if([[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"])
                        [tempInfoDict setObject:[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                    
                    [tempInfoDict setObject:[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"userName"];
                }
                
                
                [tempInfoDict setObject:[[listOfContactsArray objectAtIndex:indexPath.row] objectForKey:@"event_type"] forKey:@"eventName"];
                if([[listOfContactsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"])
                    [tempInfoDict setObject:[[listOfContactsArray objectAtIndex:indexPath.row]objectForKey:@"pic_url"] forKey:@"linkedIn_pic_url"];
            }*/
            
            [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
            
            [tempInfoDict release];
        }
                
        [self.navigationController pushViewController:giftOptions animated:YES];
        [giftOptions release];
    }
    
    
    
}

#pragma mark -
- (IBAction)showSearchView:(id)sender {
    /*searchBgView.frame=CGRectMake(0, 0, 320, 44);
    if(![searchBgView superview]){
        
        [self.view addSubview:searchBgView];
    }
    [searchBar becomeFirstResponder];*/
    if([listOfContactsArray count]&& eventGroupNum!=totalGroups){
        
        eventGroupNum=totalGroups;
        pageControlForEventGroups.currentPage=eventGroupNum-1;
        [self swiping:1];
    }
    
    
    
}


- (IBAction)searchCancelAction:(id)sender {
    [searchBar resignFirstResponder];
    searchBar.text=@"";
    [searchBgView removeFromSuperview];
    isSearchEnabled=NO;
    [self performSelector:@selector(checkTotalNumberOfGroups)];
    
    [eventsTable reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_1{
   
    if([searchBar_1 isEqual:searchBar]){
        [searchBar resignFirstResponder];
        searchBgView.frame=CGRectMake(0, 0, 320, 44);
        //[self performSelector:@selector(checkTotalNumberOfGroups)];
        //[eventsTable reloadData];
    }
    else{
        [contactsSearchBar resignFirstResponder];
        if(![searchContactsArray count]){
            eventTitleLbl.text=@"No results found";
        }
    }
   
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_1{
    if([searchBar_1 isEqual:searchBar]){
        searchBgView.frame=CGRectMake(0, 0, 320, 44);
        [searchBar becomeFirstResponder];
    }
    else{
        [contactsSearchBar becomeFirstResponder];
    }
}
- (void)searchBar:(UISearchBar *)searchBar_1 textDidChange:(NSString *)searchText{
    
    if([searchBar_1 isEqual:searchBar]){
        isSearchEnabled=YES;
        if([searchText isEqualToString:@""]){
            isSearchEnabled=NO;
            //[self performSelector:@selector(reloadTheEventsScreen)];
        }
        else{
            //if([tempSearchArray count]){
            if([allupcomingEvents count]){
                [searchUpcomingEventsArray removeAllObjects];
                for (NSMutableDictionary *event in allupcomingEvents)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                        
                        [[[event objectForKey:@"from"] objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchUpcomingEventsArray addObject:event];
                            
                        }
                    }
                    else{
                        //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                        [[event objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchUpcomingEventsArray addObject:event];
                            
                            
                        }
                    }  
                    
                }
            }
            
            if([listOfBirthdayEvents count]){
                [searchBirthdayEvents removeAllObjects];
                for (NSMutableDictionary *event in listOfBirthdayEvents)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                        
                        [[[event objectForKey:@"from"] objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchBirthdayEvents addObject:event];
                            
                        }
                    }
                    else{
                        //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                        [[event objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchBirthdayEvents addObject:event];
                            
                            
                        }
                    }  
                    
                }
            }
            
            if([eventsToCelebrateArray count]){
                [searchEventsToCelebrateArray removeAllObjects];
                for (NSMutableDictionary *event in eventsToCelebrateArray)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                        
                        [[[event objectForKey:@"from"] objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchEventsToCelebrateArray addObject:event];
                            
                        }
                    }
                    else{
                        //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                        [[event objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchEventsToCelebrateArray addObject:event];
                            
                            
                        }
                    }  
                    
                }
            }
            
            if([listOfContactsArray count]){
                [searchContactsArray removeAllObjects];
                for (NSMutableDictionary *event in listOfContactsArray)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                        
                        [[[event objectForKey:@"from"] objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchContactsArray addObject:event];
                            
                        }
                    }
                    else{
                        //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                        [[event objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchContactsArray addObject:event];
                            
                            
                        }
                    }  
                    
                }
            }
            
            /*if([linkedInContactsArray count]){
                [searchLkdContactsArray removeAllObjects];
                
                for (NSMutableDictionary *event in linkedInContactsArray)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(SELF contains[cd] %@)", searchBar.text];
                    
                    if([event objectForKey:@"from"]){
                        
                        [[[event objectForKey:@"from"] objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[[event objectForKey:@"from"] objectForKey:@"name"]];
                        
                        if(resultName)
                        {
                            [searchLkdContactsArray addObject:event];
                            
                        }
                    }
                    else{
                        //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
                        [[event objectForKey:@"name"] compare:searchBar.text options:NSCaseInsensitiveSearch];
                        BOOL resultName = [predicate evaluateWithObject:[event objectForKey:@"name"]];
                        if(resultName)
                            
                        {
                            [searchLkdContactsArray addObject:event];
                            
                            
                        }
                    }  
                    
                }
                
                
            }*/
            
            
            
            //}
            
        }
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
    }
    else{
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
                    //NSLog(@"name.. %@,%@",[event objectForKey:@"name"],searchText);
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
    }
    [eventsTable reloadData];
}

#pragma mark -
-(void)eventDetailsAction:(id)sender{
    
    EventDetailsVC *details=[[EventDetailsVC alloc]initWithNibName:@"EventDetailsVC" bundle:nil];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedEventDetails"];
    }
    
    if([eventTitleLbl.text isEqualToString:events_category_1]){
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:5];
        
        if(isSearchEnabled){
            if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
                details.isPhotoTagged=YES;
            }
            else
                details.isPhotoTagged=NO;
            
            
            
            if([[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
                [tempInfoDict setObject:[[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"FBID"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"FBID"] forKey:@"userID"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"uid"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"uid"]forKey:@"userID"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
            }
            
            if([[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
                [tempInfoDict setObject:[[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"FBName"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"name"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
            
            [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
            [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
            if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"EventID"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
            else if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"id"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
            //NSLog(@" temp dict..%@",tempInfoDict);
            if([[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[searchUpcomingEventsArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        }
        
        else{
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
            //NSLog(@" temp dict..%@",tempInfoDict);
            if([[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[allupcomingEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        }
        
        
        
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        //details.basicInfoForMsg=tempInfoDict;
        [tempInfoDict release];
        
    }
    
    else if([eventTitleLbl.text isEqualToString:events_category_2]){
        
        NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        if(isSearchEnabled){
            if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
                details.isPhotoTagged=YES;
            }
            else
                details.isPhotoTagged=NO;
            
            
            
            if([[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
                [tempInfoDict setObject:[[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"] forKey:@"userID"];
            }
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"]){
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
            }
            
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
            }
            
            if([[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
                [tempInfoDict setObject:[[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"])
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"])
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
            
            [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
            [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
            
            if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"FBID"])
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"]; 
            else if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"id"])
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];   
            if([[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[searchBirthdayEvents objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        }
        
        else{
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
        
        
        [[NSUserDefaults standardUserDefaults]setObject:tempInfoDict forKey:@"SelectedEventDetails"];
        
        [tempInfoDict release];
        
    }
    else if([eventTitleLbl.text isEqualToString:events_category_3]){
         NSMutableDictionary *tempInfoDict=[[NSMutableDictionary alloc]initWithCapacity:4];
        if(isSearchEnabled){
            if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
                details.isPhotoTagged=YES;
            }
            else
                details.isPhotoTagged=NO;
            
            
            if([[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"])
                [tempInfoDict setObject:[[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"id"] forKey:@"userID"];
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"uid"]){
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"uid"] forKey:@"userID"];
            }
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"]){
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"] forKey:@"userID"];
            }
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]){
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"linkedIn_id"]forKey:@"linkedIn_userID"];
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"update_key"]forKey:@"position_update_key"];
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"positionTitle"]forKey:@"PositionTitle"];
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"companyName"]forKey:@"CompanyName"];
            }
            if([[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"])
                [tempInfoDict setObject:[[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"from"]objectForKey:@"name"] forKey:@"userName"];
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"name"])
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"name"] forKey:@"userName"];
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBName"])
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBName"] forKey:@"userName"];
            
            [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"event_type"] forKey:@"eventName"];
            [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"event_date"] forKey:@"eventDate"];
            
            if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"FBID"])
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"EventID"] forKey:@"msgID"];
            else if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"id"])
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"id"] forKey:@"msgID"];
            
            if([[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"])
                [tempInfoDict setObject:[[searchEventsToCelebrateArray objectAtIndex:[sender tag]] objectForKey:@"pic_square"] forKey:@"FBProfilePic"];
        }
        else{
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
        
    }
        
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
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
            //[tempDict setObject:@"" forKey:@"ProfilePicture"];
            [listOfBirthdayEvents replaceObjectAtIndex:i withObject:tempDict];
        }
        [allupcomingEvents addObjectsFromArray:listOfBirthdayEvents];
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        
        
        //[self performSelector:@selector(updateNextColumnTitle)];
        
        
        [eventsTable reloadData];
       
        birthdayEventUserNoToAddAsUser=1;
       
        
        [self storeAllupcomingsForSuccessScreen];
        
        [self makeRequestToLoadImagesUsingOperations:listOfBirthdayEvents];
        
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
        //NSLog(@"%@",soapRequestString);
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
    NSLog(@"facebook did request failed..");
    //AlertWithMessageAndDelegate(@"Oops", @"facebook request failed", nil);
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
            //NSLog(@"same..");
            return ;
        }
        else{
            //NSLog(@"%@,%@,not same..",[NSString stringWithFormat:@"%@",existEventUserIDStr],[NSString stringWithFormat:@"%@",eventDetailsUserIDStr]);
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
    
    [self makeRequestToAddUserForFB:tempDict];
    [tempDict release];
    //[eventDetails setObject:@"" forKey:@"ProfilePicture"];
    [listOfBirthdayEvents addObject:eventDetails];
    [allupcomingEvents addObject:eventDetails];
    [self performSelector:@selector(checkTotalNumberOfGroups)];
    
    //[self performSelector:@selector(updateNextColumnTitle)];
    
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
    
        
    /*for(NSMutableDictionary *eventDict in tempArray ){
        if([[eventDict objectForKey:@"ProfilePicture"] isKindOfClass:[UIImage class]])
            [eventDict setObject:UIImagePNGRepresentation([eventDict objectForKey:@"ProfilePicture"])  forKey:@"ProfilePicture"];
        else if(![[eventDict objectForKey:@"ProfilePicture"] isKindOfClass:[NSData class]])
            [eventDict setObject:@"" forKey:@"ProfilePicture"];
    }*/
   
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"AllUpcomingEvents"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AllUpcomingEvents"];
    }
    [[NSUserDefaults standardUserDefaults]setObject:tempArray forKey:@"AllUpcomingEvents"];
    
    [tempArray release];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[allupcomingEvents count]];
    //[self makeRequestToLoadImagesUsingOperations];
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
        //[eventDetails setObject:@"new job" forKey:@"event_type"];
        //[eventDetails setObject:@"" forKey:@"ProfilePicture"];
        
        
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
        
        //[eventDetails setObject:@"" forKey:@"ProfilePicture"];
        
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
        
        [self makeRequestToAddUserForFB:tempDict];
        [tempDict release];
        
        
        [eventsToCelebrateArray addObject:eventDetails];
        [allupcomingEvents addObject:eventDetails];
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        //[self performSelector:@selector(updateNextColumnTitle)];
        
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
        //[eventDetails setObject:@"" forKey:@"ProfilePicture"];
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
        
        [self makeRequestToAddUserForFB:tempDict];
        [tempDict release];
        
        
        [self performSelector:@selector(checkTotalNumberOfGroups)];
        //[self performSelector:@selector(updateNextColumnTitle)];
        
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
            //facebook contacts
        case 4:
        {
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [listOfContactsArray replaceObjectsInRange:NSMakeRange(0, [listOfContactsArray count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]]];
            [nameSortDescriptor release];
        }
            
            break;
            //linkedIn contacts
        /*case 5:
            [linkedInContactsArray replaceObjectsInRange:NSMakeRange(0, [linkedInContactsArray count]) withObjectsFromArray:[listOfEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            break;
          */
    }
    
    
    [sortDescriptor release];
    
    //[eventsTable reloadData];
    ////[events_2_Table reloadData];
	
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
    for (NSDictionary *existEvents in eventsToCelebrateArray){
        NSString *existEventUserIDStr=[NSString stringWithFormat:@"%@",[existEvents objectForKey:@"linkedIn_id"]];
        NSString *eventDetailsUserIDStr=[NSString stringWithFormat:@"%@",[linkedInDict objectForKey:@"id"]];
        if([existEventUserIDStr isEqualToString:eventDetailsUserIDStr])
            return YES;
    }
    return NO;
}
#pragma mark - LinkedIn delegate
/*- (void)linkedInDidLoggedOut{
    //if(![[LinkedIn_GiftGiv sharedSingleton] isLinkedInAuthorized]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    //}
}*/
- (void)linkedInLoggedInWithUserDetails:(NSMutableDictionary*)userDetails{
            
    [[NSUserDefaults standardUserDefaults]setObject:userDetails forKey:@"MyLinkedInDetails"];
    
    
    if([CheckNetwork connectedToNetwork]){
        
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>%@</tem:fbId>\n<tem:lid>%@</tem:lid>\n<tem:lnAccessToken>%@</tem:lnAccessToken>\n<tem:lnSecretKey>%@</tem:lnSecretKey>\n<tem:lnTokenVerifier>%@</tem:lnTokenVerifier>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>%@/picture</tem:profilePictureUrl>\n</tem:AddUser>",[[[NSUserDefaults standardUserDefaults]objectForKey:@"MyFBDetails"] objectForKey:@"uid"],[userDetails objectForKey:@"id"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInAccessToken"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInSecretKey"],[[NSUserDefaults standardUserDefaults]objectForKey:@"LinkedInOauthVerifier"],[userDetails objectForKey:@"first-name"],[userDetails objectForKey:@"last-name"],[userDetails objectForKey:@"picture-url"]];
        [self performSelector:@selector(makeRequestToAddUserForLinkedIn:)withObject:soapmsgFormat];
        
    }
}
-(void)makeRequestToAddUserForLinkedIn:(NSString*)requestString{
    NSString *soapRequestString=SOAPRequestMsg(requestString);
    
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
        //[linkedInEvent setObject:@"" forKey:@"ProfilePicture"];
        
        
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
        
        if([CheckNetwork connectedToNetwork]){
            
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:AddUser>\n<tem:fbId>null</tem:fbId>\n<tem:lid>%@</tem:lid>\n<tem:lnAccessToken>null</tem:lnAccessToken>\n<tem:lnSecretKey>null</tem:lnSecretKey>\n<tem:lnTokenVerifier>null</tem:lnTokenVerifier>\n<tem:firstName>%@</tem:firstName>\n<tem:lastName>%@</tem:lastName>\n<tem:profilePictureUrl>%@/picture</tem:profilePictureUrl>\n</tem:AddUser>",[result objectForKey:@"id"],[result objectForKey:@"first-name"],[result objectForKey:@"last-name"],[result objectForKey:@"picture-url"]];
            [self performSelector:@selector(makeRequestToAddUserForLinkedIn:)withObject:soapmsgFormat];
            
        }

    }
    
}

#pragma mark - Add User Request delegate
-(void) responseForLnAddUser:(NSMutableDictionary*)response{
    
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
            //NSLog(@"%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetLinkedInList"];
            
            LinkedInContactsRequest *lnContacts=[[LinkedInContactsRequest alloc]init];
            [lnContacts setLnContactsDelegate:self];
            [lnContacts getLnContactsForRequest:theRequest];
            [lnContacts release];
            
        }
    }
}
-(void) responseForAddUser:(NSMutableDictionary*)response{
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
    //[self setEventTitle_2_Lbl:nil];
    //[self setEvents_2_Table:nil];
    [self setSearchBgView:nil];
    [self setSearchBar:nil];
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
    //[[NSNotificationCenter defaultCenter] removeObserver:picturesOperationQueue name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [picturesOperationQueue cancelAllOperations];
    [picturesOperationQueue release];
   
    //[fm removeItemAtPath:[GetCachesPathForTargetFile cachePathForProfilePicFileName:@""] error:nil];
    
    dispatch_release(ImageLoader_Q);
    dispatch_release(ImageLoader_Q_ForEvents);
    [fb_giftgiv_home setFbGiftGivDelegate:nil];
    [lnkd_giftgiv_home setLnkInGiftGivDelegate:nil];
    [searchBirthdayEvents release];
    [searchUpcomingEventsArray release];
    //[searchLkdContactsArray release];
    [searchContactsArray release];
    [searchEventsToCelebrateArray release];
    //[fb_giftgiv_home release];
    if(currentiOSVersion<6.0){
        [pageActiveImage release];
        [pageInactiveImage release]; 
    }
    if([globalContactsList count]){
        [globalContactsList removeAllObjects];
        [globalContactsList release];
        globalContactsList=nil;
    }
    [listOfBirthdayEvents release];
    [eventsToCelebrateArray release];
    [listOfContactsArray release];
    //[linkedInContactsArray release];
    [allupcomingEvents release];
    
    [categoryTitles release];
    [eventsBgView release];
    [eventTitleLbl release];
    [pageControlForEventGroups release];
    [eventsTable release];
    //[eventTitle_2_Lbl release];
   // [events_2_Table release];
    [searchBgView release];
    [searchBar release];
    [contactsSearchView release];
    [contactsSearchBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftGivUserIDReceived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoggedOut" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LinkedInLoggedIn" object:nil];
    [super dealloc];
}

@end
