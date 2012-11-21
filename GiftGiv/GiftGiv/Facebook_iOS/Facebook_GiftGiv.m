//
//  Facebook_GiftGiv.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "Facebook_GiftGiv.h"
#import "ApplicationHelpers.h"

@interface Facebook_GiftGiv()

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;

@end



@implementation Facebook_GiftGiv

@synthesize facebook,fbGiftGivDelegate,fbRequestsArray;

static NSDateFormatter *standardDateFormatter = nil;
static NSDateComponents *components=nil;
static NSCalendar *gregorian=nil;

#pragma mark Facebook_GiftGiv class methods

- (FBSession *)facebook{
    
    if (![[FBSession activeSession]isOpen]) {
        
        //        facebook = [[Facebook alloc] initWithAppId:KFacebookAppId andDelegate:self];
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *fbAccessToken=[defaults objectForKey:@"FBAccessTokenKey"];
        NSDate *fbExpirationDateKey=[defaults objectForKey:@"FBExpirationDateKey"];
        if (fbAccessToken && fbExpirationDateKey) {
            [FBSession activeSession].accessToken = fbAccessToken;
            [FBSession activeSession].expirationDate = fbExpirationDateKey;
            
            if([fbRequestsArray count]){
                for(FBRequestConnection *request in fbRequestsArray){
                    [request  cancel];
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
    if([[FBSession activeSession]isOpen]){
        if([fbRequestsArray count]){
            for(FBRequestConnection *request in fbRequestsArray){
                [request  cancel];
            }
            [fbRequestsArray removeAllObjects];
        }
        if(fbRequestsArray!=nil){
            [fbRequestsArray release];
            fbRequestsArray=nil;
        }
        [FBSession activeSession].accessToken=nil;
        [FBSession activeSession].expirationDate=nil;
        
    }
}
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    
    return [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"user_about_me",@"user_birthday",@"friends_status",@"friends_photos",@"friends_birthday",@"friends_location",nil]
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             switch (state) {
                                                 case FBSessionStateClosedLoginFailed:
                                                 {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                         message:error.localizedDescription
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil];
                                                     [alertView show];
                                                     [alertView release];
                                                 }
                                                     
                                                     break;
                                                 case FBSessionStateOpen:
                                                 {
                                                     [self storeAuthData:[[FBSession activeSession] accessToken] expiresAt:[[FBSession activeSession] expirationDate]];
                                                     
                                                     [fbGiftGivDelegate facebookLoggedIn];
                                                     [self apiFQLIMe];
                                                 }
                                                     break;
                                                     
                                                 default:
                                                     break;
                                             }
                                             [[NSNotificationCenter defaultCenter]
                                              postNotificationName:FBSessionStateChangedNotification
                                              object:session];
                                             
                                         }];
    
}
- (void) closeSession {
    
    [FBSession.activeSession closeAndClearTokenInformation];
}
#pragma mark -
#pragma mark Login helper

-(void)authorizeOurAppWithFacebook{
    
    // Check and retrieve authorization information
    
    NSString *fbAccessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
    NSDate *fbExpirationDateKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"FBExpirationDateKey"];
    
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [self openSessionWithAllowLoginUI:YES];
    }
    
    
    if (fbAccessToken && fbExpirationDateKey)
    {
        [FBSession activeSession].accessToken = fbAccessToken;
        [FBSession activeSession].expirationDate = fbExpirationDateKey;
    }
}

-(void)logoutOfFacebook{
    
    
    [FBSession activeSession].accessToken = nil;
    [FBSession activeSession].expirationDate = nil;
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    
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

#pragma mark - Facebook Delegate methodes

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"FBAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults]setObject:expiresAt forKey:@"FBExpirationDateKey"];
    
}

