//
//  OrderListCustomCell.h
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCustomCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *orderStatusLbl;
@property (retain, nonatomic) IBOutlet UILabel *orderDateLbl;

@end
