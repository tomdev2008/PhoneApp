//
//  OrderListCustomCell.m
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "OrderListCustomCell.h"

@implementation OrderListCustomCell
@synthesize profilePic;
@synthesize profileNameLbl;
@synthesize orderStatusLbl;
@synthesize orderDateLbl;

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
    [profileNameLbl release];
    [orderStatusLbl release];
    [orderDateLbl release];
    [super dealloc];
}
@end
