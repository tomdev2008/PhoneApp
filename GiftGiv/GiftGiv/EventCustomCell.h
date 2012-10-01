//
//  EventCustomCell.h
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCustomCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *profileImg;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *dateLbl;
@property (retain,nonatomic) NSString *profileId;
@property (retain, nonatomic) IBOutlet UIButton *bubbleIconForCommentsBtn;

@end
