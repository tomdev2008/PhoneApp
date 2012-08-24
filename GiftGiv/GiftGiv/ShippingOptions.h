//
//  ShippingOptionsType.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>

typedef enum ShippingCalculationModes {
	API_CALLBACK,
	API_FLATRATE,
} ShippingCalculationMode;

@interface ShippingOptions : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, assign) ShippingCalculationMode ShippingCalculationMode;
@property (nonatomic, assign) BOOL InsuranceOptionSelected;
@property (nonatomic, assign) BOOL ShippingOptionIsDefault;
@property (nonatomic, assign) float ShippingOptionAmount;
@property (nonatomic, retain) NSString *ShippingOptionName;

@end
