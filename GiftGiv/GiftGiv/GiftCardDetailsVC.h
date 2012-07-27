//
//  GiftCardDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 27/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageAllocationObject.h"


@interface GiftCardDetailsVC : UIViewController<UIActionSheetDelegate>{
    CGPoint svos;
    int selectedPriceRow;
}
@property (retain, nonatomic) NSMutableArray *priceListArray;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UIToolbar *messageInputAccessoryView;
@property (retain, nonatomic) IBOutlet UIScrollView *giftDetailsScroll;
@property (retain, nonatomic) IBOutlet UITextView *personalMsgTxtView;
@property (retain, nonatomic) IBOutlet UILabel *sendMediaLbl;
@property (retain, nonatomic) IBOutlet UILabel *giftPriceLbl;
@property (retain, nonatomic) IBOutlet UILabel *priceSelectedLbl;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLbl;
@property (retain, nonatomic) IBOutlet UIView *priceRangePickerBgView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *prevNextSegmentControl;
@property (retain, nonatomic) IBOutlet UIPickerView *pricePicker;

- (IBAction)messageKeyBoardAction:(id)sender;
- (IBAction)senderDetailsScreenAction:(id)sender;
- (IBAction)sendMediaAction:(id)sender;
- (IBAction)priceSelectionAction:(id)sender;
- (IBAction)priceSelectionButtonActions:(id)sender;
- (IBAction)backToListOfGifts:(id)sender;
- (IBAction)previousNextPriceSegmentAction:(id)sender;

@end
