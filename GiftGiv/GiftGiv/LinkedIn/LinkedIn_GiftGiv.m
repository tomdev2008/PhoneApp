//
//  LinkedIn_GiftGiv.m
//  GiftGiv
//

//  Created by Srinivas G on 20/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "LinkedIn_GiftGiv.h"
//#import "Constants.h"
#import "AppDelegate.h"
#import "RDLinkedIn.h"


@interface LinkedIn_GiftGiv ()

@property (nonatomic, retain) RDLinkedInEngine* engine;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchCurrentUserProfile;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchMemberProfile;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchNetworkUpdates;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchCommentsForUpdate;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchLikesForUpdate;

@end

@implementation LinkedIn_GiftGiv

@synthesize engine;
@synthesize fetchCurrentUserProfile,fetchMemberProfile,fetchNetworkUpdates,fetchCommentsForUpdate,fetchLikesForUpdate;

@synthesize lnkInGiftGivDelegate;

static NSCalendar *gregorianCalendar=nil;

-(id)init {
    self = [super init];
    if(self) {
        self.engine=[RDLinkedInEngine engineWithConsumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret delegate:self];
    }
    return self;
}
- (void)logInFromView:(id)viwController{

    RDLinkedInAuthorizationController* loginController = [RDLinkedInAuthorizationController authorizationControllerWithEngine:self.engine delegate:self];
    if( loginController ) {
        //[loginController setModalPresentationStyle:UIModalPresentationFormSheet];
        [viwController presentModalViewController:loginController animated:NO];
    }
    else {
        //GGLog(@"Already authenticated");
    }
}

- (void)logOut {
    if( self.engine.isAuthorized ) {
        [self.engine requestTokenInvalidation];                
    }
}
- (BOOL) isLinkedInAuthorized{
    return self.engine.isAuthorized;
}


- (void)fetchProfile {
    // make a request to linkedIn engine to get the user's profile
    self.fetchCurrentUserProfile = [self.engine profileForCurrentUser];
    
}

- (void)getMemberProfile:(NSString*)memberId{
  
    // make a request to linkedIn engine to get a particular member's profile
    self.fetchMemberProfile = [self.engine profileForPersonWithID:memberId];
}

//Algorithm to get the events from linkedin

/*
 Get network updates with an update type of PRFU
 
     For each update
 
     {
 
       For the updated-fields whether an update-field is having a name value as "person/positions"{
 
            Take the id of a member and get the member profile with positions
 
            If any position's  "is-current" value set to "true"{
 
                If the start-date's month and year related to last month of the current date{
 
                        Add the member to "Events to celebrate" with event-type "new position"
 
                }
 
            }
 
        }
 
    }
 */


//get a particular type of network updates for the loggedin user
- (void)getMyNetworkUpdatesWithType:(NSString*)type{
 
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    self.fetchNetworkUpdates = [self.engine networkUpdatesWithType:type];
   
}

//Collect the comments for a particular update
-(void)getListOfCommentsForTheUpdate:(NSString *)updateKey{
    
    self.fetchCommentsForUpdate = [self.engine commentsForUpdate:updateKey];
}
// Collect likes for a particular update
-(void)getLikesForAnUpdat:(NSString*)updateKey{
    
    self.fetchLikesForUpdate = [self.engine likesForUpdate:updateKey];
}
#pragma mark - RDLinkedInEngineDelegate

