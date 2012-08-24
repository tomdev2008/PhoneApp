//
//  PPMobileDoECReq.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "DoExpressCheckoutPaymentRequestDetails.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

static NSString *PaymentActionCodeTypeStrings[] = {@"Authorization", @"Order", @"Sale"};

@implementation DoExpressCheckoutPaymentRequestDetails

InitAndDealloc

StringAccessor(Token)
StringAccessor(PayerID)
MutableArrayAccessor(PaymentDetails)
GenericAccessor1(UserSelectedOptions, ShippingOptions)
IntAccessor(ReturnFMFDetails)
StringAccessor(GiftMessage)
BooleanAccessor(GiftReceiptEnable)
StringAccessor(GiftWrapName)
AmountAccessor(GiftWrapAmount)
StringAccessor(BuyerMarketingEmail)
StringAccessor(SurveyQuestion)
MutableArrayAccessor1(SurveyChoiceSelected, NSString)
StringAccessor(ButtonSource)
EnumAccessor(PaymentAction, PaymentActionCodeType);

-(NSString *)description {
	NSAssert(self.Token.length > 0, @"Express Checkout Token not present.  You must first obtain a token from a successful call to SetExpressCheckout.");
	NSAssert(self.PayerID.length > 0, @"PayerID not defined.");
	NSAssert(self.PaymentDetails.count > 0, @"PaymentDetails not defined.");
	NSAssert(self.PaymentDetails.count <= 10, @"PaymentDetails contains more than 10 items.");
	
	NSMutableString *buf = [NSMutableString string];
	
	[buf appendString:@"<DoExpressCheckoutPaymentReq xmlns=\"urn:ebay:api:PayPalAPI\">\
	 <DoExpressCheckoutPaymentRequest>\
	 <Version xmlns=\"urn:ebay:apis:eBLBaseComponents\">60.0</Version>\
	 <DoExpressCheckoutPaymentRequestDetails xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([[dataDict valueForKey:key] isKindOfClass:[NSArray class]]) {
			for (NSObject *object in (NSArray *)[dataDict valueForKey:key]) {
				[buf appendFormat:@"<%@>%@</%@>", key, object, key];
			}
		} else if ([key rangeOfString:@"GiftWrapAmount"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	[buf appendString:@"</DoExpressCheckoutPaymentRequestDetails></DoExpressCheckoutPaymentRequest></DoExpressCheckoutPaymentReq>"];
	
	return buf;
}

@end
