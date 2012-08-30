//
//  GiftCustomCell.h
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftCustomCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *giftIcon_one;
@property (retain, nonatomic) IBOutlet UILabel *giftTitle_one;
@property (retain, nonatomic) IBOutlet UILabel *giftPrice_one;
@property (retain, nonatomic) IBOutlet UIButton *giftIcon_two;
@property (retain, nonatomic) IBOutlet UILabel *giftTitle_two;
@property (retain, nonatomic) IBOutlet UILabel *giftPrice_two;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg_one;
@property (retain, nonatomic) IBOutlet UIImageView *giftImg_two;
@end
