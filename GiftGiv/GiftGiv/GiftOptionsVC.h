//
//  GiftOptionsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomPageControl.h"
#import "GiftCustomCell.h"
#import "GiftCardDetailsVC.h"
#import "Gift_GreetingCardDetailsVC.h"
#import "CoomonRequestCreationObject.h"
#import "GiftCategoriesRequest.h"
#import "GiftItemsRequest.h"
#import "MBProgressHUD.h"
#import "GetCachesPathForTargetFile.h"
#import "FreeGiftItemDetailsVC.h"
#import "UIImage+ProportionalFill.h"

@interface GiftOptionsVC : UIViewController<GiftCategoriesRequestDelegate,UITableViewDataSource,UITableViewDelegate,GiftItemsRequestDelegate,MBProgressHUDDelegate,UISearchBarDelegate>{
    
    int giftCatNum;
    int totalCats;
    MBProgressHUD *HUD;
    UIImage* pageActiveImage;
    UIImage* pageInactiveImage;
    NSMutableArray *giftCategoriesList;
    NSMutableArray *listOfAllGiftItems;
    NSMutableArray *currentGiftItems;
    NSFileManager *fm;
    BOOL isSearchEnabled;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchFld;
@property (retain, nonatomic) IBOutlet UIView *searchGiftsBgView;
@property (retain, nonatomic) IBOutlet UIImageView *profilePicImg;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet CustomPageControl *giftCategoryPageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *giftsBgScroll;
@property (retain, nonatomic) IBOutlet UIImageView *searchBgImg;
//Passing from HomeScreen controller as user selected the gift before event was selected
@property (retain, nonatomic) GiftItemObject *selectedGiftItemDetails;
- (IBAction)cancelTheSearch:(id)sender;

- (IBAction)backToEvents:(id)sender;
- (IBAction)giftCategoriesPaeControlAction:(id)sender;

- (void)makeRequestToGetCategories;

#pragma mark - Progress HUD
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void) stopHUD;
#pragma mark -

-(void)loadCurrentGiftItemsRespectiveToCategory;
-(BOOL)checkWhetherGiftItemsAvailableInACategory:(NSString*)categoryId;
-(int)getTheGCDFirstNum:(int)width secondNum:(int)height;

@end
