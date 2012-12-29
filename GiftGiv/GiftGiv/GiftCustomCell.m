//
//  GiftCustomCell.m
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftCustomCell.h"

@implementation GiftCustomCell
@synthesize giftIcon_one;
@synthesize giftTitle_one;
@synthesize giftPrice_one;
@synthesize giftIcon_two;
@synthesize giftTitle_two;
@synthesize giftPrice_two;
@synthesize giftImg_one;
@synthesize giftImg_two;
@synthesize gift_coreText_one;
@synthesize gift_coreText_two;
@synthesize tableTagForCell;

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
    [giftImg_one release];
    [giftImg_two release];
    [giftIcon_one release];
    [giftTitle_one release];
    [giftPrice_one release];
    [giftIcon_two release];
    [giftTitle_two release];
    [giftPrice_two release];
    [gift_coreText_one release];
    [gift_coreText_two release];
    [super dealloc];
}
@end
