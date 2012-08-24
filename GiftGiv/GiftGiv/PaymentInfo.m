//
//  PaymentInfo.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PaymentInfo.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

static NSString *PaymentTransactionCodeTypeStrings[] = {@"cart", @"express-checkout"};
static NSString *PaymentCodeTypeStrings[] = {@"none", @"echeck", @"instant"};
static NSString *PaymentStatusCodeTypeStrings[] = {@"None", @"Canceled-Reversal", @"Completed", @"Denied", @"Expired",
	@"Failed", @"In-Progress", @"Partially-Refunded", @"Pending", @"Refunded", @"Reversed", @"Processed", @"Voided"};
static NSString *PendingStatusCodeTypeStrings[] = {@"none", @"address", @"authorization", @"echeck", @"intl",
	@"multi-currency", @"order", @"paymentreview", @"unilateral", @"verify", @"other"};
static NSString *ReasonCodeTypeStrings[] = {@"none", @"chargeback", @"guarantee", @"buyer-complaint", @"refund", @"other"};
static NSString *ProtectionEligibilityTypeStrings[] = {@"Eligible", @"PartiallyEligible", @"Ineligible"};

@implementation PaymentInfo

InitAndDealloc

StringAccessor(TransactionID)
StringAccessor(ParentTransactionID)
StringAccessor(ReceiptID)
StringAccessor(PaymentDate)
AmountAccessor(GrossAmount)
AmountAccessor(FeeAmount)
AmountAccessor(SettleAmount)
AmountAccessor(TaxAmount)
StringAccessor(ExchangeRate)
StringAccessor(EbayTransactionId)
StringAccessor(PaymentRequestID)
GenericAccessor(EnhancedPaymentInfo)
GenericAccessor(SellerDetails)
GenericAccessor(FMFDetails)
GenericAccessor(PaymentError)
EnumAccessor(TransactionType, PaymentTransactionCodeType)
EnumAccessor(PaymentType, PaymentCodeType)
EnumAccessor(PaymentStatus, PaymentStatusCodeType)
EnumAccessor(PendingReason, PendingStatusCodeType)
EnumAccessor(ReasonCode, ReasonCodeType)
EnumAccessor(ProtectionEligibility, ProtectionEligibilityType)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([key rangeOfString:@"Amount"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	return buf;
}

@end
