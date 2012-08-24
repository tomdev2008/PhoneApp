//
//  PPMobileDoECRes.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "DoExpressCheckoutPaymentResponseDetails.h"
#import "ECMacros.h"


@implementation DoExpressCheckoutPaymentResponseDetails

InitAndDealloc

StringAccessor(Token)
MutableArrayAccessor(PaymentInfo)
StringAccessor(Note)
BooleanAccessor(RedirectRequired)
BooleanAccessor(SuccessPageRedirectRequested)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([[dataDict valueForKey:key] isKindOfClass:[NSArray class]]) {
			for (NSObject *object in (NSArray *)[dataDict valueForKey:key]) {
				[buf appendFormat:@"<%@>%@</%@>", key, object, key];
			}
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	return buf;
}

@end
