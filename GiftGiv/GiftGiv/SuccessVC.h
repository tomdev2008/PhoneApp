//
//  SuccessVC.h
//  GiftGiv
//
//  Created by Srinivas G on 03/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenVC.h"
#import "EventCustomCell.h"
#import "GiftOptionsVC.h"

@interface SuccessVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UITableView *upcomingEventsTable;

- (IBAction)backToHome:(id)sender;
- (IBAction)onlineSite:(id)sender;

@end
