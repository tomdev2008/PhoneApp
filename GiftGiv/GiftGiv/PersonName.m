//
//  PersonName.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PersonName.h"
#import "ECMacros.h"


@implementation PersonName

InitAndDealloc

StringAccessor(Salutation)
StringAccessor(FirstName)
StringAccessor(MiddleName)
StringAccessor(LastName)
StringAccessor(Suffix)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
	}
	
	return buf;
}

@end
