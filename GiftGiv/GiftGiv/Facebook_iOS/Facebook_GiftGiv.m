//
//  Facebook_GiftGiv.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "Facebook_GiftGiv.h"
#import "Constants.h"

@interface Facebook_GiftGiv()

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;

@end



@implementation Facebook_GiftGiv 

@synthesize facebook,fbGiftGivDelegate,fbRequestsArray;

//static Facebook_GiftGiv *sharedInstance = nil;
static NSDateFormatter *standardDateFormatter = nil;

#pragma mark Facebook_GiftGiv class methods
/*+ (Facebook_GiftGiv *)sharedSingleton
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[Facebook_GiftGiv alloc] init];
            
        }
        
        return sharedInstance;// Facebook_GiftGiv singleton
    } 
}*/


- (Facebook *)facebook{
    if (facebook==nil) {
        facebook = [[Facebook alloc] initWithAppId:KFacebookAppId andDelegate:self];
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
        NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
        if (fbAccessToken && fbExpirationDateKey) {
            self.facebook.accessToken = fbAccessToken;
            self.facebook.expirationDate = fbExpirationDateKey;
            
            if([fbRequestsArray count]){
                for(FBRequest *request in fbRequestsArray){
                    [request  cancelConnection];
                }
                [fbRequestsArray removeAllObjects];
            }
            
            
            //NSLog(@"AccessToken= %@ \n ExpirationDate= %@", facebook.accessToken, facebook.expirationDate);
            fbRequestsArray=[[NSMutableArray alloc]init];
        }
    }
    return facebook;
}
- (void) releaseFacebook{
    if(facebook!=nil){
        if([fbRequestsArray count]){
            for(FBRequest *request in fbRequestsArray){
                [request  cancelConnection];
            }
            [fbRequestsArray removeAllObjects];
        }
        if(fbRequestsArray!=nil){
            [fbRequestsArray release];
            fbRequestsArray=nil;
        }
        self.facebook.accessToken=nil;
        self.facebook.expirationDate=nil;
        [facebook release];
        facebook=nil;
    }
}
#pragma mark -
#pragma mark Login helper

-(void)authorizeOurAppWithFacebook{
    
    // Check and retrieve authorization information
    
    NSString *fbAccessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
    NSDate *fbExpirationDateKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBExpirationDateKey"];
    
    if (fbAccessToken && fbExpirationDateKey)
    {
        self.facebook.accessToken = fbAccessToken;
        self.facebook.expirationDate = fbExpirationDateKey;
    }
    
    if (![facebook isSessionValid]) {
        [self.facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"user_birthday",@"friends_status",@"friends_photos",@"friends_birthday",nil]]; //email to get user's mail address
        
        
    }
}

-(void)logoutOfFacebook{
    [[self facebook] logout];
}
-(void)extendAccessTokenIfNeeded
{
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    [[self facebook] extendAccessTokenIfNeeded];
}
#pragma mark - Facebook Delegate methodes
/**
 * Called when the user successfully logged in.
 */

- (void)fbDidLogin {
    [self storeAuthData:[[self facebook] accessToken] expiresAt:[[self facebook] expirationDate]];
    [fbGiftGivDelegate facebookLoggedIn];
    [self apiFQLIMe];
    
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
    NSLog(@"fbDidNotLogin");
    [fbGiftGivDelegate facebookDidCancelledLogin];
    
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{
    [self storeAuthData:accessToken expiresAt:expiresAt];
}
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"FBAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults]setObject:expiresAt forKey:@"FBExpirationDateKey"];
    
    //NSLog(@"%@",[defaults objectForKey:@"FBAccessTokenKey"]);
    //[defaults synchronize];
}
/**
 * Called when the user logged out.
 */
