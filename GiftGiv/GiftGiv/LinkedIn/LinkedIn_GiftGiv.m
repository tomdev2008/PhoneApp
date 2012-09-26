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

#define SHARE_COMPLETED_NOTIFICATION @"LinkedInShareSuccess"
#define SHARE_FAILED_NOTIFICATION @"LinkedInShareFailed"

@interface LinkedIn_GiftGiv ()

@property (nonatomic, retain) RDLinkedInEngine* engine;
@property (nonatomic, retain) RDLinkedInConnectionID* fetchConnection;
@property (nonatomic, retain) RDLinkedInConnectionID* getConnections;
@property (nonatomic, retain) RDLinkedInConnectionID* shareConnection;
@property (nonatomic, retain) RDLinkedInConnectionID* memberProfileConnection;

- (void)fetchProfile;

@end

static LinkedIn_GiftGiv *sharedInstance = nil;

@implementation LinkedIn_GiftGiv


@synthesize engine;
@synthesize fetchConnection,getConnections,memberProfileConnection;
@synthesize shareConnection;
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
    
    self.fetchConnection = [self.engine profileForCurrentUser];
    
}
- (void)getNetworkConnections{
    self.getConnections = [self.engine  myconnections];
}
- (void)getMemberProfile:(NSString*)memberId{
    self.memberProfileConnection = [self.engine memberNetworkUpdates:memberId];
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
    NSLog(@"identifier..%@",identifier);
    //NSLog(@"++ LinkedIn engine reports success for connection %@", identifier);
    if( identifier == self.fetchConnection ) {
        NSMutableDictionary* profile = results;
        [lnkInGiftGivDelegate linkedInLoggedInWithUserDetails:profile];
    }
    else if (identifier == self.shareConnection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_COMPLETED_NOTIFICATION object:nil];
    }
    else if (identifier == self.getConnections){
        
        if([listOfConnections count]){
            [listOfConnections removeAllObjects];
            [listOfConnections release];
            listOfConnections=nil;
        }
        listOfConnections=[[NSMutableArray alloc]initWithArray:[results objectForKey:@"person"]];
        currentConnectionNum=0;
        totalConnectionsCount=[listOfConnections count];
        //[lnkInGiftGivDelegate receivedNetworkConnections:(NSMutableDictionary*)results];
        
        
        [self getMemberProfile:[[listOfConnections objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
        
        
        
    }
    else if (identifier == self.memberProfileConnection){
       
        if(currentConnectionNum<totalConnectionsCount-1){
            currentConnectionNum++;
            [self getMemberProfile:[[listOfConnections objectAtIndex:currentConnectionNum]objectForKey:@"id"]];
        }
        
        NSLog(@"updates..%@",results);
    }
}

- (void)linkedInEngine:(RDLinkedInEngine *)engine requestFailed:(RDLinkedInConnectionID *)identifier withError:(NSError *)error {
    NSLog(@"++ LinkedIn engine reports failure for connection %@\n%@", identifier, [error localizedDescription]);
    
    if (identifier == self.shareConnection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_FAILED_NOTIFICATION object:error];
    }
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


