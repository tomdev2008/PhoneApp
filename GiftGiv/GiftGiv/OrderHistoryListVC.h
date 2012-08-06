//
//  OrderHistoryListVC.h
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListCustomCell.h"
#import "SettingsVC.h"
#import "HomeScreenVC.h"
#import "OrderHistoryDetailsVC.h"

@interface OrderHistoryListVC : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *orderHistoryTable;

- (IBAction)backToMenu:(id)sender;
- (IBAction)settingsAction:(id)sender;

@end
