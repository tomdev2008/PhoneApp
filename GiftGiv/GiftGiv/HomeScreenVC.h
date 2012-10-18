//
//  HomeScreenVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomPageControl.h"
#import "ImageAllocationObject.h"
#import "EventCustomCell.h"
#import "EventDetailsVC.h"
#import "GiftOptionsVC.h"
#import "SettingsVC.h"
#import "Facebook_GiftGiv.h"
#import "AddUserRequest.h"
#import "Constants.h"
#import "CheckNetwork.h"
#import "CoomonRequestCreationObject.h"
#import "CustomDateDisplay.h"
#import "OrderHistoryListVC.h"
#import "MBProgressHUD.h"
#import "GetEventsRequest.h"
#import "FacebookContactsReq.h"
#import "LinkedIn_GiftGiv.h"
#import "GetCachesPathForTargetFile.h"

@interface HomeScreenVC : UIViewController<UITableViewDelegate,UITableViewDataSource,Facebook_GiftGivDelegate,AddUserRequestDelegate,MBProgressHUDDelegate,GetEventsDelegate,UISearchBarDelegate,FacebookContactsReqDelegate,LinkedIn_GiftGivDelegate>

{
    int eventGroupNum;
    int totalGroups;
    CATransition *tranAnimationForEventGroups;
    MBProgressHUD *HUD;
    UIImage* pageActiveImage;
    UIImage* pageInactiveImage;
    
    int birthdayEventUserNoToAddAsUser;
    NSMutableArray *listOfBirthdayEvents; 
  
    NSMutableArray *allupcomingEvents;
    NSMutableArray *eventsToCelebrateArray;
    NSMutableArray *facebookContactsArray; 
    NSMutableArray *linkedInContactsArray;
    
    NSMutableArray *globalFacebookContacts;
   
           
    NSMutableArray *searchUpcomingEventsArray,*searchBirthdayEvents,*searchEventsToCelebrateArray,*searchFBContactsArray,*searchLkdContactsArray;
    
    
    NSMutableArray *categoryTitles;
    Facebook_GiftGiv *fb_giftgiv_home;
    LinkedIn_GiftGiv *lnkd_giftgiv_home;
    BOOL isEventsLoadingFromFB;
    BOOL isSearchEnabled;
    BOOL isFBContactsLoading;
    
    NSOperationQueue *picturesOperationQueue;
    
}
@property (retain, nonatomic) IBOutlet UISearchBar *contactsSearchBar;
@property (retain, nonatomic) IBOutlet UIView *contactsSearchView;

@property (retain, nonatomic) IBOutlet UIView *eventsBgView;
@property (retain, nonatomic) IBOutlet CustomPageControl *pageControlForEventGroups;
@property (retain, nonatomic) IBOutlet UITableView *eventsTable;
@property (retain, nonatomic) IBOutlet UILabel *eventTitleLbl;
//@property (retain, nonatomic) IBOutlet UILabel *eventTitle_2_Lbl;
//@property (retain, nonatomic) IBOutlet UITableView *events_2_Table;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain, nonatomic) IBOutlet UIView *searchBgView;
- (IBAction)settingsAction:(id)sender;
- (IBAction)pageControlActionForEventGroups:(id)sender;
- (IBAction)showListOfOrders:(id)sender;
- (void)swiping:(int)swipeDirectionNum;

- (CATransition *)getAnimationForEventGroup:(NSString *)animationType;

- (void)makeRequestToAddUserForBirthdays:(NSMutableDictionary*)userDetails;

//- (NSString*)updatedDateToBeDisplayedForTheEvent:(id)eventDate;

- (BOOL)checkWhetherEventExistInTheListOfEvents:(NSMutableDictionary*)eventsData;

- (void)sortEvents:(NSMutableArray*)listOfEvents eventCategory:(int)catNum;

- (void)storeAllupcomingsForSuccessScreen;
#pragma mark - Progress HUD
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void) stopHUD;
#pragma mark -

-(void)loadEventsData:(NSMutableArray*)sourceArray withCell:(EventCustomCell*)cell inTable:(UITableView*)table forIndexPath:(NSIndexPath*)indexPath;
- (IBAction)showSearchView:(id)sender;
- (IBAction)searchCancelAction:(id)sender;

-(void) makeRequestToLoadImagesUsingOperations;
-(BOOL)checkWhetherLinkedInEventExist:(NSMutableDictionary*)linkedInDict;
@end
