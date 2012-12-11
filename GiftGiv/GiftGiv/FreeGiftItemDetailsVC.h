//
//  FreeGiftItemDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 12/11/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "ImageAllocationObject.h"
#import <QuartzCore/QuartzCore.h>
#import "GfitZoomInView.h"
#import "GiftItemObject.h"
#import "GetCachesPathForTargetFile.h"
#import "NSAttributedString+Attributes.h"
#import "SendOptionsVC.h"

@interface FreeGiftItemDetailsVC : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,GfitZoomInViewDelegate>{
    CGPoint svos;
    NSMutableArray *monthsArray,*daysArray;
    GfitZoomInView *zoomScrollView;
}
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) GiftItemObject *giftItemInfo;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UIScrollView *giftDetailsBgScroll;
@property (retain, nonatomic) IBOutlet UIImageView *giftItemImg;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLbl;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *giftDetailsLbl;
@property (retain, nonatomic) IBOutlet UIView *innerViewForGiftItemDetails;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIButton *zoomDoneBtn;
@property (retain, nonatomic) IBOutlet UIPickerView *dodPicker;
- (IBAction)dodPickerAction:(id)sender;
@property (retain, nonatomic) IBOutlet UITextView *personalMsgTxt;
@property (retain, nonatomic) IBOutlet UIView *dodBgView;
@property (retain, nonatomic) IBOutlet UILabel *giftTitleInZoomScreen;
@property (retain, nonatomic) IBOutlet UIView *detailsBgView;
@property (retain, nonatomic) IBOutlet UIToolbar *msgInputAccessoryView;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)backToGiftsList:(id)sender;
- (IBAction)sendOptionsScreenAction:(id)sender;
- (IBAction)zoomDoneAction:(id)sender;
- (IBAction)msgKeyboardDismissAction:(id)sender;


- (void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView;

- (NSString *)getMonthName:(int)monthNum;

@end
