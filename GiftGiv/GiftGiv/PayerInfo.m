//
//  PayerInfo.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PayerInfo.h"
#import "ECMacros.h"

static NSString *PayerStatusTypeStrings[] = {@"verified", @"unverified"};

@implementation PayerInfo

InitAndDealloc

StringAccessor(Payer)
StringAccessor(PayerID)
GenericAccessor1(PayerName, PersonName)
StringAccessor(PayerCountry)
StringAccessor(PayerBusiness)
GenericAccessor(Address)
EnumAccessor(PayerStatus, PayerStatusType)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
	}
	
	return buf;
}

@end
