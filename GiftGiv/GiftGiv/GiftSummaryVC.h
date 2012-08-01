//
//  GiftSummaryVC.h
//  GiftGiv
//
//  Created by Srinivas G on 01/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftSummaryVC : UIViewController

@property (retain, nonatomic) IBOutlet UIScrollView *giftSummaryScroll;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *giftPriceLbl;
@property (retain, nonatomic) IBOutlet UILabel *addressLbl;
@property (retain, nonatomic) IBOutlet UILabel *mailGiftToLbl;
@property (retain, nonatomic) IBOutlet UILabel *personalMsgLbl;
@property (retain, nonatomic) IBOutlet UILabel *recipientAddressHeadLbl;
@property (retain, nonatomic) IBOutlet UILabel *paymentBtnLbl;
@property (retain, nonatomic) IBOutlet UIButton *paymentBtn;
@property (retain, nonatomic) IBOutlet UILabel *disclosureLbl;

@property (retain, nonatomic) NSMutableDictionary *giftSummaryDict;

- (IBAction)backToRecipientForm:(id)sender;
- (IBAction)paymentBtnAction:(id)sender;

@end