- (void)fbDidLogout{
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    
    // Remove saved authorization information if it exists
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenKey"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBExpirationDateKey"];
        //[defaults synchronize];
        
        for(FBRequest *request in fbRequestsArray){
            [request  cancelConnection];
        }
        
    }
    
    if(birthdaySearchStrings!=nil){
        [birthdaySearchStrings removeAllObjects];
        birthdaySearchStrings=nil;
    }
    if(anniversarySearchStrings!=nil){
        [anniversarySearchStrings removeAllObjects];
        anniversarySearchStrings=nil;
    }
    if(newJobSearchStrings!=nil){
        [newJobSearchStrings removeAllObjects];
        newJobSearchStrings=nil;
    }
    if(congratsSearchStrings!=nil){
        [congratsSearchStrings removeAllObjects];
        congratsSearchStrings=nil;
    }
    if(friendUserIds!=nil){
        [friendUserIds removeAllObjects];
        friendUserIds=nil;
    }
    
    [fbGiftGivDelegate facebookDidLoggedOut];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated{
    //[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"FacebookSessionExpired", @"") message:NSLocalizedString(@"YourSessionExpired", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    AlertWithMessageAndDelegate(NSLocalizedString(@"FacebookSessionExpired", @""), NSLocalizedString(@"YourSessionExpired", @""),nil);
    [self fbDidLogout];
}

