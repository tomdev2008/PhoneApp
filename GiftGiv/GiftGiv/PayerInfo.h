//
//  PayerInfo.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "PersonName.h"
#import "Address.h"

typedef enum PayerStatusTypes {
	VERIFIED,
	UNVERIFIED,
} PayerStatusType;

@interface PayerInfo : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Payer;
@property (nonatomic, retain) NSString *PayerID;
@property (nonatomic, assign) PayerStatusType PayerStatus;
@property (nonatomic, retain) PersonName *PayerName;
@property (nonatomic, retain) NSString *PayerCountry;
@property (nonatomic, retain) NSString *PayerBusiness;
@property (nonatomic, retain) Address *Address;

@end
