//
//  PaymentInfo.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "EnhancedPaymentInfo.h"
#import "SellerDetails.h"
#import "FMFDetails.h"
#import "PaymentError.h"

typedef enum PaymentTransactionCodeTypes {
	TRANSACTION_CART,
	TRANSACTION_EXPRESS_CHECKOUT,
} PaymentTransactionCodeType;

typedef enum PaymentCodeTypes {
	PAYMENT_TYPE_NONE,
	PAYMENT_TYPE_ECHECK,
	PAYMENT_TYPE_INSTANT,
} PaymentCodeType;

typedef enum PaymentStatusCodeTypes {
	PAYMENT_STATUS_NONE,
	PAYMENT_STATUS_CANCELED_REVERSAL,
	PAYMENT_STATUS_COMPLETED,
	PAYMENT_STATUS_DENIED,
	PAYMENT_STATUS_EXPIRED,
	PAYMENT_STATUS_FAILED,
	PAYMENT_STATUS_IN_PROGRESS,
	PAYMENT_STATUS_PARTIALLY_REFUNDED,
	PAYMENT_STATUS_PENDING,
	PAYMENT_STATUS_REFUNDED,
	PAYMENT_STATUS_REVERSED,
	PAYMENT_STATUS_PROCESSED,
	PAYMENT_STATUS_VOIDED,
} PaymentStatusCodeType;

typedef enum PendingStatusCodeTypes {
	PENDING_REASON_NONE,
	PENDING_REASON_ADDRESS,
	PENDING_REASON_AUTHORIZATION,
	PENDING_REASON_ECHECK,
	PENDING_REASON_INTL,
	PENDING_REASON_MULTI_CURRENCY,
	PENDING_REASON_ORDER,
	PENDING_REASON_PAYMENT_REVIEW,
	PENDING_REASON_UNILATERAL,
	PENDING_REASON_VERIFY,
	PENDING_REASON_OTHER,
} PendingStatusCodeType;

typedef enum ReasonCodeTypes {
	REASON_CODE_NONE,
	REASON_CODE_CHARGEBACK,
	REASON_CODE_GUARANTEE,
	REASON_CODE_BUYER_COMPLAINT,
	REASON_CODE_REFUND,
	REASON_CODE_OTHER,
} ReasonCodeType;

typedef enum ProtectionEligibilityTypes {
	PROTECTION_ELIGIBLE,
	PROTECTION_PARTIALLY_ELIGIBLE,
	PROTECTION_INELIGIBLE,
} ProtectionEligibilityType;


@interface PaymentInfo : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *TransactionID;
@property (nonatomic, retain) NSString *ParentTransactionID;
@property (nonatomic, retain) NSString *ReceiptID;
@property (nonatomic, assign) PaymentTransactionCodeType TransactionType;
@property (nonatomic, assign) PaymentCodeType PaymentType;
@property (nonatomic, retain) NSString *PaymentDate;
@property (nonatomic, assign) float GrossAmount;
@property (nonatomic, assign) float FeeAmount;
@property (nonatomic, assign) float SettleAmount;
@property (nonatomic, assign) float TaxAmount;
@property (nonatomic, retain) NSString *ExchangeRate;
@property (nonatomic, assign) PaymentStatusCodeType PaymentStatus;
@property (nonatomic, assign) PendingStatusCodeType PendingReason;
@property (nonatomic, assign) ReasonCodeType ReasonCode;
@property (nonatomic, assign) ProtectionEligibilityType ProtectionEligibility;
@property (nonatomic, retain) NSString *EbayTransactionId;
@property (nonatomic, retain) NSString *PaymentRequestID;
@property (nonatomic, retain) EnhancedPaymentInfo *EnhancedPaymentInfo;
@property (nonatomic, retain) SellerDetails *SellerDetails;
@property (nonatomic, retain) FMFDetails *FMFDetails;
@property (nonatomic, retain) PaymentError *PaymentError;

@end
