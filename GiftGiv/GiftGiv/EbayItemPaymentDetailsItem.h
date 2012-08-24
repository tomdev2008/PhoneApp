//
//  EbayItemPaymentDetailsItem.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>


@interface EbayItemPaymentDetailsItem : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *ItemNumber;
@property (nonatomic, retain) NSString *AuctionTransactionId;
@property (nonatomic, retain) NSString *OrderID;
@property (nonatomic, retain) NSString *CartID;

@end
