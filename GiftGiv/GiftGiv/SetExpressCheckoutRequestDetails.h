//
//  SetExpressCheckoutRequestDetails.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "PaymentDetails.h"
#import "ShippingOptions.h"
#import "BillingAgreementDetails.h"
#import "EnhancedCheckoutData.h"
#import "OtherPaymentMethodDetails.h"
#import "BuyerDetails.h"
#import "FundingSourceDetails.h"

typedef enum NoShippingTypes {
	DISPLAY_SHIPPING,
	DO_NOT_DISPLAY_SHIPPING,
	GET_SHIPPING_FROM_BUYER_PROFILE,
} NoShippingType;

typedef enum SolutionTypes {
	SOLE,
	MARK,
} SolutionType;

typedef enum LandingPageTypes {
	BILLING,
	LOGIN,
} LandingPageType;

typedef enum ChannelTypes {
	MERCHANT,
	EBAY_ITEM,
} ChannelType;

@interface SetExpressCheckoutRequestDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *ReturnURL;
@property (nonatomic, retain) NSString *CancelURL;
@property (nonatomic, retain) NSString *cppHeaderImage;
@property (nonatomic, retain) NSString *cppHeaderBorderColor;
@property (nonatomic, retain) NSString *cppHeaderBackColor;
@property (nonatomic, retain) NSString *cppPayflowColor;
@property (nonatomic, readonly, retain) NSMutableArray *PaymentDetails;
@property (nonatomic, assign) int AllowNote;
@property (nonatomic, assign) int ReqConfirmShipping;
@property (nonatomic, assign) NoShippingType NoShipping;
@property (nonatomic, retain) NSString *Token;
@property (nonatomic, assign) float MaxAmount;
@property (nonatomic, retain) NSString *CallbackURL;
@property (nonatomic, assign) int CallbackTimeout;
@property (nonatomic, retain) ShippingOptions *FlatRateShippingOptions;
@property (nonatomic, assign) int AddressOverride;
@property (nonatomic, retain) NSString *LocaleCode;
@property (nonatomic, retain) NSString *PageStyle;
@property (nonatomic, retain) NSString *BuyerEmail;
@property (nonatomic, assign) SolutionType SolutionType;
@property (nonatomic, assign) LandingPageType LandingPage;
@property (nonatomic, assign) ChannelType ChannelType;
@property (nonatomic, retain) NSString *giropaySuccessURL;
@property (nonatomic, retain) NSString *giropayCancelURL;
@property (nonatomic, retain) NSString *BanktxnPendingURL;
@property (nonatomic, readonly, retain) NSMutableArray *BillingAgreementDetails;
@property (nonatomic, retain) EnhancedCheckoutData *EnhancedCheckoutData;
@property (nonatomic, readonly, retain) NSMutableArray *OtherPaymentMethods;
@property (nonatomic, retain) BuyerDetails *BuyerDetails;
@property (nonatomic, retain) NSString *BrandName;
@property (nonatomic, retain) FundingSourceDetails *FundingSourceDetails;
@property (nonatomic, retain) NSString *CustomerServiceNumber;
@property (nonatomic, assign) int GiftMessageEnable;
@property (nonatomic, assign) int GiftReceiptEnable;
@property (nonatomic, assign) int GiftWrapEnable;
@property (nonatomic, retain) NSString *GiftWrapName;
@property (nonatomic, assign) float GiftWrapAmount;
@property (nonatomic, assign) int BuyerEmailOptinEnable;
@property (nonatomic, retain) NSString *SurveyQuestion;
@property (nonatomic, retain) NSString *CallbackVersion;
@property (nonatomic, assign) int SurveyEnable;
@property (nonatomic, readonly, retain) NSMutableArray *SurveyChoice;

-(void)addPaymentDetails:(PaymentDetails *)paymentDetails;
-(void)addBillingAgreementDetails:(BillingAgreementDetails *)billingAgreementDetails;
-(void)addOtherPaymentMethods:(OtherPaymentMethodDetails *)otherPaymentMethodDetails;
-(void)addSurveyChoice:(NSString *)choice;

@end
