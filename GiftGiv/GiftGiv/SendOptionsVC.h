//
//  SendOptionsVC.h
//  GiftGiv
//
//  Created by Srinivas G on 30/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ApplicationHelpers.h"

@interface SendOptionsVC : UIViewController<UIActionSheetDelegate>{
    CGPoint svos;
        
}

@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *recipientAddressLbl;
- (IBAction)recipientAddressOptionAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *recipientAddressContentView;
@property (retain, nonatomic) IBOutlet UIView *streeAddress_oneBgView;
@property (retain, nonatomic) IBOutlet UITextField *streeAddress_oneTxtFld;
@property (retain, nonatomic) IBOutlet UIView *streetAddress_twoBgView;
@property (retain, nonatomic) IBOutlet UITextField *streetAddress_twoTxtFld;
@property (retain, nonatomic) IBOutlet UIView *cityBgView;
@property (retain, nonatomic) IBOutlet UITextField *cityTxtFld;
@property (retain, nonatomic) IBOutlet UILabel *stateLbl;
- (IBAction)stateSelectionAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *zipBgView;
@property (retain, nonatomic) IBOutlet UITextField *zipTxtFld;

@property (retain, nonatomic) IBOutlet UIToolbar *keyboardAccessoryView;
- (IBAction)resignKeyboardAction:(id)sender;
- (IBAction)backToGiftDetailsScreen:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *sendOptionsContentScroll;
@property (retain, nonatomic) IBOutlet UILabel *confirmBtnLbl;
@property (retain, nonatomic) IBOutlet UIButton *confirmBtn;


- (IBAction)confirmScreenAction:(id)sender;

@property BOOL isSendElectronically;

-(void)refreshTheFormForOption:(int)optionIndex;

@end