- (void)linkedInEngineAccessToken:(RDLinkedInEngine *)engine setAccessToken:(OAToken *)token {
   
    if( token ) {
        [token rd_storeInUserDefaultsWithServiceProviderName:@"LinkedIn" prefix:@"Demo"];
    }
    else {
        
        [OAToken rd_clearUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Demo"];
        [lnkInGiftGivDelegate linkedInDidLoggedOut];
    }
}

- (OAToken *)linkedInEngineAccessToken:(RDLinkedInEngine *)engine {
    return [OAToken rd_tokenWithUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Demo"];
}

//Delegate to receive the response from linkedIn
- (void)linkedInEngine:(RDLinkedInEngine *)engine requestSucceeded:(RDLinkedInConnectionID *)identifier withResults:(id)results {
    
    //Related to current user's profile
    if( identifier == self.fetchCurrentUserProfile ) {
        NSMutableDictionary* profile = results;
        [lnkInGiftGivDelegate linkedInLoggedInWithUserDetails:profile];
    }
    //network updates
    else if (identifier == self.fetchNetworkUpdates){
        if([networkUpdates count]){
            [networkUpdates removeAllObjects];
            [networkUpdates release];
            networkUpdates=nil;
        }
        networkUpdates=[[NSMutableArray alloc]init];
       
        NSMutableArray *tempUpdates;
        if([[results objectForKey:@"update"]isKindOfClass:[NSDictionary class]])
            tempUpdates=[[NSMutableArray alloc]initWithObjects:[results objectForKey:@"update"], nil];
        else
            tempUpdates=[[NSMutableArray alloc]initWithArray:[results objectForKey:@"update"]];
       // for each update
        for (NSMutableDictionary *updateDict in tempUpdates) {
            
            if([updateDict objectForKey:@"updated-fields"]){
                if([[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]){
                    int update_field_count=[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] count];
                    
                    if([[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]isKindOfClass:[NSArray class]]){
                        
                        for(int i=0;i<update_field_count;i++){
                           
                            if([[[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"person/positions"]){
                                
                                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] initWithCapacity:2];
                                [tempDict setObject:[[[updateDict objectForKey:@"update-content"]objectForKey:@"person"]objectForKey:@"id"] forKey:@"id"];
                                [tempDict setObject:[updateDict objectForKey:@"update-key"] forKey:@"update_key"];
                                
                                [networkUpdates addObject:tempDict];
                                [tempDict release];
                                break;
                            }
                        }
                    }
                    else if([[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]isKindOfClass:[NSDictionary class]]){
                        //GGLog(@"Updates1...%@",updateDict);
                        //take the update if it is related to position
                        if([[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] objectForKey:@"name"] isEqualToString:@"person/positions"]){
                            //GGLog(@"Updates...%@",updateDict);
                            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] initWithCapacity:2];
                            [tempDict setObject:[[[updateDict objectForKey:@"update-content"]objectForKey:@"person"]objectForKey:@"id"] forKey:@"id"];
                            [tempDict setObject:[updateDict objectForKey:@"update-key"] forKey:@"update_key"];
                            [networkUpdates addObject:tempDict];
                            [tempDict release];
                            
                        }
                    }
                }
            }
        }
        [tempUpdates release];
        
        currentConnectionNum=0;
        totalConnectionsCount=[networkUpdates count];
        if(totalConnectionsCount){
            while (currentConnectionNum<totalConnectionsCount){
                
                // check whether the ID is private or not, if it is private, we will not get profile for that user
                if(![[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"] isEqualToString:@"private"]){
                    
                    //Get the member's profile
                    if([self isLinkedInAuthorized])
                        [self getMemberProfile:[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
                    break;
                }
                    
                else
                    currentConnectionNum++;
            }
            
        }
        else{
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        }
               
    }
    else if (identifier == self.fetchMemberProfile){
        
        if([results isKindOfClass:[NSDictionary class]]){
            if([[results objectForKey:@"positions"] isKindOfClass:[NSDictionary class]]){
                if([[results objectForKey:@"positions"] objectForKey:@"position"]){
                    
                    if([[[results objectForKey:@"positions"] objectForKey:@"position"]isKindOfClass:[NSArray class]]){
                        for(NSDictionary *tempDict in [[results objectForKey:@"positions"] objectForKey:@"position"]){
                            
                            if([tempDict objectForKey:@"is-current"]){
                                if([[tempDict objectForKey:@"is-current"] isEqualToString:@"true"]){
                                   // To check if the start-date from past 1 month
                                    if([tempDict objectForKey:@"start-date"]){
                                        NSDictionary *startDateDict=[tempDict objectForKey:@"start-date"];
                                        if(gregorianCalendar==nil)
                                            gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                        NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                                        int currentMonth=[components month];
                                        int currentYear=[components year];
                                                                                
                                        if([[startDateDict objectForKey:@"year"] intValue]==currentYear){
                                            
                                            if([[startDateDict objectForKey:@"month"] intValue]>=currentMonth-1){
                                                                                                
                                                [[results objectForKey:@"positions"] setObject:tempDict forKey:@"position"];
                                                for (int j=0;j<totalConnectionsCount;j++){
                                                    
                                                    if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                        [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                                }
                                               
                                                
                                                //send it to events to celebrate group
                                                
                                                [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                                break;
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    else if([[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"is-current"]){
                        if([[[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"is-current"] isEqualToString:@"true"]){
                            
                            if([[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"start-date"]){
                                NSDictionary *startDateDict=[[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"start-date"];
                                if(gregorianCalendar==nil)
                                    gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                                int currentMonth=[components month];
                                int currentYear=[components year];
                                                                
                                if([startDateDict objectForKey:@"year"]){
                                    if([[startDateDict objectForKey:@"year"] intValue]==currentYear){
                                        if([startDateDict objectForKey:@"month"]){
                                            if([[startDateDict objectForKey:@"month"] intValue]>=currentMonth-1){
                                                
                                                //send it to events to celebrate group
                                                for (int j=0;j<totalConnectionsCount;j++){
                                                    
                                                    if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                        [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                                }
                                                
                                                
                                                [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                            }
                                        }
                                        else{
                                            for (int j=0;j<totalConnectionsCount;j++){
                                                
                                                if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                    [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                            }
                                            [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                           
                        }
                    }
                }
            }
            
        }  
        
        
        if(currentConnectionNum<totalConnectionsCount-1){
            currentConnectionNum++;
            while (currentConnectionNum<totalConnectionsCount){
                if(![[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"] isEqualToString:@"private"]){
                    if([self isLinkedInAuthorized])
                        [self getMemberProfile:[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
                    break;
                }
                
                else
                    currentConnectionNum++;
            }
            
        }
        else if(currentConnectionNum==totalConnectionsCount-1){
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        }

    }
    else if (identifier == self.fetchLikesForUpdate){
        
        //Received likes for the events to show in the details screen.
        int likesCount=0;
        if([results objectForKey:@"like"]){
            likesCount=[[results objectForKey:@"like"] count];
        }
            
        [lnkInGiftGivDelegate receivedLikesForAnUpdate:likesCount];
        
    }
    else if (identifier ==  self.fetchCommentsForUpdate){
        
        [lnkInGiftGivDelegate receivedCommentsForAnUpdate:results];
        
    }
}

- (void)linkedInEngine:(RDLinkedInEngine *)engine requestFailed:(RDLinkedInConnectionID *)identifier withError:(NSError *)error {
    GGLog(@"++ LinkedIn engine reports failure for connection %@\n%@", identifier, [error localizedDescription]);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
   [lnkInGiftGivDelegate linkedInDidRequestFailed];
}


#pragma mark - RDLinkedInAuthorizationControllerDelegate

- (void)linkedInAuthorizationControllerSucceeded:(RDLinkedInAuthorizationController *)controller {
    
    [lnkInGiftGivDelegate linkedInLoggedIn];
}

- (void)linkedInAuthorizationControllerFailed:(RDLinkedInAuthorizationController *)controller {
    [lnkInGiftGivDelegate linkedInDidRequestFailed];
    GGLog(@"failed!");
}

- (void)linkedInAuthorizationControllerCanceled:(RDLinkedInAuthorizationController *)controller {
    [lnkInGiftGivDelegate linkedInDidCancelledLogin];
    GGLog(@"cancelled!");
}

@end