#pragma mark - FQLs and GraphAPI

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid,first_name,last_name,birthday_date FROM user WHERE uid=me()", @"q",
                                   nil];
    currentAPICall=kAPIGetUserDetails;
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                 HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error) {
                                     if (error) {
                                         //NSLog(@"Error: %@", [error localizedDescription]);
                                     } else {
                                         
                                         if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
                                             result = [result objectAtIndex:0];
                                         }
                                         
                                         if([result objectForKey:@"data"]){
                                             [fbGiftGivDelegate facebookDidLoggedInWithUserDetails:(NSMutableDictionary*)[[result objectForKey:@"data"]objectAtIndex:0]];
                                         }
                                     }
                                 }];
    
}
//Get my friend birthdays
- (void)listOfBirthdayEvents{
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        
        //Date should be in MM/dd/yyyy formate only for facebook queries
        NSString *startDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:-4]; //previous 3 days as it like windows phone logic
        NSString *endDate=[self getNewDateForCurrentDateByAddingTimeIntervalInDays:14]; //next 15 days as it like windows phone logic
        
        NSString *getBirthdaysQuery=[NSString stringWithFormat:@"SELECT uid, name, first_name, last_name, birthday_date, pic_square FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()) AND strlen(birthday_date) != 0 AND birthday_date >= \"%@\" AND birthday_date <= \"%@\" ORDER BY birthday_date ASC",startDate,endDate];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getBirthdaysQuery, @"q",
                                       nil];
        
        // Make the API request that uses FQL
        [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                     HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error) {
                                         if (error) {
                                             NSLog(@"Error: %@", [error localizedDescription]);
                                         } else {
                                             if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                                                 return;
                                             //List of birthdays received
                                             
                                             if([result isKindOfClass:[NSDictionary class]]){
                                                 if([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]){
                                                     [fbGiftGivDelegate receivedBirthDayEvents:(NSMutableArray *)[result objectForKey:@"data"]];
                                                 }
                                             }
                                             
                                         }
                                     }];
    }
    
}

//Algorithm to track the photos/statuses
/*
 Get all friends
 
 For each friend{
    //photos (For better performance, we used multiquery for each 50 friends)
    Get all photos which are modified from past 3 days{
    for each photo{
        if comments count or likes count are greater than or equal 15{
            Get the all comments respective to the photo/event ID{
                For each comment{
                    If the comment text matches with the search keywords respective to birthdays/anniversaries/congratulations/newjob{
                            Get the particular user details (name, picture url) as we dont get these details with the above query{
                                Add this as an event with respective to the user
                            }
                    }
                }
            }
        }
    }
    //Statuses (For better performance, we used batch requests for each 50 friends
    Get status messages from past 2 days{
        For each status message{
            If comments or likes count greater than or equal 15{
                If status message text matches with any of the searched keywords respective to birthdays/anniversaries/congratulations/newjob{
                    Add this as an event with respective to the user
                }
            else{
                For each comment{
                    If comment message text matches with any of the searched keyword respective to birthdays/anniversaries/congratulations/newjob{
                        Add this as an event with respective to the user
                    }
                }
            }
        }
 }
 
 */

