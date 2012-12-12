//
//  HomeScreenVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageControl.h"
#import "ImageAllocationObject.h"
#import "EventCustomCell.h"
#import "EventDetailsVC.h"
#import "GiftOptionsVC.h"
#import "SettingsVC.h"
#import "Facebook_GiftGiv.h"
#import "AddUserRequest.h"
#import "CheckNetwork.h"
#import "CoomonRequestCreationObject.h"
#import "CustomDateDisplay.h"
#import "OrderHistoryListVC.h"
#import "GetEventsRequest.h"
#import "FacebookContactsReq.h"
#import "LinkedIn_GiftGiv.h"
#import "GetCachesPathForTargetFile.h"
#import "AddUser_LinkedInRequest.h"
#import "LinkedInContactsRequest.h"
#import "AddNormalUserv_2_Request.h"

@interface HomeScreenVC : UIViewController<UITableViewDelegate,UITableViewDataSource,Facebook_GiftGivDelegate,AddUserRequestDelegate,GetEventsDelegate,UISearchBarDelegate, FacebookContactsReqDelegate,LinkedIn_GiftGivDelegate,AddUser_LinkedInRequestDelegate,LinkedInContactsReqDelegate,UIScrollViewDelegate,AddNormalUserv_2_RequestDelegate>

{
    int eventGroupNum;
    int totalGroups;
   
   
    UIImage* pageActiveImage;
    UIImage* pageInactiveImage;
    
    int birthdayEventUserNoToAddAsUser;
    NSMutableArray *listOfBirthdayEvents; 
  
    NSMutableArray *allupcomingEvents;
    NSMutableArray *eventsToCelebrateArray;
    NSMutableArray *listOfContactsArray;
    
    NSMutableArray *globalContactsList;
   
           
    NSMutableArray *searchContactsArray;
    
    
    NSMutableArray *categoryTitles;
    Facebook_GiftGiv *fb_giftgiv_home;
    LinkedIn_GiftGiv *lnkd_giftgiv_home;
    
    BOOL isEventsLoadingFromFB;
    BOOL isSearchEnabled;
    BOOL isFBContactsLoading;
    BOOL isLnContactsLoading;
    BOOL isCancelledImgOperations;
    BOOL isSearchSringAvailable;
    NSFileManager *fm;
    NSOperationQueue *picturesOperationQueue;
    dispatch_queue_t ImageLoader_Q, ImageLoader_Q_ForEvents;
    BOOL eventsPopulated;
}
@property (retain, nonatomic) IBOutlet UIScrollView *eventsBgScroll;
@property (retain, nonatomic) IBOutlet UISearchBar *contactsSearchBar;
@property (retain, nonatomic) IBOutlet UIView *contactsSearchView;
@property (retain, nonatomic) NSMutableArray *listOfContactsArray;
@property (retain, nonatomic) IBOutlet UIImageView *searchBgImg;

@property (retain, nonatomic) IBOutlet CustomPageControl *pageControlForEventGroups;

- (IBAction)settingsAction:(id)sender;
- (IBAction)showContactUsScreen:(id)sender;
- (IBAction)pageControlActionForEventGroups:(id)sender;
- (IBAction)showListOfOrders:(id)sender;

- (void)makeRequestToAddUserForFB:(NSMutableDictionary*)userDetails;

- (BOOL)checkWhetherEventExistInTheListOfEvents:(NSMutableDictionary*)eventsData;

- (void)sortEvents:(NSMutableArray*)listOfEvents eventCategory:(int)catNum;

- (void)storeAllupcomingsForSuccessScreen;


-(void)loadEventsData:(NSMutableArray*)sourceArray withCell:(EventCustomCell*)cell inTable:(UITableView*)table forIndexPath:(NSIndexPath*)indexPath;
- (IBAction)showSearchView:(id)sender;
- (IBAction)cancelTheSearch:(id)sender;

-(void)makeRequestToLoadImagesUsingOperations:(id)source;
-(void)checkAndStartOperationToDownloadPicForTheEvent:(NSDictionary*)eventData;
-(BOOL)checkWhetherLinkedInEventExist:(NSMutableDictionary*)linkedInDict;

//Selected the event to go for GiftOptions page
-(NSMutableDictionary*)collectTheDetailsOfSelectedEvent:(NSMutableDictionary*)sourceDict;

//Get the event details for the selected event
-(NSMutableDictionary*)collectDetailsToGetEventDetailsForTheSelectedEvent:(NSMutableDictionary*)souceDict;

@end
