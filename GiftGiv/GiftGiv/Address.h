//
//  AddressType.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>

typedef enum AddressStatusTypes {
	NONE,
	CONFIRMED,
	UNCONFIRMED,
} AddressStatusType;

typedef enum AddressOwnerTypes {
	OWNER_EBAY,
	OWNER_PAYPAL,
} AddressOwnerType;

@interface Address : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString *Street1;
@property (nonatomic, retain) NSString *Street2;
@property (nonatomic, retain) NSString *CityName;
@property (nonatomic, retain) NSString *StateOrProvince;
@property (nonatomic, retain) NSString *PostalCode;
@property (nonatomic, retain) NSString *Country;
@property (nonatomic, retain) NSString *CountryName;
@property (nonatomic, retain) NSString *Phone;
@property (nonatomic, retain) NSString *AddressID;
@property (nonatomic, retain) NSString *ExternalAddressID;
@property (nonatomic, assign) AddressOwnerType AddressOwner;
@property (nonatomic, assign) AddressStatusType AddressStatus;

@end
