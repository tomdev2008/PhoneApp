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

@synthesize facebook,fbGiftGivDelegate;

static Facebook_GiftGiv *sharedInstance = nil;
static NSDateFormatter *standardDateFormatter = nil;

#pragma mark Facebook_GiftGiv class methods
+ (Facebook_GiftGiv *)sharedSingleton
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
}

- (Facebook *)facebook{
    if (!facebook) {
        facebook = [[Facebook alloc] initWithAppId:KFacebookAppId andDelegate:sharedInstance];
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
        NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
        if (fbAccessToken && fbExpirationDateKey) {
            self.facebook.accessToken = fbAccessToken;
            self.facebook.expirationDate = fbExpirationDateKey;
            //NSLog(@"AccessToken= %@ \n ExpirationDate= %@", facebook.accessToken, facebook.expirationDate);
        }
    }
    return facebook;
}
#pragma mark -
#pragma mark Login helper

-(void)authorizeOurAppWithFacebook{
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
    NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
    
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
    [self storeAuthData:[self.facebook accessToken] expiresAt:[self.facebook expirationDate]];
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    //NSLog(@"%@",[defaults objectForKey:@"FBAccessTokenKey"]);
    [defaults synchronize];
}
/**
 * Called when the user logged out.
 */
- (void)fbDidLogout{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
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

#pragma mark - FQLs

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid,first_name,last_name,birthday_date FROM user WHERE uid=me()", @"query",
                                   nil];
    currentAPICall=kAPIGetUserDetails;
    [facebook requestWithMethodName:@"fql.query"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}
- (void)listOfBirthdayEvents{
    
    currentAPICall=kAPIGetBirthdayEvents;
    
    //Date should be in MM/dd/yyyy formate only for facebook queries
    NSString *startDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:-3];
    NSString *endDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:15];
    
    
    NSString *getBirthdaysQuery=[NSString stringWithFormat:@"SELECT uid, name, first_name, last_name, birthday_date FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()) AND strlen(birthday_date) != 0 AND birthday_date >= \"%@\" AND birthday_date <= \"%@\" ORDER BY birthday_date ASC",startDate,endDate];
    //NSLog(@"%@",getBirthdaysQuery);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   getBirthdaysQuery, @"query",
                                   nil];
    
    [facebook requestWithMethodName:@"fql.query"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
    
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
    currentAPICall=kAPIGetAllFriends;
    
    
    NSString *getFriendsQuery=@"SELECT uid, name, first_name, last_name, birthday_date from user where uid in (SELECT uid2 FROM friend WHERE uid1=me())";
    //NSLog(@"%@",getFriendsQuery);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   getFriendsQuery, @"query",
                                   nil];
    
    [facebook requestWithMethodName:@"fql.query"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}
