//
//  CommentsCustomCell.h
//  GiftGiv
//
//  Created by Srinivas G on 24/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface CommentsCustomCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *commentsLbl;

@end
