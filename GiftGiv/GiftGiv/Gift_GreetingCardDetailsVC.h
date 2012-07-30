//
//  Gift_GreetingCardDetailsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageAllocationObject.h"
#import "SendOptionsVC.h"

@interface Gift_GreetingCardDetailsVC : UIViewController{
    CGPoint svos;
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *giftDetailsContentScroll;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *backGreetingImg;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *frontGreetingImg;
@property (retain, nonatomic) IBOutlet UILabel *frontLbl;
@property (retain, nonatomic) IBOutlet UILabel *backLbl;
@property (retain, nonatomic) IBOutlet UIImageView *zoomInImgView;
@property (retain, nonatomic) IBOutlet UILabel *greetingNameLbl;
@property (retain, nonatomic) IBOutlet UIImageView *flowerImgView;
@property (retain, nonatomic) IBOutlet UILabel *greetingPrice;
@property (retain, nonatomic) IBOutlet UIToolbar *msgInputAccessoryView;
@property (retain, nonatomic) IBOutlet UITextView *personalMsgTxt;

@property BOOL isGreetingCard;

- (IBAction)sendOptionsScreenAction:(id)sender;
- (IBAction)msgKeyboardDismissAction:(id)sender;
- (IBAction)backToListOfGiftsAction:(id)sender;

@end
