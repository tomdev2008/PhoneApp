//
//  OtherPaymentMethodDetails.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>


@interface OtherPaymentMethodDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@end
