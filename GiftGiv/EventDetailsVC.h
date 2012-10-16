//
//  EventDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 24/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsCustomCell.h"
#import "NSAttributedString+Attributes.h"
#import "GiftOptionsVC.h"
#import "Facebook_GiftGiv.h"
#import "MBProgressHUD.h"
#import "CustomDateDisplay.h"
#import "LinkedIn_GiftGiv.h"

@interface EventDetailsVC : UIViewController <UITableViewDelegate,UITableViewDataSource,Facebook_GiftGivDelegate,MBProgressHUDDelegate,LinkedIn_GiftGivDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *listOfComments;
    BOOL shouldLoadingPicsStop;
    Facebook_GiftGiv *fb_giftgiv_eventDetails;
    int linkedInLikes;
}
@property (retain, nonatomic) IBOutlet UIImageView *profileImgView;
@property (retain, nonatomic) IBOutlet UILabel *nameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventDateLbl;
@property (retain, nonatomic) IBOutlet UILabel *likesCommentsLbl;
@property (retain, nonatomic) IBOutlet UITableView *commentsTable;
@property (retain, nonatomic) IBOutlet UITextView *eventDescription;
@property (retain, nonatomic) IBOutlet UIImageView *eventImg;
@property (retain, nonatomic) IBOutlet UIScrollView *detailsScroll;


@property BOOL isPhotoTagged;

- (IBAction)backToEventsList:(id)sender;
- (IBAction)showGiftCategories:(id)sender;

#pragma mark - Progress HUD
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void) stopHUD;
#pragma mark -
- (void)loadProfilePictures;
@end
