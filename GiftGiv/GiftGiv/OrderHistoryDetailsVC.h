//
//  OrderHistoryDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsVC.h"
#import "CoomonRequestCreationObject.h"
#import "GetGiftItemRequest.h"
#import "OrderObject.h"
#import "CustomDateDisplay.h"
#import "ImageAllocationObject.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface OrderHistoryDetailsVC : UIViewController<GetGiftItemDelegate>

@property (retain, nonatomic) IBOutlet UILabel *statusLbl;
@property (retain, nonatomic) IBOutlet UILabel *mailGiftToLbl;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg;
@property (retain, nonatomic) IBOutlet UIScrollView *orderDetailsScroll;
@property (retain, nonatomic) IBOutlet UILabel *giftNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *statusHeadLbl;
@property (retain, nonatomic) IBOutlet UILabel *statusDateLbl;
@property (retain, nonatomic) IBOutlet UILabel *recipientAddressHeadLbl;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *thoughtFulMessageLbl;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *msgHeadLbl;
@property (retain, nonatomic) IBOutlet UILabel *messageLbl;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *giftPriceLbl;
@property (retain, nonatomic) IBOutlet UILabel *addressLbl;
@property (retain, nonatomic) OrderObject *orderDetails;


- (IBAction)backToOrdersList:(id)sender;
- (IBAction)settingsAction:(id)sender;

- (void)loadGiftImage:(NSString*)imgURL forAnObject:(UIImageView*)targetImgView;
- (NSString*)updateDate:(id)sourceDate;
@end
