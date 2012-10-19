//
//  LinkedIn_GiftGiv.m
//  GiftGiv
//

//  Created by Srinivas G on 20/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "LinkedIn_GiftGiv.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "RDLinkedIn.h"

//#define SHARE_COMPLETED_NOTIFICATION @"LinkedInShareSuccess"
//#define SHARE_FAILED_NOTIFICATION @"LinkedInShareFailed"

@interface LinkedIn_GiftGiv ()

@property (nonatomic, retain) RDLinkedInEngine* engine;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchCurrentUserProfile;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchMemberProfile;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchNetworkUpdates;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchCommentsForUpdate;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchLikesForUpdate;

- (void)fetchProfile;

@end

//static LinkedIn_GiftGiv *sharedInstance = nil;

@implementation LinkedIn_GiftGiv


@synthesize engine;
@synthesize fetchCurrentUserProfile,fetchMemberProfile,fetchNetworkUpdates,fetchCommentsForUpdate,fetchLikesForUpdate;
//@synthesize shareConnection;
@synthesize lnkInGiftGivDelegate;

/*#pragma mark LinkedInShareHelper class methods
+ (LinkedIn_GiftGiv *)sharedSingleton
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif
    
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[LinkedIn_GiftGiv alloc] init];
        }
        return sharedInstance;// LinkedInShareHelper singleton
    } 
}*/
-(id)init {
    self = [super init];
    if(self) {
        self.engine=[RDLinkedInEngine engineWithConsumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret delegate:self];
    }
    return self;
}
- (void)logInFromView:(id)viwController{
    //NSLog(@"self.engine=%@ , self=%@",self.engine,self);
    RDLinkedInAuthorizationController* loginController = [RDLinkedInAuthorizationController authorizationControllerWithEngine:self.engine delegate:self];
    if( loginController ) {
        //[loginController setModalPresentationStyle:UIModalPresentationFormSheet];
        [viwController presentModalViewController:loginController animated:NO];
    }
    else {
        //NSLog(@"Already authenticated");
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
    
    self.fetchCurrentUserProfile = [self.engine profileForCurrentUser];
    
}

- (void)getMemberProfile:(NSString*)memberId{
  
    self.fetchMemberProfile = [self.engine profileForPersonWithID:memberId];
}

- (void)getMyNetworkUpdatesWithType:(NSString*)type{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    self.fetchNetworkUpdates = [self.engine networkUpdatesWithType:type];
   
}
-(void)getListOfCommentsForTheUpdate:(NSString *)updateKey{
    self.fetchCommentsForUpdate = [self.engine commentsForUpdate:updateKey];
}
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

- (void)linkedInEngine:(RDLinkedInEngine *)engine requestSucceeded:(RDLinkedInConnectionID *)identifier withResults:(id)results {
    
   // NSLog(@"identifier..%@",identifier);
    //NSLog(@"++ LinkedIn engine reports success for connection %@", identifier);
    if( identifier == self.fetchCurrentUserProfile ) {
        NSMutableDictionary* profile = results;
        [lnkInGiftGivDelegate linkedInLoggedInWithUserDetails:profile];
    }
    
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
        //NSLog(@"PRFU Updates..%@",tempUpdates);
        //NSLog(@"%d",[tempUpdates count]);
        for (NSMutableDictionary *updateDict in tempUpdates) {
            
            if([updateDict objectForKey:@"updated-fields"]){
                if([[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]){
                    int update_field_count=[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] count];
                    //NSLog(@"feed..%@, \nClass:%@",[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"],[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] class]);
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
                        
                        if([[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] objectForKey:@"name"] isEqualToString:@"person/positions"]){
                            
                            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] initWithCapacity:2];
                            [tempDict setObject:[[[updateDict objectForKey:@"update-content"]objectForKey:@"person"]objectForKey:@"id"] forKey:@"id"];
                            [tempDict setObject:[updateDict objectForKey:@"update-key"] forKey:@"update_key"];
                            [networkUpdates addObject:tempDict];
                            [tempDict release];
                            //break;
                        }
                    }
                }
            }
        }
        [tempUpdates release];
        
        currentConnectionNum=0;
        totalConnectionsCount=[networkUpdates count];
        if(totalConnectionsCount){
            while (currentConnectionNum<totalConnectionsCount-1){
                if(![[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"] isEqualToString:@"private"]){
                    if([self isLinkedInAuthorized])
                        [self getMemberProfile:[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
                    break;
                }
                    
                else
                    currentConnectionNum++;
            }
            
        }
               
    }
    else if (identifier == self.fetchMemberProfile){
        
        if([results isKindOfClass:[NSDictionary class]]){
            if([[results objectForKey:@"positions"] isKindOfClass:[NSDictionary class]]){
                if([[results objectForKey:@"positions"] objectForKey:@"position"]){
                    //NSLog(@"position..%@",[[results objectForKey:@"positions"] objectForKey:@"position"]);
                    if([[[results objectForKey:@"positions"] objectForKey:@"position"]isKindOfClass:[NSArray class]]){
                        for(NSDictionary *tempDict in [[results objectForKey:@"positions"] objectForKey:@"position"]){
                            //NSLog(@"dict..%@",tempDict);
                            if([tempDict objectForKey:@"is-current"]){
                                if([[tempDict objectForKey:@"is-current"] isEqualToString:@"true"]){
                                    //NSLog(@"found..%@",[results objectForKey:@"first-name"]);
                                    if([tempDict objectForKey:@"start-date"]){
                                        NSDictionary *startDateDict=[tempDict objectForKey:@"start-date"];
                                        
                                        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                        NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                                        int currentMonth=[components month];
                                        int currentYear=[components year];
                                        [gregorianCalendar release];
                                        
                                        if([[startDateDict objectForKey:@"year"] intValue]==currentYear){
                                            
                                            if([[startDateDict objectForKey:@"month"] intValue]>=currentMonth-1){
                                                //    NSMutableDictionary *tempResults=[[NSMutableDictionary alloc] initWithDictionary:results];
                                                //  [tempResults
                                                
                                                
                                                [[results objectForKey:@"positions"] setObject:tempDict forKey:@"position"];
                                                for (int j=0;j<totalConnectionsCount;j++){
                                                    
                                                    if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                        [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                                }
                                                
                                                //NSLog(@"%@",tempDict);
                                                
                                                //send it to events to celebrate group
                                                
                                                [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                                break;
                                            }
                                            
                                        }
                                    }
                                    
                                    //[[results objectForKey:@"positions"] setObject:tempDict forKey:@"position"];
                                    //[lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                    //break;
                                }
                            }
                        }
                    }
                    else if([[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"is-current"]){
                        if([[[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"is-current"] isEqualToString:@"true"]){
                            //NSLog(@"found..%@",[results objectForKey:@"first-name"]);
                            if([[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"start-date"]){
                                NSDictionary *startDateDict=[[[results objectForKey:@"positions"] objectForKey:@"position"] objectForKey:@"start-date"];
                                
                                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                                int currentMonth=[components month];
                                int currentYear=[components year];
                                [gregorianCalendar release];
                                
                                if([startDateDict objectForKey:@"year"]){
                                    if([[startDateDict objectForKey:@"year"] intValue]==currentYear){
                                        if([startDateDict objectForKey:@"month"]){
                                            if([[startDateDict objectForKey:@"month"] intValue]>=currentMonth-1){
                                                //NSLog(@"linkedIn Event received..%@",results);
                                                //send it to events to celebrate group
                                                
                                                for (int j=0;j<totalConnectionsCount;j++){
                                                    
                                                    if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                        [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                                }
                                                
                                                
                                                [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                            }
                                        }
                                        else{
                                            //NSLog(@"linkedIn Event received..%@",results);
                                            
                                            for (int j=0;j<totalConnectionsCount;j++){
                                                
                                                if([[results objectForKey:@"id"] isEqualToString:[[networkUpdates objectAtIndex:j]objectForKey:@"id"]])
                                                    [results setObject:[[networkUpdates objectAtIndex:j]objectForKey:@"update_key"] forKey:@"update_key"];
                                            }
                                            [lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                            //[lnkInGiftGivDelegate receivedLinkedInNewEvent:(NSMutableDictionary*)results];
                        }
                    }
                }
            }
            
        }  
        
        
        if(currentConnectionNum<totalConnectionsCount-1){
            currentConnectionNum++;
            while (currentConnectionNum<totalConnectionsCount-1){
                if(![[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"] isEqualToString:@"private"]){
                    if([self isLinkedInAuthorized])
                        [self getMemberProfile:[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
                    break;
                }
                
                else
                    currentConnectionNum++;
            }
            //[self getMemberProfile:[[networkUpdates objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
        }
        else if(currentConnectionNum==totalConnectionsCount-1){
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        }
       // NSLog(@"updates..%@",results);
    }
    else if (identifier == self.fetchLikesForUpdate){
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
    NSLog(@"++ LinkedIn engine reports failure for connection %@\n%@", identifier, [error localizedDescription]);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
   [lnkInGiftGivDelegate linkedInDidRequestFailed];
}


#pragma mark - RDLinkedInAuthorizationControllerDelegate

- (void)linkedInAuthorizationControllerSucceeded:(RDLinkedInAuthorizationController *)controller {
    
    [lnkInGiftGivDelegate linkedInLoggedIn];
    //[self fetchProfile];
}

- (void)linkedInAuthorizationControllerFailed:(RDLinkedInAuthorizationController *)controller {
    [lnkInGiftGivDelegate linkedInDidRequestFailed];
    NSLog(@"failed!");
}

- (void)linkedInAuthorizationControllerCanceled:(RDLinkedInAuthorizationController *)controller {
    [lnkInGiftGivDelegate linkedInDidCancelledLogin];
    NSLog(@"cancelled!");
}

@end


