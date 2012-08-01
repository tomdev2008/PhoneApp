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
#import "GiftSummaryVC.h"

@interface SendOptionsVC : UIViewController<UIActionSheetDelegate>{
    CGPoint svos;
    NSMutableArray *listOfStates;
    int selectedStateRow;
}

@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UIView *statePickerBgView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *stateSelSegmentCntl;
@property (retain, nonatomic) IBOutlet UIPickerView *statesPicker;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *recipientAddressLbl;
@property (retain, nonatomic) IBOutlet UIView *recipientAddressContentView;
@property (retain, nonatomic) IBOutlet UIView *streeAddress_oneBgView;
@property (retain, nonatomic) IBOutlet UITextField *streeAddress_oneTxtFld;
@property (retain, nonatomic) IBOutlet UIView *streetAddress_twoBgView;
@property (retain, nonatomic) IBOutlet UITextField *streetAddress_twoTxtFld;
@property (retain, nonatomic) IBOutlet UIView *cityBgView;
@property (retain, nonatomic) IBOutlet UITextField *cityTxtFld;
@property (retain, nonatomic) IBOutlet UILabel *stateLbl;
@property (retain, nonatomic) IBOutlet UIView *zipBgView;
@property (retain, nonatomic) IBOutlet UITextField *zipTxtFld;
@property (retain, nonatomic) IBOutlet UIView *recipientSMSContentView;
@property (retain, nonatomic) IBOutlet UIView *phoneNumBgView;
@property (retain, nonatomic) IBOutlet UITextField *phoneNumTxtFld;
@property (retain, nonatomic) IBOutlet UIView *emailBgView;
@property (retain, nonatomic) IBOutlet UIView *recipientemailContentView;
@property (retain, nonatomic) IBOutlet UITextField *emailTxtFld;
@property (retain, nonatomic) IBOutlet UITextView *requestMsgTxtView;
@property (retain, nonatomic) IBOutlet UIToolbar *keyboardAccessoryView;
@property (retain, nonatomic) IBOutlet UIScrollView *sendOptionsContentScroll;
@property (retain, nonatomic) IBOutlet UILabel *confirmBtnLbl;
@property (retain, nonatomic) IBOutlet UIButton *confirmBtn;
@property (retain, nonatomic) NSMutableDictionary *sendingInfoDict;
@property BOOL isSendElectronically;

- (IBAction)stateSelectionAction:(id)sender;
- (IBAction)recipientAddressOptionAction:(id)sender;
- (IBAction)resignKeyboardAction:(id)sender;
- (IBAction)backToGiftDetailsScreen:(id)sender;
- (IBAction)stateSelectionDone:(id)sender;
- (IBAction)stateSelectionNavigatorActions:(id)sender;
- (IBAction)confirmScreenAction:(id)sender;

-(void)refreshTheFormForOption:(int)optionIndex;
-(BOOL)validateMail:(NSString *)email;

@end
