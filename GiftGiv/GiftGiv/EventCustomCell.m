//
//  EventCustomCell.m
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "EventCustomCell.h"

@implementation EventCustomCell
@synthesize profileImg;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize dateLbl,profileId;
@synthesize bubbleIconForCommentsBtn;

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
    [profileId release];
    [profileImg release];
    [profileNameLbl release];
    [eventNameLbl release];
    [dateLbl release];
    [bubbleIconForCommentsBtn release];
    [super dealloc];
}
@end
