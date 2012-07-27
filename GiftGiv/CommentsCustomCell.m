//
//  CommentsCustomCell.m
//  GiftGiv
//
//  Created by Srinivas G on 24/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "CommentsCustomCell.h"

@implementation CommentsCustomCell
@synthesize profilePic;
@synthesize commentsLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [profilePic release];
    [commentsLbl release];
    [super dealloc];
}
@end
