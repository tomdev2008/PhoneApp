//
//  PPMobileGetECRes.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "GetExpressCheckoutDetailsResponseDetails.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

static NSString *CheckoutStatusTypeStrings[] = {@"PaymentActionNotInitiated", @"PaymentActionFailed", @"PaymentActionInProgress", @"PaymentCompleted"};

@implementation GetExpressCheckoutDetailsResponseDetails

InitAndDealloc

StringAccessor(Token)
GenericAccessor(PayerInfo)
StringAccessor(Custom)
StringAccessor(InvoiceID)
StringAccessor(ContactPhone)
AmountAccessor(PayPalAdjustment)
StringAccessor(Note)
BooleanAccessor(RedirectRequired)
GenericAccessor1(UserSelectedOptions, ShippingOptions)
StringAccessor(GiftMessage)
BooleanAccessor(GiftReceiptEnable)
StringAccessor(GiftWrapName)
AmountAccessor(GiftWrapAmount)
StringAccessor(BuyerMarketingEmail)
StringAccessor(SurveyQuestion)
MutableArrayAccessor(PaymentDetails)
MutableArrayAccessor1(SurveyChoiceSelected, NSString)
EnumAccessor(CheckoutStatus, CheckoutStatusType)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([[dataDict valueForKey:key] isKindOfClass:[NSArray class]]) {
			for (NSObject *object in (NSArray *)[dataDict valueForKey:key]) {
				[buf appendFormat:@"<%@>%@</%@>", key, object, key];
			}
		} else if ([key rangeOfString:@"PayPalAdjustment"].location != NSNotFound || [key rangeOfString:@"GiftWrapAmount"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	return buf;
}

@end
