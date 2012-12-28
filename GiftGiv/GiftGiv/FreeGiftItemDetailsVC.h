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
#import "GiftItemObject.h"
#import "GetCachesPathForTargetFile.h"
#import "NSAttributedString+Attributes.h"
#import "GiftSummaryVC.h"
#import "Facebook_GiftGiv.h"
#import "HomeScreenVC.h"
#import "AddUserRequest.h"
#import "CoomonRequestCreationObject.h"

@interface FreeGiftItemDetailsVC : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,Facebook_GiftGivDelegate,AddUserRequestDelegate>{
    CGPoint svos;
    NSMutableArray *monthsArray,*daysArray;
    GfitZoomInView *zoomScrollView;
    Facebook_GiftGiv *fb_giftgiv_detailsScreen;
    int selectedSendOptionRow;
    NSMutableArray *listOfSendOptions;
}
- (IBAction)recipientAddressAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *txtEditBtn;

@property (retain, nonatomic) IBOutlet UILabel *confirmBtnLbl;
@property (retain, nonatomic) IBOutlet UIButton *confirmBtn;
@property (retain, nonatomic) IBOutlet UISegmentedControl *addEmailSMSSegment;

@property (retain, nonatomic) IBOutlet UILabel *recipientsAddressLbl;
@property (retain, nonatomic) IBOutlet UIPickerView *addressMailSMSPicker;
@property (retain, nonatomic) IBOutlet UIView *addressEmailSMSSelPickerBgView;
@property (retain, nonatomic) IBOutlet UIView *emailBgView;
@property (retain, nonatomic) IBOutlet UILabel *wallPostDescription;
- (IBAction)addressEmailSMSSelDoneAction:(id)sender;
- (IBAction)addressEmailSMSNavigatorAction:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *emailTxtField;

@property (retain, nonatomic) IBOutlet UIView *recipientemailContentView;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLabel;

@property (retain, nonatomic) IBOutlet UIView *giftMsgEditScreen;
@property (retain, nonatomic) IBOutlet UITextView *giftMsgTxtView;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) NSMutableDictionary *giftItemInfo;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UIScrollView *giftDetailsBgScroll;
@property (retain, nonatomic) IBOutlet UILabel *giftDetailsLbl;
@property (retain, nonatomic) IBOutlet UIView *innerViewForGiftItemDetails;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIPickerView *dodPicker;
- (IBAction)dodPickerAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *dodBgView;
@property (retain, nonatomic) IBOutlet UIView *detailsBgView;
@property (retain, nonatomic) IBOutlet UIToolbar *msgInputAccessoryView;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)backToGiftsList:(id)sender;
- (IBAction)sendOptionsScreenAction:(id)sender;
- (IBAction)giftMsgEditActions:(id)sender;
- (IBAction)editActionForTheMessage:(id)sender;
- (void)refreshTheFormForOption:(int)optionIndex;
- (BOOL)validateMail:(NSString *)email;

- (NSString *)getMonthName:(int)monthNum;
-(void)updateTheScreenRespectiveToMessageText:(NSString*)targetText;
@end
