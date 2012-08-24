//
//  PaymentError.h
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import <Foundation/Foundation.h>


@interface PaymentError : NSObject {
	@private
	NSMutableDictionary *dataDict;
}

@property (nonatomic, retain) NSString *ShortMessage;
@property (nonatomic, retain) NSString *LongMessage;
@property (nonatomic, retain) NSString *ErrorCode;
@property (nonatomic, retain) NSString *SeverityCode;
@property (nonatomic, retain) NSString *ErrorParameters;

@end
