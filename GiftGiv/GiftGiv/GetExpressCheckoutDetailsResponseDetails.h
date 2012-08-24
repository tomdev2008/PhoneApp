//
//  PPMobileGetECRes.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "PayerInfo.h"
#import "ShippingOptions.h"
#import "PaymentDetails.h"

typedef enum CheckoutStatusTypes {
	PAYMENT_ACTION_NOT_INITIATED,
	PAYMENT_ACTION_FAILED,
	PAYMENT_ACTION_IN_PROGRESS,
	PAYMENT_COMPLETED,
} CheckoutStatusType;

@interface GetExpressCheckoutDetailsResponseDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Token;
@property (nonatomic, retain) PayerInfo *PayerInfo;
@property (nonatomic, retain) NSString *Custom;
@property (nonatomic, retain) NSString *InvoiceID;
@property (nonatomic, retain) NSString *ContactPhone;
@property (nonatomic, readonly, retain) NSMutableArray *PaymentDetails;
@property (nonatomic, assign) float PayPalAdjustment;
@property (nonatomic, retain) NSString *Note;
@property (nonatomic, assign) BOOL RedirectRequired;
@property (nonatomic, retain) ShippingOptions *UserSelectedOptions;
@property (nonatomic, assign) CheckoutStatusType CheckoutStatus;
@property (nonatomic, retain) NSString *GiftMessage;
@property (nonatomic, assign) BOOL GiftReceiptEnable;
@property (nonatomic, retain) NSString *GiftWrapName;
@property (nonatomic, assign) float GiftWrapAmount;
@property (nonatomic, retain) NSString *BuyerMarketingEmail;
@property (nonatomic, retain) NSString *SurveyQuestion;
@property (nonatomic, readonly, retain) NSMutableArray *SurveyChoiceSelected;

-(void)addPaymentDetails:(PaymentDetails *)paymentDetails;
-(void)addSurveyChoiceSelected:(NSString *)choice;

@end
