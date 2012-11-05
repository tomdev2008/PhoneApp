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
static NSDateComponents *components=nil;
static NSCalendar *gregorian=nil;

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
        [self.facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"user_birthday",@"friends_status",@"friends_photos",@"friends_birthday",@"friends_location",nil]]; //email to get user's mail address
        
        
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
        //currentAPICall=kAPIGetBirthdayEvents;
        
        //Date should be in MM/dd/yyyy formate only for facebook queries
        NSString *startDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:-4]; //previous 3 days as it like windows phone logic
        NSString *endDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:14]; //next 15 days as it like windows phone logic
        
        
        NSString *getBirthdaysQuery=[NSString stringWithFormat:@"SELECT uid, name, first_name, last_name, birthday_date, pic_square FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()) AND strlen(birthday_date) != 0 AND birthday_date >= \"%@\" AND birthday_date <= \"%@\" ORDER BY birthday_date ASC",startDate,endDate];
        //NSLog(@"%@",getBirthdaysQuery);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getBirthdaysQuery, @"query",
                                       nil];
        
        getFBBirthdaysReq=[[self facebook] requestWithMethodName:@"fql.query"
                                                      andParams:params
                                                  andHttpMethod:@"POST"
                                                    andDelegate:self];
        [fbRequestsArray addObject:getFBBirthdaysReq];
    }
    
}
-(NSString*)getNewDateForCurrentDateByAddingTimeIntervalInDays:(int)daysToAdd{
    NSDate *now=[NSDate date];    
    // set up date components
    if(components==nil)
       components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    
    // create a calendar
    if(gregorian==nil)
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
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
        //currentAPICall=kAPIGetAllFriends;
        [fbRequestsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FBRequest*reqObj= (FBRequest*)obj ;
            [reqObj.connection cancel];
        }];
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(friendUserIds!=nil && [friendUserIds count]){
            responseCount=0;
            [friendUserIds removeAllObjects];
            [friendUserIds release];
            friendUserIds=nil;
        }
        friendUserIds=[[NSMutableDictionary alloc]init];
        
        NSString *getFriendsQuery=@"SELECT uid, name, first_name, last_name, birthday_date, pic_square from user where uid in (SELECT uid2 FROM friend WHERE uid1=me())";
        //NSLog(@"%@",getFriendsQuery);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getFriendsQuery, @"query",
                                       nil];
        
        getFriendsListReq=[[self facebook] requestWithMethodName:@"fql.query"
                                                    andParams:params
                                                andHttpMethod:@"POST"
                                                  andDelegate:self];
       
        [fbRequestsArray addObject:getFriendsListReq];
        
        
    }
    
}
- (void)getEventDetails:(NSString*)statusID{
    NSLog(@"Event ID=%@",statusID);
    getDetailedEventReq=[[self facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@",statusID] andDelegate:self];
}
#pragma mark - FBRequestDelegate methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error=%@",error);
    responseCount++;
    [fbGiftGivDelegate facebookDidRequestFailed];
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        
        if([request isEqual:getDetailedEventReq]){
            
            if([result isKindOfClass:[NSDictionary class]]){
                [fbGiftGivDelegate receivedDetailedEventInfo:(NSMutableDictionary*)result];
            }
        }
        if([request isEqual:getFriendsListReq]){
                 
            
            if(newJobSearchStrings==nil){
                newJobSearchStrings=[[NSMutableArray alloc]initWithObjects:@"got job", @"got new job", @"new job" ,nil];/*@"congrats",@"all the best", @"good luck", @"congratulations", @"got job", @"got new job", @"new job",nil];*/
            }
            if(anniversarySearchStrings==nil){
                anniversarySearchStrings=[[NSMutableArray alloc]initWithObjects:@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary" ,nil];/*@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary",nil]*/;
            }
            if(congratsSearchStrings==nil){
                congratsSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats", @"Congratulations" ,nil];/*@"congrats", @"all the best", @"good luck", @"congratulations",nil];*/
            }
            if(birthdaySearchStrings==nil){
                birthdaySearchStrings=[[NSMutableArray alloc]initWithObjects:@"belated", @"birthday wishes", @"have a lovely birthday", @"happy birthday", @"many happy returns of the day",nil];/*@"happy",@"many more", @"wish you",@"belated",@"birthday wishes",@"have a lovely birthday",@"happy birthday",@"many happy returns of the day",nil];*/
            }
            
            if(![result isKindOfClass:[NSArray class]])
                return;
            NSTimeInterval currentTimeInterval=[[NSDate date] timeIntervalSince1970];
            //NSLog(@"photos..reque %@",fbReqPhotos.url);
            NSMutableArray *requestJsonArray = [[[NSMutableArray alloc] init] autorelease];
            NSMutableArray *requestJsonArrayForPhotos = [[[NSMutableArray alloc] init] autorelease];
            
            int requestCountForBatch=0;
            int countOfFriends=[result count];
            for (NSDictionary *friendDict in (NSMutableArray*)result){
                
                if(![friendDict isKindOfClass:[NSDictionary class]])
                    return;
                
                if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                    return;
                //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                currentAPICall=kAPIGetJSONForStatuses;
                
                NSString *getPhotosQuery=[NSString stringWithFormat:@"'%@':'SELECT object_id, created,owner, like_info, comment_info FROM photo WHERE modified>=%.0f AND aid IN (SELECT aid FROM album WHERE owner = %@ AND modified_major>=%.0f)'",[friendDict objectForKey:@"uid"],(currentTimeInterval-(3*24*60*60)),[friendDict objectForKey:@"uid"],(currentTimeInterval-(3*24*60*60))]; //actually it should be for the last 3 days, but changed it to 4 days to get the same as from service.
                
                requestCountForBatch++;
                [requestJsonArrayForPhotos addObject:getPhotosQuery];
                if(requestCountForBatch==countOfFriends){
                    NSString *requestJson = [NSString stringWithFormat:@"{%@}", [requestJsonArrayForPhotos componentsJoinedByString:@","]];
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"queries"];
                    FBRequest *fbReqPhotos=[[self facebook] requestWithMethodName:@"fql.multiquery"
                                                                        andParams:params
                                                                    andHttpMethod:@"POST"
                                                                      andDelegate:self];
                    [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqPhotos.params objectForKey:@"queries"]];
                    [fbRequestsArray addObject:fbReqPhotos];
                    [requestJsonArrayForPhotos removeAllObjects];
                    //requestCountForBatch=0;
                }
                 
                
                
                /*NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               getPhotosQuery, @"query",
                                               nil];
                
                FBRequest *fbReqPhotos=[[self facebook] requestWithMethodName:@"fql.query"
                                                                    andParams:params
                                                                andHttpMethod:@"POST"
                                                                  andDelegate:self];
                [fbRequestsArray addObject:fbReqPhotos];
                
                [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqPhotos.params objectForKey:@"query"]];*/
                
                
                //last 2 days
                NSString *fbReqStatuses=[NSString stringWithFormat:@"{ \"method\": \"GET\", \"relative_url\": \"%@/statuses?since=%@\" }", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-3]];
                
                               
                [requestJsonArray addObject:fbReqStatuses];
                if(requestCountForBatch%50==0){
                   
                    NSString *requestJson = [NSString stringWithFormat:@"[ %@ ]", [requestJsonArray componentsJoinedByString:@","]];
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                    FBRequest *fbReqSta=[[self facebook] requestWithGraphPath:@"" andParams:params andHttpMethod:@"POST" andDelegate:self];
                    [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqSta.params objectForKey:@"batch"]];
                    [requestJsonArray removeAllObjects];
                    //requestCountForBatch=0;
                    [fbRequestsArray addObject:fbReqSta];
                }
               
            }
            if([requestJsonArrayForPhotos count]){
                NSString *requestJson = [NSString stringWithFormat:@"{%@}", [requestJsonArrayForPhotos componentsJoinedByString:@","]];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"queries"];
                FBRequest *fbReqPhotos=[[self facebook] requestWithMethodName:@"fql.multiquery"
                                                                    andParams:params
                                                                andHttpMethod:@"POST"
                                                                  andDelegate:self];
                [friendUserIds setValue:@"" forKey:[fbReqPhotos.params objectForKey:@"queries"]];
                [fbRequestsArray addObject:fbReqPhotos];
                [requestJsonArrayForPhotos removeAllObjects];
                //requestCountForBatch=0;
            }
            if([requestJsonArray count]){
                NSString *requestJson = [NSString stringWithFormat:@"[ %@ ]", [requestJsonArray componentsJoinedByString:@","]];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                FBRequest *fbReqStatuses=[[self facebook] requestWithGraphPath:@"" andParams:params andHttpMethod:@"POST" andDelegate:self];
                [friendUserIds setValue:@"" forKey:[fbReqStatuses.params objectForKey:@"batch"]];
                [requestJsonArray removeAllObjects];
                requestCountForBatch=0;
                [fbRequestsArray addObject:fbReqStatuses];
            }
            
                   
            
        }
        if([request isEqual:getFBBirthdaysReq]){
            if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                return;
            
            if([result isKindOfClass:[NSArray class]])
                [fbGiftGivDelegate receivedBirthDayEvents:(NSMutableArray *)result];
        }
        switch (currentAPICall) {
                
            case kAPIGetUserDetails:
                //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; 
                if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
                    result = [result objectAtIndex:0];
                }
                [fbGiftGivDelegate facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)result];
                break;
            case kAPIGetBirthdayEvents:
                
                
                break;
                //Received all friends details
            case kAPIGetAllFriends:
                
                /*if(fbOperationQueue)
                    [fbOperationQueue cancelAllOperations];
                else
                    fbOperationQueue=[[NSOperationQueue alloc]init];*/
                
                 
                break;
            case kAPIGetJSONForStatuses:
                responseCount++;
                if([result isKindOfClass:[NSArray class]]){
                    int resultCount=[result count];
                    //Batch statuses
                    if([request.params objectForKey:@"batch"]){
                        for ( int i=0; i < resultCount; i++ ) {
                            NSDictionary *response = [result objectAtIndex:i];
                            if(![response isKindOfClass:[NSNull class]]){
                                int httpCode = [[response objectForKey:@"code"] intValue];
                                
                                SBJSON *json=[[SBJSON alloc]init];
                                NSDictionary *resultantJson=(NSDictionary*)[json objectWithString:[response objectForKey:@"body"]];
                                [json release];
                                
                                //NSString *jsonResponse = [response objectForKey:@"body"];
                                if ( httpCode != 200 ) {
                                    NSLog( @"Facebook request error: code: %d  message: %@", httpCode, resultantJson );
                                }
                                else {
                                    int totalCountForMessages=[[resultantJson objectForKey:@"data"] count];
                                    if(totalCountForMessages){
                                        //NSLog(@"data class..%@",[[resultantJson objectForKey:@"data"] class]);
                                        
                                        for(int i=0;i<totalCountForMessages;i++){
                                            
                                            //Statuses
                                            if([[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"]){
                                                int commentsCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                                int likesCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                                if(commentsCount>=15 || likesCount>=15){
                                                    NSString *messageStr=[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"message"];
                                                    
                                                    BOOL isEventStatusFound=NO;
                                                    if(!isEventStatusFound){
                                                        
                                                        for (NSString *searchedString in birthdaySearchStrings){
                                                            
                                                            if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                // NSLog(@"checking..%@",messageStr);
                                                                isEventStatusFound=YES;
                                                                [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    if(!isEventStatusFound){
                                                        for (NSString *searchedString in anniversarySearchStrings){
                                                            if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                isEventStatusFound=YES;
                                                                [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    if(!isEventStatusFound){
                                                        for (NSString *searchedString in newJobSearchStrings){
                                                            if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                isEventStatusFound=YES;
                                                                [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    if(!isEventStatusFound){
                                                        for (NSString *searchedString in congratsSearchStrings){
                                                            if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                isEventStatusFound=YES;
                                                                [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    
                                                    if(!isEventStatusFound){
                                                        BOOL isEventsFromCommentsFound=NO;
                                                        for(int j=0;j<commentsCount;j++){
                                                            NSString *commentsStr=[[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                                            //NSLog(@"comments..%@",commentsStr);
                                                            
                                                            
                                                            if(!isEventsFromCommentsFound){
                                                                for (NSString *searchedString in birthdaySearchStrings){
                                                                    if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                        isEventsFromCommentsFound=YES;
                                                                        [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                            
                                                            if(!isEventsFromCommentsFound){
                                                                for (NSString *searchedString in anniversarySearchStrings){
                                                                    if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                        isEventsFromCommentsFound=YES;
                                                                        [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                            if(!isEventsFromCommentsFound){
                                                                for (NSString *searchedString in newJobSearchStrings){
                                                                    if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                        isEventsFromCommentsFound=YES;
                                                                        [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                            if(!isEventsFromCommentsFound){
                                                                for (NSString *searchedString in congratsSearchStrings){
                                                                    if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                        //isEventsFromCommentsFound=YES;
                                                                        [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
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
                                }
                            }
                            
                        }
                    }
                    
                    else{
                        for (int i=0;i<resultCount;i++){
                            
                            if([[result objectAtIndex:i] objectForKey:@"pic_square"]){
                                
                                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[friendUserIds objectForKey:[request.params objectForKey:@"query"]]];
                                [tempDict setObject:[[result objectAtIndex:i]objectForKey:@"name"] forKey:@"FBName"];
                                [tempDict setObject:[[result objectAtIndex:i]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[tempDict objectForKey:@"PhotoCreatedDate"]floatValue]] forKey:@"PhotoCreatedDate"];
                                if([[tempDict objectForKey:@"EventName"] isEqualToString:@"birthday"]){
                                    [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:tempDict];
                                }
                                else if([[tempDict objectForKey:@"EventName"] isEqualToString:@"relationships"]){
                                    [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:tempDict];
                                }
                                else if([[tempDict objectForKey:@"EventName"] isEqualToString:@"congratulations"]){
                                    [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:tempDict];
                                }
                                else if([[tempDict objectForKey:@"EventName"] isEqualToString:@"new job"]){
                                    [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:tempDict];
                                }
                                
                                
                                [tempDict release];
                                
                                
                            }
                            //list of pictures received from multiquery
                            else if([request.params objectForKey:@"queries"]){
                                if([[result objectAtIndex:i] objectForKey:@"fql_result_set"]){
                                    int listCountOfResultSetForEachQuery=[[[result objectAtIndex:i] objectForKey:@"fql_result_set"] count];
                                    for(int j=0;j<listCountOfResultSetForEachQuery;j++){
                                        NSMutableDictionary *overviewOfPhotoObject=(NSMutableDictionary*)[[[result objectAtIndex:i] objectForKey:@"fql_result_set"] objectAtIndex:j];
                                        if([[[overviewOfPhotoObject  objectForKey:@"like_info"] objectForKey:@"like_count"] intValue]>=15 || [[[overviewOfPhotoObject objectForKey:@"comment_info"] objectForKey:@"comment_count"] intValue]>=15){
                                            //NSLog(@"result..%@",result);
                                            NSString *getCommentsForPhoto=[NSString stringWithFormat:@"SELECT object_id,text from comment where object_id=%@",[overviewOfPhotoObject objectForKey:@"object_id"]];
                                            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           getCommentsForPhoto, @"query",
                                                                           nil];
                                            
                                            FBRequest *fbReqComments=[[self facebook] requestWithMethodName:@"fql.query"
                                                                                                  andParams:params
                                                                                              andHttpMethod:@"POST"
                                                                                                andDelegate:self];
                                            [fbRequestsArray addObject:fbReqComments];
                                            
                                            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithCapacity:2];
                                            [tempDict setObject:[overviewOfPhotoObject objectForKey:@"created"] forKey:@"PhotoCreatedDate"];
                                            
                                            [tempDict setObject:[[result objectAtIndex:i] objectForKey:@"name"] forKey:@"FBID"];
                                            
                                            [friendUserIds setValue:tempDict forKey:[fbReqComments.params objectForKey:@"query"]];
                                            [tempDict release];
                                        }
                                        
                                    }
                                }
                                
                            }
                                                      
                            
                            else if([[result objectAtIndex:i] objectForKey:@"text"]){
                                BOOL isEventFound=NO;
                                //int commentsCount=[[result objectForKey:@"data"] count];
                                //for(int j=0;j<commentsCount;j++){
                                NSString *commentsStr=[[result objectAtIndex:i] objectForKey:@"text"];
                                
                                //commentsStr=[commentsS;tr lowercaseString];
                                
                                for (NSString *searchedString in birthdaySearchStrings){
                                    if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                        isEventFound=YES;
                                        
                                        NSMutableDictionary *baseDetailsDict=[[NSMutableDictionary alloc]initWithDictionary:[friendUserIds objectForKey:[request.params objectForKey:@"query"]]];
                                        [baseDetailsDict setObject:[NSString stringWithFormat:@"%@",[[result objectAtIndex:i]objectForKey:@"object_id"]] forKey:@"EventID"];
                                        [baseDetailsDict setObject:@"birthday" forKey:@"EventName"];
                                        NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[[friendUserIds objectForKey:[request.params objectForKey:@"query"]]objectForKey:@"FBID"]];
                                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                       getProfile, @"query",
                                                                       nil];
                                        
                                        FBRequest *fbReqProfile=[[self facebook] requestWithMethodName:@"fql.query"
                                                                                             andParams:params
                                                                                         andHttpMethod:@"POST"
                                                                                           andDelegate:self];
                                        [fbRequestsArray addObject:fbReqProfile];
                                        
                                        
                                        [friendUserIds setValue:baseDetailsDict forKey:[fbReqProfile.params objectForKey:@"query"]];
                                        
                                        [baseDetailsDict release];
                                        //[fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                        break;
                                    }
                                }
                                if(!isEventFound){
                                    for (NSString *searchedString in newJobSearchStrings){
                                        
                                        if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                            isEventFound=YES;
                                            NSMutableDictionary *baseDetailsDict=[[NSMutableDictionary alloc]initWithDictionary:[friendUserIds objectForKey:[request.params objectForKey:@"query"]]];
                                            [baseDetailsDict setObject:[NSString stringWithFormat:@"%@",[[result objectAtIndex:i]objectForKey:@"object_id"]] forKey:@"EventID"];
                                            [baseDetailsDict setObject:@"new job" forKey:@"EventName"];
                                            NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[[friendUserIds objectForKey:[request.params objectForKey:@"query"]]objectForKey:@"FBID"]];
                                            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           getProfile, @"query",
                                                                           nil];
                                            
                                            FBRequest *fbReqProfile=[[self facebook] requestWithMethodName:@"fql.query"
                                                                                                 andParams:params
                                                                                             andHttpMethod:@"POST"
                                                                                               andDelegate:self];
                                            [fbRequestsArray addObject:fbReqProfile];
                                            
                                            
                                            [friendUserIds setValue:baseDetailsDict forKey:[fbReqProfile.params objectForKey:@"query"]];
                                            
                                            [baseDetailsDict release];
                                            // [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }
                                }
                                if(!isEventFound){
                                    for (NSString *searchedString in anniversarySearchStrings){
                                        
                                        if(!isEventFound &&[self checkWhetherText:commentsStr contains:searchedString]){
                                            isEventFound=YES;
                                            NSMutableDictionary *baseDetailsDict=[[NSMutableDictionary alloc]initWithDictionary:[friendUserIds objectForKey:[request.params objectForKey:@"query"]]];
                                            [baseDetailsDict setObject:[NSString stringWithFormat:@"%@",[[result objectAtIndex:i]objectForKey:@"object_id"]] forKey:@"EventID"];
                                            [baseDetailsDict setObject:@"relationships" forKey:@"EventName"];
                                            NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[[friendUserIds objectForKey:[request.params objectForKey:@"query"]]objectForKey:@"FBID"]];
                                            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           getProfile, @"query",
                                                                           nil];
                                            
                                            FBRequest *fbReqProfile=[[self facebook] requestWithMethodName:@"fql.query"
                                                                                                 andParams:params
                                                                                             andHttpMethod:@"POST"
                                                                                               andDelegate:self];
                                            [fbRequestsArray addObject:fbReqProfile];
                                            
                                            
                                            [friendUserIds setValue:baseDetailsDict forKey:[fbReqProfile.params objectForKey:@"query"]];
                                            
                                            [baseDetailsDict release];
                                            // [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }
                                }
                                
                                if(!isEventFound){
                                    for (NSString *searchedString in congratsSearchStrings){
                                        
                                        if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                            //isEventFound=YES;
                                            
                                            NSMutableDictionary *baseDetailsDict=[[NSMutableDictionary alloc]initWithDictionary:[friendUserIds objectForKey:[request.params objectForKey:@"query"]]];
                                            [baseDetailsDict setObject:[NSString stringWithFormat:@"%@",[[result objectAtIndex:i]objectForKey:@"object_id"]] forKey:@"EventID"];
                                            [baseDetailsDict setObject:@"congratulations" forKey:@"EventName"];
                                            
                                            NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[[friendUserIds objectForKey:[request.params objectForKey:@"query"]]objectForKey:@"FBID"]];
                                            
                                            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           getProfile, @"query",
                                                                           nil];
                                            
                                            FBRequest *fbReqProfile=[[self facebook] requestWithMethodName:@"fql.query"
                                                                                                 andParams:params
                                                                                             andHttpMethod:@"POST"
                                                                                               andDelegate:self];
                                            [fbRequestsArray addObject:fbReqProfile];
                                            
                                            
                                            [friendUserIds setValue:baseDetailsDict forKey:[fbReqProfile.params objectForKey:@"query"]];
                                            
                                            [baseDetailsDict release];
                                            //[fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }  
                                }
                                
                                //}
                            }
                        }
                    }
                    
                    
                    
                }
                
                if(responseCount==[friendUserIds count])
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                break;
                
        }
    }
    
	
    
}
-(BOOL)checkWhetherText:(NSString*)sourceText contains:(NSString*)searchedKeyword{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", searchedKeyword];
    
    [sourceText compare:searchedKeyword options:NSCaseInsensitiveSearch];
    return [predicate evaluateWithObject:sourceText];
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