- (void)getAllFriendsWithTheirDetails{
    
    //Check if the accesstoken is available
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"FBAccessTokenKey"]){
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        /*[fbRequestsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         FBRequest*reqObj= (FBRequest*)obj ;
         [reqObj.connection cancel];
         }];*/
        
        if(friendUserIds!=nil && [friendUserIds count]){
            responseCount=0;
            [friendUserIds removeAllObjects];
            [friendUserIds release];
            friendUserIds=nil;
        }
        friendUserIds=[[NSMutableDictionary alloc]init];
        
        NSString *getFriendsQuery=@"SELECT uid, name, first_name, last_name, birthday_date, pic_square from user where uid in (SELECT uid2 FROM friend WHERE uid1=me())";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       getFriendsQuery, @"q",
                                       nil];
        
        // Make the API request that uses FQL
        [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                     HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error) {
                                         if (error) {
                                             GGLog(@"Error: %@", [error localizedDescription]);
                                         } else {
                                             if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                                                 return;
                                             //Received list of friends, here we should get the statuses and photos
                                             if(![[result objectForKey:@"data"]isKindOfClass:[NSArray class]])
                                                 return;
                                             //Event search keywords
                                             if(newJobSearchStrings==nil){
                                                 newJobSearchStrings=[[NSMutableArray alloc]initWithObjects:@"got job", @"got new job", @"new job" ,nil];
                                             }
                                             if(anniversarySearchStrings==nil){
                                                 anniversarySearchStrings=[[NSMutableArray alloc]initWithObjects:@"married", @"engaged", @"in a relationship", @"happy anniversary", @"anniversary" ,nil];
                                             }
                                             if(congratsSearchStrings==nil){
                                                 congratsSearchStrings=[[NSMutableArray alloc]initWithObjects:@"congrats", @"Congratulations" ,nil];
                                             }
                                             if(birthdaySearchStrings==nil){
                                                 birthdaySearchStrings=[[NSMutableArray alloc]initWithObjects:@"belated", @"birthday wishes", @"have a lovely birthday", @"happy birthday", @"many happy returns of the day",nil];
                                             }
                                             
                                             
                                             //epoch time
                                             NSTimeInterval currentTimeInterval=[[NSDate date] timeIntervalSince1970];
                                             
                                             NSMutableArray *requestJsonArray = [[[NSMutableArray alloc] init] autorelease];
                                             NSMutableArray *requestJsonArrayForPhotos = [[[NSMutableArray alloc] init] autorelease];
                                             
                                             int requestCountForBatch=0;
                                             
                                             for (NSDictionary *friendDict in (NSMutableArray*)[result objectForKey:@"data"]){
                                                 
                                                 if(![friendDict isKindOfClass:[NSDictionary class]])
                                                     return;
                                                 
                                                 if(![[NSUserDefaults standardUserDefaults]boolForKey:@"IsLoadingFromFacebook"])
                                                     return;
                                                 
                                                 
                                                 // Get the list of photos for each of my friend from past 3 days
                                                 NSString *getPhotosQuery=[NSString stringWithFormat:@"'%@':'select object_id,created,owner, like_info,comment_info from photo where modified>=%.0f and aid in (select aid from album where owner=%@ and modified_major>=%.0f)'",[friendDict objectForKey:@"uid"],(currentTimeInterval-(3*24*60*60)),[friendDict objectForKey:@"uid"],(currentTimeInterval-(3*24*60*60))];
                                                 // statuses query for batch request
                                                 //last 2 days
                                                 NSString *fbReqStatuses=[NSString stringWithFormat:@"{ \"method\": \"GET\", \"relative_url\": \"%@/statuses?since=%@\" }", [friendDict objectForKey:@"uid"], [self getNewDateForCurrentDateByAddingTimeIntervalInDays:-3]];
                                                 
                                                 
                                                 [requestJsonArray addObject:fbReqStatuses];
                                                 requestCountForBatch++;
                                                 [requestJsonArrayForPhotos addObject:getPhotosQuery];
                                                 
                                                 //For every 50 friends, will make multiquery
                                                 if(requestCountForBatch%20==0){
                                                     NSString *requestJson = [NSString stringWithFormat:@"[{\"method\":\"POST\", \"relative_url\":\"method/fql.multiquery?queries={%@}\"}]", [requestJsonArrayForPhotos componentsJoinedByString:@","]];
                                                     [requestJsonArrayForPhotos removeAllObjects];
                                                     
                                                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                                                     [FBRequestConnection startWithGraphPath:@"" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                         if(error){
                                                             
                                                         }
                                                         else{
                                                             //GGLog(@"RESULT---%@",result);
                                                             
                                                             int resultCount=[result count];
                                                             for ( int i=0; i < resultCount; i++ ) {
                                                                 NSDictionary *response = [result objectAtIndex:i];
                                                                 if(![response isKindOfClass:[NSNull class]]){
                                                                     int httpCode = [[response objectForKey:@"code"] intValue];
                                                                     
                                                                     
                                                                     if ( httpCode != 200 ) {
                                                                         GGLog( @"Facebook request error: code: %d ", httpCode );
                                                                     }
                                                                     else {
                                                                         SBJSON *json=[[SBJSON alloc]init];
                                                                         NSArray *resultantJson=(NSArray*)[json objectWithString:[response objectForKey:@"body"]];
                                                                         [json release];
                                                                         for(NSDictionary* resultDict in resultantJson){
                                                                             if([resultDict objectForKey:@"fql_result_set"]){
                                                                                 int listCountOfResultSetForEachQuery=[[resultDict objectForKey:@"fql_result_set"] count];
                                                                                 for(int j=0;j<listCountOfResultSetForEachQuery;j++){
                                                                                     NSMutableDictionary *overviewOfPhotoObject=(NSMutableDictionary*)[[resultDict objectForKey:@"fql_result_set"] objectAtIndex:j];
                                                                                     
                                                                                     //Check if the comments count or likes count more than or equal to 15
                                                                                     if([[[overviewOfPhotoObject  objectForKey:@"like_info"] objectForKey:@"like_count"] intValue]>=15 || [[[overviewOfPhotoObject objectForKey:@"comment_info"] objectForKey:@"comment_count"] intValue]>=15){
                                                                                         
                                                                                         //Get the details of a photo with comments
                                                                                         NSString *getCommentsForPhoto=[NSString stringWithFormat:@"SELECT object_id,text from comment where object_id=%@",[overviewOfPhotoObject objectForKey:@"object_id"]];
                                                                                         NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                                                        getCommentsForPhoto, @"q",
                                                                                                                        nil];
                                                                                         [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                      HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error) {
                                                                                                                          if(error){
                                                                                                                              
                                                                                                                          }
                                                                                                                          else{
                                                                                                                              
                                                                                                                              BOOL isEventFound=NO;
                                                                                                                              int commentsTextCount=[[result objectForKey:@"data" ]count];
                                                                                                                              for(int i=0;i<commentsTextCount;i++){
                                                                                                                                  NSString *commentsStr=[[[result objectForKey:@"data" ] objectAtIndex:i] objectForKey:@"text"];
                                                                                                                                  
                                                                                                                                  
                                                                                                                                  for (NSString *searchedString in birthdaySearchStrings){
                                                                                                                                      if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                          isEventFound=YES;
                                                                                                                                          NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                          
                                                                                                                                          NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                          [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                       HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                           if(error){
                                                                                                                                                                               
                                                                                                                                                                           }
                                                                                                                                                                           else{
                                                                                                                                                                               NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                               
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                               [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                               [tempDict setObject:@"birthday" forKey:@"EventName"];
                                                                                                                                                                               [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                               [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];
                                                                                                                                                                               [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               [tempDict release];
                                                                                                                                                                           }
                                                                                                                                                                       }];
                                                                                                                                          
                                                                                                                                          //break;
                                                                                                                                      }
                                                                                                                                  }
                                                                                                                                  if(!isEventFound){
                                                                                                                                      for (NSString *searchedString in newJobSearchStrings){
                                                                                                                                          
                                                                                                                                          if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                              isEventFound=YES;
                                                                                                                                              NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                              
                                                                                                                                              NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                              [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                           HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                               if(error){
                                                                                                                                                                                   
                                                                                                                                                                               }
                                                                                                                                                                               else{
                                                                                                                                                                                   NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                                   [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                                   [tempDict setObject:@"new job" forKey:@"EventName"];
                                                                                                                                                                                   [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                                   [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];
                                                                                                                                                                                   [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict release];
                                                                                                                                                                               }
                                                                                                                                                                           }];
                                                                                                                                              
                                                                                                                                              //break;
                                                                                                                                          }
                                                                                                                                      }}
                                                                                                                                  if(!isEventFound){
                                                                                                                                      for (NSString *searchedString in anniversarySearchStrings){
                                                                                                                                          
                                                                                                                                          if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                              isEventFound=YES;
                                                                                                                                              NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                              
                                                                                                                                              NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                              [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                           HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                               if(error){
                                                                                                                                                                                   
                                                                                                                                                                               }
                                                                                                                                                                               else{
                                                                                                                                                                                   NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                                   [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                                   [tempDict setObject:@"relationships" forKey:@"EventName"];
                                                                                                                                                                                   [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];                                                                                                              [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                                   
                                                                                                                                                                                   [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict release];
                                                                                                                                                                               }
                                                                                                                                                                           }];
                                                                                                                                              
                                                                                                                                              //break;
                                                                                                                                          }
                                                                                                                                      }}
                                                                                                                                  
                                                                                                                                  if(!isEventFound){
                                                                                                                                                                                                      for (NSString *searchedString in congratsSearchStrings){
                                                                                                                                          
                                                                                                                                                                                                              if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                                                                                                       isEventFound=YES;
                                                                                                                                              NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                              
                                                                                                                                              NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                              [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                           HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                               if(error){
                                                                                                                                                                                   
                                                                                                                                                                               }
                                                                                                                                                                               else{
                                                                                                                                                                                                                                                                                                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                                   [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                                   [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                                   [tempDict setObject:@"congratulations" forKey:@"EventName"];
                                                                                                                                                                                   [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];                                                                                                              [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                                   
                                                                                                                                                                                   [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   
                                                                                                                                                                                   [tempDict release];
                                                                                                                                                                               }
                                                                                                                                                                           }];
                                                                                                                                              
                                                                                                                                              //break;
                                                                                                                                          }
                                                                                                                                      }}
                                                                                                                              }
                                                                                                                              
                                                                                                                              
                                                                                                                              
                                                                                                                          }
                                                                                                                      }];
                                                                                         
                                                                                     }
                                                                                     
                                                                                 }
                                                                             }
                                                                         }
                                                                         
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                                 
                                                             }}
                                                     }];
                                                 }
                                                 
                                                 
                                                 // for every 50 friends, will prepare a batch request
                                                 if(requestCountForBatch%50==0){
                                                     
                                                     NSString *requestJson = [NSString stringWithFormat:@"[ %@ ]", [requestJsonArray componentsJoinedByString:@","]];
                                                     [requestJsonArray removeAllObjects];
                                                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                                                     [FBRequestConnection startWithGraphPath:@"" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                         if(error){
                                                             
                                                         }
                                                         else{
                                                             
                                                             int resultCount=[result count];
                                                             //Batch statuses
                                                             
                                                                 for ( int i=0; i < resultCount; i++ ) {
                                                                     NSDictionary *response = [result objectAtIndex:i];
                                                                     if(![response isKindOfClass:[NSNull class]]){
                                                                         int httpCode = [[response objectForKey:@"code"] intValue];
                                                                         
                                                                         SBJSON *json=[[SBJSON alloc]init];
                                                                         NSDictionary *resultantJson=(NSDictionary*)[json objectWithString:[response objectForKey:@"body"]];
                                                                         [json release];
                                                                         
                                                                         if ( httpCode != 200 ) {
                                                                             GGLog( @"Facebook request error: code: %d  message: %@", httpCode, resultantJson );
                                                                         }
                                                                         else {
                                                                             int totalCountForMessages=[[resultantJson objectForKey:@"data"] count];
                                                                             if(totalCountForMessages){
                                                                                 
                                                                                 for(int i=0;i<totalCountForMessages;i++){
                                                                                     
                                                                                     //Statuses
                                                                                     if([[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"]){
                                                                                         int commentsCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                                                                         int likesCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                                                                         //check if the comments or likes are more than or equal to 15
                                                                                         if(commentsCount>=15 || likesCount>=15){
                                                                                             NSString *messageStr=[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"message"];
                                                                                             
                                                                                             BOOL isEventStatusFound=NO;
                                                                                             if(!isEventStatusFound){
                                                                                                 //If birthday search keyword matched then send this event to the delegate
                                                                                                 for (NSString *searchedString in birthdaySearchStrings){
                                                                                                     
                                                                                                     if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                         
                                                                                                         isEventStatusFound=YES;
                                                                                                         [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                         //break;
                                                                                                     }
                                                                                                 }
                                                                                             }
                                                                                             if(!isEventStatusFound){
                                                                                                 //If anniversary search keyword matched then send this event to the delegate
                                                                                                 for (NSString *searchedString in anniversarySearchStrings){
                                                                                                     if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                         isEventStatusFound=YES;
                                                                                                         [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                         //break;
                                                                                                     }
                                                                                                 }
                                                                                             }
                                                                                             if(!isEventStatusFound){
                                                                                                 //If new job search keyword matched then send this event to the delegate
                                                                                                 for (NSString *searchedString in newJobSearchStrings){
                                                                                                     if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                         isEventStatusFound=YES;
                                                                                                         [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                         //break;
                                                                                                     }
                                                                                                 }
                                                                                             }
                                                                                             if(!isEventStatusFound){
                                                                                                 //If congrats search keyword matched then send this event to the delegate
                                                                                                 for (NSString *searchedString in congratsSearchStrings){
                                                                                                     if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                         isEventStatusFound=YES;
                                                                                                         [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                         //break;
                                                                                                     }
                                                                                                 }
                                                                                             }
                                                                                             
                                                                                             if(!isEventStatusFound){
                                                                                                 //Checking with comments text
                                                                                                 BOOL isEventsFromCommentsFound=NO;
                                                                                                 for(int j=0;j<commentsCount;j++){
                                                                                                     NSString *commentsStr=[[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                                                                                     
                                                                                                     if(!isEventsFromCommentsFound){
                                                                                                         for (NSString *searchedString in birthdaySearchStrings){
                                                                                                             if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                 isEventsFromCommentsFound=YES;
                                                                                                                 [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                                 //break;
                                                                                                             }
                                                                                                         }
                                                                                                     }
                                                                                                     
                                                                                                     if(!isEventsFromCommentsFound){
                                                                                                         for (NSString *searchedString in anniversarySearchStrings){
                                                                                                             if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                 isEventsFromCommentsFound=YES;
                                                                                                                 [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                                 //break;
                                                                                                             }
                                                                                                         }
                                                                                                     }
                                                                                                     if(!isEventsFromCommentsFound){
                                                                                                         for (NSString *searchedString in newJobSearchStrings){
                                                                                                             if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                 isEventsFromCommentsFound=YES;
                                                                                                                 [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                                 //break;
                                                                                                             }
                                                                                                         }
                                                                                                     }
                                                                                                     if(!isEventsFromCommentsFound){
                                                                                                         for (NSString *searchedString in congratsSearchStrings){
                                                                                                             if(!isEventsFromCommentsFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                 isEventsFromCommentsFound=YES;
                                                                                                                 [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                                 //break;
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
                                                     }];
                                                 }
                                             }
                                             
                                             if([requestJsonArrayForPhotos count]){
                                                 NSString *requestJson = [NSString stringWithFormat:@"[{\"method\":\"POST\", \"relative_url\":\"method/fql.multiquery?queries={%@}\"}]", [requestJsonArrayForPhotos componentsJoinedByString:@","]];
                                                 [requestJsonArrayForPhotos removeAllObjects];
                                                 
                                                 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                                                 [FBRequestConnection startWithGraphPath:@"" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                     if(error){
                                                         
                                                     }
                                                     else{
                                                         GGLog(@"RESULT---%@",result);
                                                         
                                                         int resultCount=[result count];
                                                         for ( int i=0; i < resultCount; i++ ) {
                                                             NSDictionary *response = [result objectAtIndex:i];
                                                             if(![response isKindOfClass:[NSNull class]]){
                                                                 int httpCode = [[response objectForKey:@"code"] intValue];
                                                                 
                                                                 
                                                                 if ( httpCode != 200 ) {
                                                                     GGLog( @"Facebook request error: code: %d ", httpCode );
                                                                 }
                                                                 else {
                                                                     SBJSON *json=[[SBJSON alloc]init];
                                                                     NSArray *resultantJson=(NSArray*)[json objectWithString:[response objectForKey:@"body"]];
                                                                     [json release];
                                                                     for(NSDictionary* resultDict in resultantJson){
                                                                         if([resultDict objectForKey:@"fql_result_set"]){
                                                                             int listCountOfResultSetForEachQuery=[[resultDict objectForKey:@"fql_result_set"] count];
                                                                             for(int j=0;j<listCountOfResultSetForEachQuery;j++){
                                                                                 NSMutableDictionary *overviewOfPhotoObject=(NSMutableDictionary*)[[resultDict objectForKey:@"fql_result_set"] objectAtIndex:j];
                                                                                 
                                                                                 //Check if the comments count or likes count more than or equal to 15
                                                                                 if([[[overviewOfPhotoObject  objectForKey:@"like_info"] objectForKey:@"like_count"] intValue]>=15 || [[[overviewOfPhotoObject objectForKey:@"comment_info"] objectForKey:@"comment_count"] intValue]>=15){
                                                                                     
                                                                                     //Get the details of a photo with comments
                                                                                     NSString *getCommentsForPhoto=[NSString stringWithFormat:@"SELECT object_id,text from comment where object_id=%@",[overviewOfPhotoObject objectForKey:@"object_id"]];
                                                                                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                                                    getCommentsForPhoto, @"q",
                                                                                                                    nil];
                                                                                     [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                  HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error) {
                                                                                                                      if(error){
                                                                                                                          
                                                                                                                      }
                                                                                                                      else{
                                                                                                                          
                                                                                                                          BOOL isEventFound=NO;
                                                                                                                          int commentsTextCount=[[result objectForKey:@"data" ]count];
                                                                                                                          for(int i=0;i<commentsTextCount;i++){
                                                                                                                              NSString *commentsStr=[[[result objectForKey:@"data" ] objectAtIndex:i] objectForKey:@"text"];
                                                                                                                              
                                                                                                                              
                                                                                                                              for (NSString *searchedString in birthdaySearchStrings){
                                                                                                                                  if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                      isEventFound=YES;
                                                                                                                                      NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                      
                                                                                                                                      NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                      [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                   HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                       if(error){
                                                                                                                                                                           
                                                                                                                                                                       }
                                                                                                                                                                       else{
                                                                                                                                                                           NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                           
                                                                                                                                                                           [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                           [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                           [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                           [tempDict setObject:@"birthday" forKey:@"EventName"];
                                                                                                                                                                           [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                           [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];
                                                                                                                                                                           [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                           
                                                                                                                                                                           
                                                                                                                                                                           
                                                                                                                                                                           [tempDict release];
                                                                                                                                                                       }
                                                                                                                                                                   }];
                                                                                                                                      
                                                                                                                                      //break;
                                                                                                                                  }
                                                                                                                              }
                                                                                                                              if(!isEventFound){
                                                                                                                                  for (NSString *searchedString in newJobSearchStrings){
                                                                                                                                      
                                                                                                                                      if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                          isEventFound=YES;
                                                                                                                                          NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                          
                                                                                                                                          NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                          [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                       HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                           if(error){
                                                                                                                                                                               
                                                                                                                                                                           }
                                                                                                                                                                           else{
                                                                                                                                                                               NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                               
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                               [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                               [tempDict setObject:@"new job" forKey:@"EventName"];
                                                                                                                                                                               [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                               [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];
                                                                                                                                                                               [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               [tempDict release];
                                                                                                                                                                           }
                                                                                                                                                                       }];
                                                                                                                                          
                                                                                                                                          //break;
                                                                                                                                      }
                                                                                                                                  }}
                                                                                                                              if(!isEventFound){
                                                                                                                                  for (NSString *searchedString in anniversarySearchStrings){
                                                                                                                                      
                                                                                                                                      if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                          isEventFound=YES;
                                                                                                                                          NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                          
                                                                                                                                          NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                          [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                       HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                           if(error){
                                                                                                                                                                               
                                                                                                                                                                           }
                                                                                                                                                                           else{
                                                                                                                                                                               NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                               
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                               [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                               [tempDict setObject:@"relationships" forKey:@"EventName"];
                                                                                                                                                                               [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];                                                                                                              [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                               
                                                                                                                                                                               [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               [tempDict release];
                                                                                                                                                                           }
                                                                                                                                                                       }];
                                                                                                                                          
                                                                                                                                          //break;
                                                                                                                                      }
                                                                                                                                  }}
                                                                                                                              
                                                                                                                              if(!isEventFound){
                                                                                                                                                                                                  for (NSString *searchedString in congratsSearchStrings){
                                                                                                                                      
                                                                                                                                                                                                          if(!isEventFound && [self checkWhetherText:commentsStr contains:searchedString]){
                                                                                                                                                                                                                   isEventFound=YES;
                                                                                                                                          NSString *getProfile=[NSString stringWithFormat:@"SELECT name, pic_square from user where uid=%@",[resultDict objectForKey:@"name"]];
                                                                                                                                          
                                                                                                                                          NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:getProfile, @"q",nil];
                                                                                                                                          [FBRequestConnection startWithGraphPath:@"/fql" parameters:params
                                                                                                                                                                       HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                                                                                                                                           if(error){
                                                                                                                                                                               
                                                                                                                                                                           }
                                                                                                                                                                           else{
                                                                                                                                                                                                                                                                                            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                                                                                                                                                                               
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"name"] forKey:@"FBName"];
                                                                                                                                                                               [tempDict setObject:[[[result objectForKey:@"data" ] objectAtIndex:0]objectForKey:@"pic_square"] forKey:@"pic_square"];
                                                                                                                                                                               [tempDict setObject:[NSString stringWithFormat:@"%@",[overviewOfPhotoObject objectForKey:@"object_id"]] forKey:@"EventID"];
                                                                                                                                                                               [tempDict setObject:@"congratulations" forKey:@"EventName"];
                                                                                                                                                                               [tempDict setObject:[resultDict objectForKey:@"name"] forKey:@"FBID"];                                                                                                              [tempDict setObject:[NSDate dateWithTimeIntervalSince1970:[[overviewOfPhotoObject objectForKey:@"created"]floatValue]] forKey:@"PhotoCreatedDate"];
                                                                                                                                                                               
                                                                                                                                                                               [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:tempDict];
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               [tempDict release];
                                                                                                                                                                           }
                                                                                                                                                                       }];
                                                                                                                                          
                                                                                                                                          //break;
                                                                                                                                      }
                                                                                                                                  }}
                                                                                                                          }
                                                                                                                          
                                                                                                                          
                                                                                                                          
                                                                                                                      }
                                                                                                                  }];
                                                                                     
                                                                                 }
                                                                                 
                                                                             }
                                                                         }
                                                                     }
                                                                     
                                                                 }
                                                             }
                                                             
                                                             
                                                             
                                                         }}
                                                 }];
                                             }
                                             if([requestJsonArray count]){
                                                 NSString *requestJson = [NSString stringWithFormat:@"[ %@ ]", [requestJsonArray componentsJoinedByString:@","]];
                                                 [requestJsonArray removeAllObjects];
                                                 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:requestJson forKey:@"batch"];
                                                 [FBRequestConnection startWithGraphPath:@"" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result,NSError *error){
                                                     if(error){
                                                         
                                                     }
                                                     else{
                                                         //GGLog(@"Result..%@",result);
                                                         int resultCount=[result count];
                                                         //Batch statuses
                                                         
                                                         for ( int i=0; i < resultCount; i++ ) {
                                                             NSDictionary *response = [result objectAtIndex:i];
                                                             if(![response isKindOfClass:[NSNull class]]){
                                                                 int httpCode = [[response objectForKey:@"code"] intValue];
                                                                 
                                                                 SBJSON *json=[[SBJSON alloc]init];
                                                                 NSDictionary *resultantJson=(NSDictionary*)[json objectWithString:[response objectForKey:@"body"]];
                                                                 [json release];
                                                                 
                                                                 if ( httpCode != 200 ) {
                                                                     GGLog( @"Facebook request error: code: %d  message: %@", httpCode, resultantJson );
                                                                 }
                                                                 else {
                                                                     int totalCountForMessages=[[resultantJson objectForKey:@"data"] count];
                                                                     if(totalCountForMessages){
                                                                         
                                                                         for(int i=0;i<totalCountForMessages;i++){
                                                                             
                                                                             //Statuses
                                                                             if([[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"]){
                                                                                 int commentsCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] count];
                                                                                 int likesCount=[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"data"] count];
                                                                                 //check if the comments or likes are more than or equal to 15
                                                                                 if(commentsCount>=15 || likesCount>=15){
                                                                                     NSString *messageStr=[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"message"];
                                                                                     
                                                                                     BOOL isEventStatusFound=NO;
                                                                                     if(!isEventStatusFound){
                                                                                         //If birthday search keyword matched then send this event to the delegate
                                                                                         for (NSString *searchedString in birthdaySearchStrings){
                                                                                             
                                                                                             if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                 
                                                                                                 isEventStatusFound=YES;
                                                                                                 [fbGiftGivDelegate birthdayEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                 break;
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     if(!isEventStatusFound){
                                                                                         //If anniversary search keyword matched then send this event to the delegate
                                                                                         for (NSString *searchedString in anniversarySearchStrings){
                                                                                             if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                 isEventStatusFound=YES;
                                                                                                 [fbGiftGivDelegate anniversaryEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                 break;
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     if(!isEventStatusFound){
                                                                                         //If new job search keyword matched then send this event to the delegate
                                                                                         for (NSString *searchedString in newJobSearchStrings){
                                                                                             if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                 isEventStatusFound=YES;
                                                                                                 [fbGiftGivDelegate newJobEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                 break;
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     if(!isEventStatusFound){
                                                                                         //If congrats search keyword matched then send this event to the delegate
                                                                                         for (NSString *searchedString in congratsSearchStrings){
                                                                                             if(!isEventStatusFound && [self checkWhetherText:messageStr contains:searchedString]){
                                                                                                 isEventStatusFound=YES;
                                                                                                 [fbGiftGivDelegate congratsEventDetailsFromStatusOrPhoto:[[resultantJson objectForKey:@"data"]objectAtIndex:i]];
                                                                                                 break;
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     
                                                                                     if(!isEventStatusFound){
                                                                                         //Checking with comments text
                                                                                         BOOL isEventsFromCommentsFound=NO;
                                                                                         for(int j=0;j<commentsCount;j++){
                                                                                             NSString *commentsStr=[[[[[[resultantJson objectForKey:@"data"]objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"data"] objectAtIndex:j] objectForKey:@"message"];
                                                                                             
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
                                                                                                         isEventsFromCommentsFound=YES;
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
                                                 }];
                                             }
                                             
                                         }}];
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    }
    
}
- (void)getEventDetails:(NSString*)statusID{
    GGLog(@"event ID..%@",statusID);
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@",statusID] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error){
            GGLog(@"Error: %@", [error localizedDescription]);
        }
        else{
            
            if([result isKindOfClass:[NSDictionary class]]){
                [fbGiftGivDelegate receivedDetailedEventInfo:(NSMutableDictionary*)result];
            }
        }
    }];
    
}
#pragma mark -
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
    
    if(standardDateFormatter==nil){
        standardDateFormatter=[[NSDateFormatter alloc]init];
        [standardDateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    
    NSString *convertedToString=[standardDateFormatter stringFromDate:updatedDate];
    
    return convertedToString;
}

//Check whether the message/text contains a searched keyword
-(BOOL)checkWhetherText:(NSString*)sourceText contains:(NSString*)searchedKeyword{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", searchedKeyword];
    
    [sourceText compare:searchedKeyword options:NSCaseInsensitiveSearch];
    return [predicate evaluateWithObject:sourceText];
}
-(void)dealloc{
    
    if(fbRequestsArray){
        [fbRequestsArray removeAllObjects];
        
        [fbRequestsArray release];
    }
    [super dealloc];
}

@end
