//
//  PaymentDetailsItem.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "EbayItemPaymentDetailsItem.h"
#import "EnhancedItemData.h"


@interface PaymentDetailsItem : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, assign) float Amount;
@property (nonatomic, retain) NSString *Number;
@property (nonatomic, assign) int Quantity;
@property (nonatomic, assign) float Tax;
@property (nonatomic, assign) int ItemWeight;
@property (nonatomic, assign) int ItemLength;
@property (nonatomic, assign) int ItemWidth;
@property (nonatomic, assign) int ItemHeight;
@property (nonatomic, retain) EbayItemPaymentDetailsItem *EbayItemPaymentDetailsItem;
@property (nonatomic, retain) NSString *ItemURL;
@property (nonatomic, retain) EnhancedItemData *EnhancedItemData;

@end
