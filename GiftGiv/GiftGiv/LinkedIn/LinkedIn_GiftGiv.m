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
//@property (nonatomic, retain) RDLinkedInConnectionID* shareConnection;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchNetworkUpdates;

- (void)fetchProfile;

@end

static LinkedIn_GiftGiv *sharedInstance = nil;

@implementation LinkedIn_GiftGiv


@synthesize engine;
@synthesize fetchCurrentUserProfile,fetchMemberProfile,fetchNetworkUpdates;
//@synthesize shareConnection;
@synthesize lnkInGiftGivDelegate;

#pragma mark LinkedInShareHelper class methods
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
}
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
    self.fetchNetworkUpdates = [self.engine networkUpdatesWithType:type];
}
#pragma mark - RDLinkedInEngineDelegate

- (void)linkedInEngineAccessToken:(RDLinkedInEngine *)engine setAccessToken:(OAToken *)token {
    
    if( token ) {
        [token rd_storeInUserDefaultsWithServiceProviderName:@"LinkedIn" prefix:@"Demo"];
    }
    else {
        [OAToken rd_clearUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Demo"];
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
        
        NSMutableArray *tempUpdates=[[NSMutableArray alloc]initWithArray:[results objectForKey:@"update"]];
        
        for (NSMutableDictionary *updateDict in tempUpdates) {
            
            if([updateDict objectForKey:@"updated-fields"]){
                if([[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]){
                    int update_field_count=[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] count];
                   // NSLog(@"feed..%@, \nClass:%@",[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"],[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] class]);
                    if([[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]isKindOfClass:[NSArray class]]){
                        for(int i=0;i<update_field_count;i++){
                           
                            if([[[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"person/positions"]){
                              
                                [networkUpdates addObject:[[[updateDict objectForKey:@"update-content"]objectForKey:@"person"]objectForKey:@"id"]];
                                break;
                            }
                        }
                    }
                    else if([[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"]isKindOfClass:[NSDictionary class]]){
                        
                        if([[[[updateDict objectForKey:@"updated-fields"] objectForKey:@"update-field"] objectForKey:@"name"] isEqualToString:@"person/positions"]){
                            [networkUpdates addObject:[[[updateDict objectForKey:@"update-content"]objectForKey:@"person"]objectForKey:@"id"]];
                            break;
                        }
                    }
                }
            }
        }
        
        currentConnectionNum=0;
        totalConnectionsCount=[networkUpdates count];
        
        [self getMemberProfile:[networkUpdates objectAtIndex:currentConnectionNum]];
               
    }
    else if (identifier == self.fetchMemberProfile){
       
        NSLog(@"%@",results);  
        
        
        if(currentConnectionNum<totalConnectionsCount-1){
            currentConnectionNum++;
            [self getMemberProfile:[networkUpdates objectAtIndex:currentConnectionNum]];
        }
        
       // NSLog(@"updates..%@",results);
    }
}

- (void)linkedInEngine:(RDLinkedInEngine *)engine requestFailed:(RDLinkedInConnectionID *)identifier withError:(NSError *)error {
    NSLog(@"++ LinkedIn engine reports failure for connection %@\n%@", identifier, [error localizedDescription]);
    
   
}


#pragma mark - RDLinkedInAuthorizationControllerDelegate

- (void)linkedInAuthorizationControllerSucceeded:(RDLinkedInAuthorizationController *)controller {
    NSLog(@"success...");
    [lnkInGiftGivDelegate linkedInLoggedIn];
    [self fetchProfile];
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


