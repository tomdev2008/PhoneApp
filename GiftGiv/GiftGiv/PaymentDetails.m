//
//  PaymentDetails.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PaymentDetails.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

static NSString *PaymentActionCodeTypeStrings[] = {@"Authorization", @"Order", @"Sale"};

@implementation PaymentDetails

InitAndDealloc

AmountAccessor(OrderTotal)
AmountAccessor(ItemTotal)
AmountAccessor(ShippingTotal)
AmountAccessor(InsuranceTotal)
AmountAccessor(ShippingDiscount)
BooleanAccessor(InsuranceOptionOffered)
AmountAccessor(HandlingTotal)
AmountAccessor(TaxTotal)
StringAccessor(OrderDescription)
StringAccessor(Custom)
StringAccessor(InvoiceID)
StringAccessor(NotifyURL)
GenericAccessor1(ShipToAddress, Address)
StringAccessor(NoteText)
StringAccessor(TransactionId)
StringAccessor(AllowedPaymentMethodType)
StringAccessor(PaymentRequestID)
MutableArrayAccessor(PaymentDetailsItem)
EnumAccessor(PaymentAction, PaymentActionCodeType);

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([[dataDict valueForKey:key] isKindOfClass:[NSArray class]]) {
			for (NSObject *object in (NSArray *)[dataDict valueForKey:key]) {
				[buf appendFormat:@"<%@>%@</%@>", key, object, key];
			}
		} else if ([key rangeOfString:@"Total"].location != NSNotFound || [key rangeOfString:@"Discount"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	return buf;
}

@end
