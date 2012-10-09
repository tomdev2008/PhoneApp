//
//  Gift_GreetingCardDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageAllocationObject.h"
#import "SendOptionsVC.h"
#import "GiftItemObject.h"

@interface Gift_GreetingCardDetailsVC : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>{
    CGPoint svos;
    NSMutableArray *monthsArray,*daysArray;
}
@property (retain, nonatomic) IBOutlet UIView *detailsBgView;
@property (retain, nonatomic) IBOutlet UIScrollView *giftDetailsContentScroll;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UIView *innerViewForGreetDetails;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *giftDetailsLbl;
@property (retain, nonatomic) IBOutlet UIImageView *backGreetingImg;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIView *dodBgView;
@property (retain, nonatomic) IBOutlet UIPickerView *dodPicker;
@property (retain, nonatomic) IBOutlet UIImageView *frontGreetingImg;
@property (retain, nonatomic) IBOutlet UILabel *frontLbl;
@property (retain, nonatomic) IBOutlet UILabel *backLbl;
@property (retain, nonatomic) IBOutlet UIImageView *zoomInImgView;
@property (retain, nonatomic) IBOutlet UILabel *greetingNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *flowerImgView;
@property (retain, nonatomic) IBOutlet UILabel *greetingPrice;
@property (retain, nonatomic) IBOutlet UIToolbar *msgInputAccessoryView;
@property (retain, nonatomic) IBOutlet UITextView *personalMsgTxt;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) GiftItemObject *giftItemInfo;

@property BOOL isGreetingCard;
- (IBAction)dodPickerAction:(id)sender;
- (IBAction)sendOptionsScreenAction:(id)sender;
- (IBAction)msgKeyboardDismissAction:(id)sender;
- (IBAction)backToListOfGiftsAction:(id)sender;
- (IBAction)showDatePicker:(id)sender;

- (void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView;

-(NSString *)getMonthName:(int)monthNum;

@end
