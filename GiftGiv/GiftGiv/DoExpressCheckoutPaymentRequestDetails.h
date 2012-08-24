//
//  PPMobileDoECReq.h
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


@interface DoExpressCheckoutPaymentRequestDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Token;
@property (nonatomic, retain) NSString *PayerID;
@property (nonatomic, assign) PaymentActionCodeType PaymentAction;
@property (nonatomic, readonly, retain) NSMutableArray *PaymentDetails;
@property (nonatomic, retain) ShippingOptions *UserSelectedOptions;
@property (nonatomic, assign) int ReturnFMFDetails;
@property (nonatomic, retain) NSString *GiftMessage;
@property (nonatomic, assign) BOOL GiftReceiptEnable;
@property (nonatomic, retain) NSString *GiftWrapName;
@property (nonatomic, assign) float GiftWrapAmount;
@property (nonatomic, retain) NSString *BuyerMarketingEmail;
@property (nonatomic, retain) NSString *SurveyQuestion;
@property (nonatomic, readonly, retain) NSMutableArray *SurveyChoiceSelected;
@property (nonatomic, retain) NSString *ButtonSource;

-(void)addPaymentDetails:(PaymentDetails *)paymentDetails;
-(void)addSurveyChoiceSelected:(NSString *)choice;

@end