#pragma mark - FQLs and GraphAPI

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid,first_name,last_name,birthday_date FROM user WHERE uid=me()", @"query",
                                   nil];
    currentAPICall=kAPIGetUserDetails;
    FBRequest *aboutMeReq=[[self facebook] requestWithMethodName:@"fql.query"
                                                andParams:params
                                            andHttpMethod:@"POST"
                                              andDelegate:self];
    [fbRequestsArray addObject:aboutMeReq];
}
- (void)listOfBirthdayEvents{
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        currentAPICall=kAPIGetBirthdayEvents;
        
        //Date should be in MM/dd/yyyy formate only for facebook queries
        NSString *startDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:-4]; //previous 3 days as it like windows phone logic
        NSString *endDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:14]; //next 15 days as it like windows phone logic
        
        
        NSString *getBirthdaysQuery=[NSString stringWithFormat:@"SELECT uid, name, first_name, last_name, birthday_date, pic_square FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()) AND strlen(birthday_date) != 0 AND birthday_date >= \"%@\" AND birthday_date <= \"%@\" ORDER BY birthday_date ASC",startDate,endDate];
        //NSLog(@"%@",getBirthdaysQuery);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getBirthdaysQuery, @"query",
                                       nil];
        
        FBRequest *birthdaysReq=[[self facebook] requestWithMethodName:@"fql.query"
                                                      andParams:params
                                                  andHttpMethod:@"POST"
                                                    andDelegate:self];
        [fbRequestsArray addObject:birthdaysReq];
    }
    
}
-(NSString*)getNewDateForCurrentDateByAddingTimeIntervalInDays:(int)daysToAdd{
    NSDate *now=[NSDate date];    
    // set up date components
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:daysToAdd];
    
    // create a calendar
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    NSDate *updatedDate = [gregorian dateByAddingComponents:components toDate:now options:0];
    //NSLog(@"%@",updatedDate);
    if(standardDateFormatter==nil){
        standardDateFormatter=[[NSDateFormatter alloc]init];  
        [standardDateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    
    NSString *convertedToString=[standardDateFormatter stringFromDate:updatedDate];
    
    return convertedToString;
}

- (void)getAllFriendsWithTheirDetails{
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        currentAPICall=kAPIGetAllFriends;
        
        
        NSString *getFriendsQuery=@"SELECT uid, name, first_name, last_name, birthday_date, pic_square from user where uid in (SELECT uid2 FROM friend WHERE uid1=me())";
        //NSLog(@"%@",getFriendsQuery);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getFriendsQuery, @"query",
                                       nil];
        
        FBRequest *friendsReq=[[self facebook] requestWithMethodName:@"fql.query"
                                                    andParams:params
                                                andHttpMethod:@"POST"
                                                  andDelegate:self];
        [fbRequestsArray addObject:friendsReq];
    }
    
}
- (void)getEventDetails:(NSString*)statusID{
    
    getDetailedEventReq=[[self facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@",statusID] andDelegate:self];
}
#pragma mark - FBRequestDelegate methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error=%@",error);
    [fbGiftGivDelegate facebookDidRequestFailed];
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        
        if([request isEqual:getDetailedEventReq]){
            
            if([result isKindOfClass:[NSDictionary class]]){
                [fbGiftGivDelegate receivedDetailedEventInfo:(NSMutableDictionary*)result];
            }
        }
        
        switch (currentAPICall) {
                
            case kAPIGetUserDetails:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; 
                if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
                    result = [result objectAtIndex:0];
                }
                [fbGiftGivDelegate facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)result];
                break;
            case kAPIGetBirthdayEvents:
                if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                    return;
                
                if([result isKindOfClass:[NSArray class]])
                [fbGiftGivDelegate receivedBirthDayEvents:(NSMutableArray *)result];
                
                break;
                //Received all friends details
            case kAPIGetAllFriends:
                
                /*if(fbOperationQueue)
                    [fbOperationQueue cancelAllOperations];
                else
                    fbOperationQueue=[[NSOperationQueue alloc]init];*/
                
                [fbRequestsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    FBRequest*reqObj= (FBRequest*)obj ;
                    [reqObj.connection cancel];
                }];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(friendUserIds!=nil && [friendUserIds count]){
                    [friendUserIds removeAllObjects];
                    [friendUserIds release];
                    friendUserIds=nil;
                }
                friendUserIds=[[NSMutableDictionary alloc]init];
                
                if(newJobSearchStrings==nil){
                    newJobSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats", @"all the best", @"good luck", @"congratulations", @"got job", @"got new job", @"new job" ,nil];/*@"congrats",@"all the best", @"good luck", @"congratulations", @"got job", @"got new job", @"new job",nil];*/
                }
                if(anniversarySearchStrings==nil){
                    anniversarySearchStrings=[[NSMutableArray alloc]initWithObjects:@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary" ,nil];/*@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary",nil]*/;
                }
                if(congratsSearchStrings==nil){
                    congratsSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats", @"all the best", @"good luck", @"congratulations",nil];/*@"congrats", @"all the best", @"good luck", @"congratulations",nil];*/
                }
                if(birthdaySearchStrings==nil){
                    birthdaySearchStrings=[[NSMutableArray alloc]initWithObjects:@"wish you", @"belated", @"birthday wishes", @"have a lovely birthday", @"happy birthday", @"many happy returns of the day",nil];/*@"happy",@"many more", @"wish you",@"belated",@"birthday wishes",@"have a lovely birthday",@"happy birthday",@"many happy returns of the day",nil];*/
                }
                
                if(![result isKindOfClass:[NSArray class]])
                    return;
                for (NSDictionary *friendDict in (NSMutableArray*)result){
                    if(![friendDict isKindOfClass:[NSDictionary class]])
                        return;
                    
                    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                        return;
                    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    currentAPICall=kAPIGetJSONForStatuses;
                    //last 2 days
                    FBRequest *fbReqStatuses=[[self facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/statuses?since=%@", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-3]] andDelegate:self]; //last 2 days as it like windows phone logic
                    [fbRequestsArray addObject:fbReqStatuses];
                    [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqStatuses url]];
                    FBRequest *fbReqPhotos=[[self facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/photos?since=%@", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-3]] andDelegate:self]; //last 2 days as it like windows phone logic
                    [fbRequestsArray addObject:fbReqPhotos];
                    [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqPhotos url]];  
                    
                    
                    
                }
                
                
                break;
            case kAPIGetJSONForStatuses:
                //json
                
                if([result isKindOfClass:[NSDictionary class]]){
                    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                        return;
                    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    
                    //parse the json feed to check the number of comments and likes, If it has more than 25 comments then check for the event text (for photos, 15 comments)
                    int totalCountForMessagesOrPhotos=[[result objectForKey:@"data"]count];
                    
                    if(totalCountForMessagesOrPhotos){
                        
                        for (int i=0;i<totalCountForMessagesOrPhotos;i++){
                            //Picture(photos)
                            //NSLog(@"%@",result);
                            if([[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"picture"]){
                                
                                NSString *photoFromUser=[NSString stringWithFormat:@"%@",[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"from"] objectForKey:@"id"]];
                                NSString *userIDOfPhotos=[NSString stringWithFormat:@"%@",[friendUserIds objectForKey:request.url]];
                                
                                if([photoFromUser isEqualToString:userIDOfPhotos]){
                                    
                                    int commentsCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                    int likesCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                    
                                    if(commentsCount>=15 || likesCount>=15){
                                        
                                        BOOL isEventFound=NO;
                                        
                                        for(int j=0;j<commentsCount;j++){
                                            NSString *commentsStr=[[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                            
                                            //commentsStr=[commentsStr lowercaseString];
                                            
                                            for (NSString *searchedString in birthdaySearchStrings){
                                                if(!isEventFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventFound=YES;
                                                    [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }                                    
                                            if(!isEventFound){
                                                for (NSString *searchedString in newJobSearchStrings){
                                                    if(!isEventFound && [searchedString rangeOfString :commentsStr options:NSLiteralSearch].location != NSNotFound){
                                                        isEventFound=YES;
                                                        [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            if(!isEventFound){
                                                for (NSString *searchedString in anniversarySearchStrings){
                                                    if(!isEventFound &&[searchedString rangeOfString :commentsStr options:NSLiteralSearch].location != NSNotFound){
                                                        isEventFound=YES;
                                                        [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            
                                            if(!isEventFound){
                                                for (NSString *searchedString in congratsSearchStrings){
                                                    
                                                    if(!isEventFound && [searchedString rangeOfString :commentsStr options:NSLiteralSearch].location != NSNotFound){
                                                        //isEventFound=YES;
                                                        [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                            //Statuses
                            else{
                                int commentsCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                int likesCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                if(commentsCount>=15 || likesCount>=15){
                                    NSString *messageStr=[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"message"];
                                    
                                    BOOL isEventStatusFound=NO;
                                    if(!isEventStatusFound){
                                        
                                        for (NSString *searchedString in birthdaySearchStrings){
                                            
                                            if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                // NSLog(@"checking..%@",messageStr);
                                                isEventStatusFound=YES;
                                                [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                break;
                                            }
                                        }  
                                    }
                                    if(!isEventStatusFound){
                                        for (NSString *searchedString in anniversarySearchStrings){
                                            if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                isEventStatusFound=YES;
                                                [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                break;
                                            }
                                        }  
                                    }
                                    if(!isEventStatusFound){
                                        for (NSString *searchedString in newJobSearchStrings){
                                            if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                isEventStatusFound=YES;
                                                [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                break;
                                            }
                                        }  
                                    }                                
                                    if(!isEventStatusFound){
                                        for (NSString *searchedString in congratsSearchStrings){
                                            if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                isEventStatusFound=YES;
                                                [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                break;
                                            }
                                        }  
                                    }
                                    
                                    if(!isEventStatusFound){
                                        BOOL isEventsFromCommentsFound=NO;
                                        for(int j=0;j<commentsCount;j++){
                                            NSString *commentsStr=[[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                            //NSLog(@"comments..%@",commentsStr);
                                            
                                            
                                            if(!isEventsFromCommentsFound){
                                                for (NSString *searchedString in birthdaySearchStrings){
                                                    if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                        isEventsFromCommentsFound=YES;
                                                        [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            
                                            if(!isEventsFromCommentsFound){
                                                for (NSString *searchedString in anniversarySearchStrings){
                                                    if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                        isEventsFromCommentsFound=YES;
                                                        [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            if(!isEventsFromCommentsFound){
                                                for (NSString *searchedString in newJobSearchStrings){
                                                    if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                        isEventsFromCommentsFound=YES;
                                                        [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            if(!isEventsFromCommentsFound){
                                                for (NSString *searchedString in congratsSearchStrings){
                                                    if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                        //isEventsFromCommentsFound=YES;
                                                        [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                        break;
                                                    }
                                                }  
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    }
                    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];     
                }
                break;
                
        }
    }
    
	
    
}
-(void)dealloc{
    //[fbOperationQueue cancelAllOperations];
    //[fbOperationQueue release];
    if(fbRequestsArray){
        [fbRequestsArray removeAllObjects];

        [fbRequestsArray release];
    }
    [super dealloc];
}

@end
