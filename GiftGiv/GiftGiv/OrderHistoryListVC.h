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
#import "GetListOfOrdersRequest.h"
#import "CustomDateDisplay.h"
#import "MBProgressHUD.h"
#import "GetCachesPathForTargetFile.h"

@interface OrderHistoryListVC : UIViewController <UITableViewDataSource,UITableViewDelegate,GetListOfOrdersDelegate,MBProgressHUDDelegate>{
    NSMutableArray *ordersList;
    MBProgressHUD *HUD;
    NSFileManager *fm;
}

@property (retain, nonatomic) IBOutlet UITableView *orderHistoryTable;
@property (retain, nonatomic) IBOutlet UILabel *noHistoryLbl;
@property (retain, nonatomic) IBOutlet UIButton *startCelebBtn;

- (IBAction)backToMenu:(id)sender;
- (IBAction)settingsAction:(id)sender;

#pragma mark - progress hud
- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr;
- (void)stopHUD;
#pragma mark -
-(NSString*)updateDate:(id)sourceDate;
@end
