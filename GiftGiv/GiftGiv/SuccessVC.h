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
#import "CustomDateDisplay.h"

@interface SuccessVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *upcomingEvents;
}
@property (retain, nonatomic) IBOutlet UITableView *upcomingEventsTable;
@property (retain, nonatomic) NSMutableArray *upcomingEvents;
//@property (nonatomic, retain) NSString *transactionID;


- (IBAction)backToHome:(id)sender;
- (IBAction)onlineSite:(id)sender;

-(void)loadProfilePictures;

@end
