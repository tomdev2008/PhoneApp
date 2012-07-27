//
//  HomeScreenVC.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomPageControl.h"
#import "ImageAllocationObject.h"
#import "EventCustomCell.h"
#import "EventDetailsVC.h"
#import "GiftOptionsVC.h"

@interface HomeScreenVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    int eventGroupNum;
    
    CATransition *tranAnimationForEventGroups;
    
    UIImage* pageActiveImage;
    UIImage* pageInactiveImage;
}

@property (retain, nonatomic) IBOutlet UIView *eventsBgView;
@property (retain, nonatomic) IBOutlet CustomPageControl *pageControlForEventGroups;
@property (retain, nonatomic) IBOutlet UITableView *eventsTable;
@property (retain, nonatomic) IBOutlet UILabel *eventTitleLbl;

- (IBAction)settingsAction:(id)sender;
- (IBAction)pageControlActionForEventGroups:(id)sender;

- (void)swiping:(int)swipeDirectionNum;

- (CATransition *)getAnimationForEventGroup:(NSString *)animationType;

@end
