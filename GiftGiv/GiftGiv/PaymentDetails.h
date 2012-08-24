//
//  PaymentDetails.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "PaymentDetailsItem.h"


typedef enum PaymentActionCodeTypes {
	PAYMENT_ACTION_AUTHORIZATION,
	PAYMENT_ACTION_ORDER,
	PAYMENT_ACTION_SALE,
} PaymentActionCodeType;

@interface PaymentDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, assign) float OrderTotal;
@property (nonatomic, assign) float ItemTotal;
@property (nonatomic, assign) float ShippingTotal;
@property (nonatomic, assign) float InsuranceTotal;
@property (nonatomic, assign) float ShippingDiscount;
@property (nonatomic, assign) BOOL InsuranceOptionOffered;
@property (nonatomic, assign) float HandlingTotal;
@property (nonatomic, assign) float TaxTotal;
@property (nonatomic, retain) NSString *OrderDescription;
@property (nonatomic, retain) NSString *Custom;
@property (nonatomic, retain) NSString *InvoiceID;
@property (nonatomic, retain) NSString *NotifyURL;
@property (nonatomic, retain) Address *ShipToAddress;
@property (nonatomic, readonly, retain) NSMutableArray *PaymentDetailsItem;
@property (nonatomic, retain) NSString *NoteText;
@property (nonatomic, retain) NSString *TransactionId;
@property (nonatomic, retain) NSString *AllowedPaymentMethodType;
@property (nonatomic, assign) PaymentActionCodeType PaymentAction;
@property (nonatomic, retain) NSString *PaymentRequestID;

-(void)addPaymentDetailsItem:(PaymentDetailsItem *)paymentDetailsItem;

@end
