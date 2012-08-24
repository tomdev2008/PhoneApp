//
//  PPMobileDoECRes.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>
#import "PaymentInfo.h"


@interface DoExpressCheckoutPaymentResponseDetails : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *Token;
@property (nonatomic, readonly, retain) NSMutableArray *PaymentInfo;
@property (nonatomic, retain) NSString *Note;
@property (nonatomic, assign) BOOL RedirectRequired;
@property (nonatomic, assign) BOOL SuccessPageRedirectRequested;

-(void)addPaymentInfo:(PaymentInfo *)paymentInfo;

@end
