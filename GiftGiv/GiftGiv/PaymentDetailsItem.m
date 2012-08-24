//
//  PaymentDetailsItem.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PaymentDetailsItem.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

@implementation PaymentDetailsItem

InitAndDealloc

StringAccessor(Name)
StringAccessor(Description)
AmountAccessor(Amount)
StringAccessor(Number)
IntAccessor(Quantity)
AmountAccessor(Tax)
IntAccessor(ItemWeight)
IntAccessor(ItemLength)
IntAccessor(ItemWidth)
IntAccessor(ItemHeight)
GenericAccessor(EbayItemPaymentDetailsItem)
StringAccessor(ItemURL)
GenericAccessor(EnhancedItemData)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([key rangeOfString:@"Amount"].location != NSNotFound || [key rangeOfString:@"Tax"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	return buf;
}

@end
