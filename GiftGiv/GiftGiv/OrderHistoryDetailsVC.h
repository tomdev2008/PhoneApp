//
//  OrderHistoryDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsVC.h"

@interface OrderHistoryDetailsVC : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *statusLbl;
@property (retain, nonatomic) IBOutlet UILabel *mailGiftToLbl;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg;
@property (retain, nonatomic) IBOutlet UIButton *askAgainBtn;
@property (retain, nonatomic) IBOutlet UILabel *askAddressLbl;
@property (retain, nonatomic) IBOutlet UIScrollView *orderDetailsScroll;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *statusHeadLbl;
@property (retain, nonatomic) IBOutlet UILabel *statusDateLbl;
@property (retain, nonatomic) IBOutlet UILabel *recipientAddressHeadLbl;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *messageLbl;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *giftPriceLbl;
@property (retain, nonatomic) IBOutlet UILabel *addressLbl;

- (IBAction)askAgainAction:(id)sender;
- (IBAction)backToOrdersList:(id)sender;
- (IBAction)settingsAction:(id)sender;

@end