#pragma mark FBRequestDelegate methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error=%@",error);
    [fbGiftGivDelegate facebookDidRequestFailed];
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    
    //NSLog(@"%@",result);
    
	switch (currentAPICall) {
        case kAPIGetUserDetails:
            if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
                result = [result objectAtIndex:0];
            }
            [fbGiftGivDelegate facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)result];
            break;
        case kAPIGetBirthdayEvents:
            
            [fbGiftGivDelegate receivedBirthDayEvents:(NSMutableArray *)result];
            
            break;
            //Received all friends details
        case kAPIGetAllFriends:
            currentAPICall=kAPIGetJSONForStatuses;
            if(friendUserIds!=nil && [friendUserIds count]){
                [friendUserIds removeAllObjects];
                [friendUserIds release];
                friendUserIds=nil;
            }
            friendUserIds=[[NSMutableDictionary alloc]init];
            
            if(newJobSearchStrings==nil){
                newJobSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats",@"all the best", @"good luck", @"congratulations", @"got job", @"got new job", @"new job",nil];
            }
            if(anniversarySearchStrings==nil){
                anniversarySearchStrings=[[NSMutableArray alloc]initWithObjects:@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary",nil];
            }
            if(congratsSearchStrings==nil){
                congratsSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats", @"all the best", @"good luck", @"congratulations",nil];
            }
            if(birthdaySearchStrings==nil){
                birthdaySearchStrings=[[NSMutableArray alloc]initWithObjects:@"happy",@"many more", @"wish you",@"belated",@"birthday wishes",@"have a lovely birthday",@"happy birthday",@"many happy returns of the day",nil];
            }
            
            
            for (NSDictionary *friendDict in (NSMutableArray*)result){
                
                
                //last 2 days
                FBRequest *fbReqStatuses=[facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/statuses?since=%@", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-2]] andDelegate:self];
                [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqStatuses url]];
                FBRequest *fbReqPhotos=[facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/photos?since=%@", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-2]] andDelegate:self];
                [friendUserIds setValue:[friendDict objectForKey:@"uid"] forKey:[fbReqPhotos url]];  
            }
            
            break;
        case kAPIGetJSONForStatuses:
            //json
            
            if([result isKindOfClass:[NSDictionary class]]){
                
                
                //parse the json feed to check the number of comments and likes, If it has more than 25 comments then check for the event text
                int totalCountForMessagesOrPhotos=[[result objectForKey:@"data"]count];
                
                if(totalCountForMessagesOrPhotos){
                    
                    for (int i=0;i<totalCountForMessagesOrPhotos;i++){
                        //Picture(photos)
                        if([[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"picture"]){
                            
                            NSString *photoFromUser=[NSString stringWithFormat:@"%@",[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"from"] objectForKey:@"id"]];
                            NSString *userIDOfPhotos=[NSString stringWithFormat:@"%@",[friendUserIds objectForKey:request.url]];
                            
                            if([photoFromUser isEqualToString:userIDOfPhotos]){
                                
                                int commentsCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                int likesCount=[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                
                                if(commentsCount>=15 || likesCount>=15){
                                    
                                    for(int j=0;j<commentsCount;j++){
                                        NSString *commentsStr=[[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                        commentsStr=[commentsStr lowercaseString];
                                        BOOL isEventFound;
                                        for (NSString *searchedString in birthdaySearchStrings){
                                            if(!isEventFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                isEventFound=YES;
                                                [fbGiftGivDelegate birthdayEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                break;
                                            }
                                        }                                    
                                        if(!isEventFound){
                                            for (NSString *searchedString in anniversarySearchStrings){
                                                if(!isEventFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventFound=YES;
                                                    [fbGiftGivDelegate birthdayEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        if(!isEventFound){
                                            for (NSString *searchedString in anniversarySearchStrings){
                                                if(!isEventFound &&[commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventFound=YES;
                                                    [fbGiftGivDelegate anniversaryEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        if(!isEventFound){
                                            for (NSString *searchedString in newJobSearchStrings){
                                                if(!isEventFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventFound=YES;
                                                    [fbGiftGivDelegate newJobEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        if(!isEventFound){
                                            for (NSString *searchedString in congratsSearchStrings){
                                                
                                                if(!isEventFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventFound=YES;
                                                    [fbGiftGivDelegate congratsEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
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
                            if(commentsCount>=25 || likesCount>=25){
                                NSString *messageStr=[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"message"];
                                BOOL isEventStatusFound;
                                if(!isEventStatusFound){
                                    for (NSString *searchedString in birthdaySearchStrings){
                                        if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                            isEventStatusFound=YES;
                                            [fbGiftGivDelegate birthdayEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }  
                                }
                                if(!isEventStatusFound){
                                    for (NSString *searchedString in anniversarySearchStrings){
                                        if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                            isEventStatusFound=YES;
                                            [fbGiftGivDelegate anniversaryEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }  
                                }
                                if(!isEventStatusFound){
                                    for (NSString *searchedString in newJobSearchStrings){
                                        if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                            isEventStatusFound=YES;
                                            [fbGiftGivDelegate newJobEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }  
                                }                                
                                if(!isEventStatusFound){
                                    for (NSString *searchedString in congratsSearchStrings){
                                        if(!isEventStatusFound && [messageStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                            isEventStatusFound=YES;
                                            [fbGiftGivDelegate congratsEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
                                            break;
                                        }
                                    }  
                                }
                                
                                else if(!isEventStatusFound){
                                    for(int j=0;j<commentsCount;j++){
                                        NSString *commentsStr=[[[[[[result objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                        BOOL isEventsFromCommentsFound;
                                        
                                        if(!isEventsFromCommentsFound){
                                            for (NSString *searchedString in birthdaySearchStrings){
                                                if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventsFromCommentsFound=YES;
                                                    [fbGiftGivDelegate birthdayEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        
                                        if(!isEventsFromCommentsFound){
                                            for (NSString *searchedString in anniversarySearchStrings){
                                                if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventsFromCommentsFound=YES;
                                                    [fbGiftGivDelegate anniversaryEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        if(!isEventsFromCommentsFound){
                                            for (NSString *searchedString in newJobSearchStrings){
                                                if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventsFromCommentsFound=YES;
                                                    [fbGiftGivDelegate newJobEventDetailsFromPhoto:[[result objectForKey:@"data"]objectAtIndex:i]];
                                                    break;
                                                }
                                            }  
                                        }
                                        if(!isEventsFromCommentsFound){
                                            for (NSString *searchedString in congratsSearchStrings){
                                                if(!isEventsFromCommentsFound && [commentsStr rangeOfString :searchedString options:NSLiteralSearch].location != NSNotFound){
                                                    isEventsFromCommentsFound=YES;
                                                    [fbGiftGivDelegate congratsEventDetailsFromStatus:[[result objectForKey:@"data"]objectAtIndex:i]];
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
            break;
    }
    
}


@end
