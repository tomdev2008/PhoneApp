//
//  AddressType.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "Address.h"
#import "ECMacros.h"

static NSString *AddressOwnerTypeStrings[] = {@"eBay", @"PayPal"};
static NSString *AddressStatusTypeStrings[] = {@"None", @"Confirmed", @"Unconfirmed"};

@implementation Address

InitAndDealloc

StringAccessor(Name)
StringAccessor(Street1)
StringAccessor(Street2)
StringAccessor(CityName)
StringAccessor(StateOrProvince)
StringAccessor(PostalCode)
StringAccessor(Country)
StringAccessor(CountryName)
StringAccessor(Phone)
StringAccessor(AddressID)
StringAccessor(ExternalAddressID)
EnumAccessor(AddressOwner, AddressOwnerType)
EnumAccessor(AddressStatus, AddressStatusType)

-(NSString *)description {
	NSMutableString *buf = [NSMutableString string];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
	}
	
	return buf;
}

@end
