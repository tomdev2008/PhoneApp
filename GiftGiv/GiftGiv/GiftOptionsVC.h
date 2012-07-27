//
//  GiftOptionsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageControl.h"
#import <QuartzCore/QuartzCore.h>
#import "GiftCustomCell.h"
#import "GiftCardDetailsVC.h"


@interface GiftOptionsVC : UIViewController{
    
    int giftCatNum;
    int totalCats;
    
    CATransition *tranAnimationForGiftCategories;
    UIImage* pageActiveImage;
    UIImage* pageInactiveImage;
    NSMutableArray *giftCategoriesList;
        
}
@property (retain, nonatomic) IBOutlet UIImageView *profilePicImg;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UITableView *giftsTable;
@property (retain, nonatomic) IBOutlet CustomPageControl *giftCategoryPageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *giftCategoriesScroll;
@property (retain, nonatomic) NSMutableArray *giftsList;

- (IBAction)backToEvents:(id)sender;
- (IBAction)giftCategoriesPaeControlAction:(id)sender;

- (void)swipingForGiftCategories:(int)swipeDirectionNum;
- (void)reloadTheContentForGifts;

- (CATransition *)getAnimationForGiftCategories:(NSString *)animationType;

@end
