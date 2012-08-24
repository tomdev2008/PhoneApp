//
//  PaymentError.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "PaymentError.h"
#import "ECMacros.h"


@implementation PaymentError

InitAndDealloc

StringAccessor(ShortMessage)
StringAccessor(LongMessage)
StringAccessor(ErrorCode)
StringAccessor(SeverityCode)
StringAccessor(ErrorParameters)

@end
