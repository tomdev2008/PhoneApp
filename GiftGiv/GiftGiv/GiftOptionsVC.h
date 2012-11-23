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
#import "UIImage+scaling.h"
#import "GetCachesPathForTargetFile.h"

@interface GiftOptionsVC : UIViewController<GiftCategoriesRequestDelegate,GiftItemsRequestDelegate,MBProgressHUDDelegate,UISearchBarDelegate>{
    
    int giftCatNum;
    int totalCats;
    MBProgressHUD *HUD;
    CATransition *tranAnimationForGiftCategories;
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
@property (retain, nonatomic) IBOutlet UILabel *categoryTitleLbl;
@property (retain, nonatomic) IBOutlet UIView *giftItemsBgView;

@property (retain, nonatomic) IBOutlet UIImageView *profilePicImg;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UITableView *giftsTable;
@property (retain, nonatomic) IBOutlet CustomPageControl *giftCategoryPageControl;


- (IBAction)backToEvents:(id)sender;
- (IBAction)giftCategoriesPaeControlAction:(id)sender;

- (void)swipingForGiftCategories:(int)swipeDirectionNum;

- (CATransition *)getAnimationForGiftCategories:(NSString *)animationType;

- (void)makeRequestToGetCategories;

#pragma mark - Progress HUD
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void) stopHUD;
#pragma mark -

-(void)loadCurrentGiftItemsForCategory :(NSString*)categoryId;
-(BOOL)checkWhetherGiftItemsAvailableInACategory:(NSString*)categoryId;
-(int)getTheGCDFirstNum:(int)width secondNum:(int)height;
@end
