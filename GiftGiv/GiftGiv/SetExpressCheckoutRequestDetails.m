//
//  SetExpressCheckoutRequestDetails.m
//  ExpressCheckout
//
//  Class used for serializing and parsing EC network calls.
//  Merchant apps should not do the EC network calls within the iPhone application, because
//  this would require the merchant's API credentials to be hardcoded in the app, which is
//  a security concern.
//

#import "SetExpressCheckoutRequestDetails.h"
#import "ECMacros.h"
#import "ECNetworkHandler.h"

static NSString *SolutionTypeStrings[] = {@"Sole", @"Mark"};
static NSString *LandingPageTypeStrings[] = {@"LandingPage", @"Billing", @"Login"};
static NSString *ChannelTypeStrings[] = {@"Merchant", @"eBayItem"};

#define LOCALE_CODE @"LocaleCode"

@implementation SetExpressCheckoutRequestDetails

InitAndDealloc

StringAccessor(ReturnURL)
StringAccessor(CancelURL)
StringAccessor1(cppHeaderImage, @"cpp-header-image")
StringAccessor1(cppHeaderBorderColor, @"cpp-header-border-color")
StringAccessor1(cppHeaderBackColor, @"cpp-header-back-color")
StringAccessor1(cppPayflowColor, @"cpp-payflow-color")
IntAccessor(AllowNote)
IntAccessor(ReqConfirmShipping)
TypedefAccessor(NoShipping, NoShippingType)
StringAccessor(Token)
AmountAccessor(MaxAmount)
StringAccessor(CallbackURL)
IntAccessor(CallbackTimeout)
GenericAccessor1(FlatRateShippingOptions, ShippingOptions)
IntAccessor(AddressOverride)
StringAccessor(PageStyle)
StringAccessor(BuyerEmail)
StringAccessor(giropaySuccessURL)
StringAccessor(giropayCancelURL)
StringAccessor(BanktxnPendingURL)
GenericAccessor(EnhancedCheckoutData)
GenericAccessor(BuyerDetails)
StringAccessor(BrandName)
GenericAccessor(FundingSourceDetails)
StringAccessor(CustomerServiceNumber)
IntAccessor(GiftMessageEnable)
IntAccessor(GiftReceiptEnable)
IntAccessor(GiftWrapEnable)
StringAccessor(GiftWrapName)
AmountAccessor(GiftWrapAmount)
IntAccessor(BuyerEmailOptinEnable)
StringAccessor(SurveyQuestion)
StringAccessor(CallbackVersion)
IntAccessor(SurveyEnable)
MutableArrayAccessor(PaymentDetails)
MutableArrayAccessor(BillingAgreementDetails)
MutableArrayAccessor1(OtherPaymentMethods, OtherPaymentMethodDetails)
MutableArrayAccessor1(SurveyChoice, NSString)
EnumAccessor(SolutionType, SolutionType)
EnumAccessor(LandingPage, LandingPageType);
EnumAccessor(ChannelType, ChannelType);

@dynamic LocaleCode;

static NSString *supportedLocales[] = {@"AU", @"AT", @"BE", @"CA", @"CH", @"CN", @"DE", @"ES", @"GB", @"FR", @"IT", @"NL", @"PL", @"US"};

-(NSString *)LocaleCode {
	NSString *code = [dataDict valueForKey:LOCALE_CODE];
	for (int i = 0; i < sizeof(supportedLocales)/sizeof(NSString *); i++) {
		if ([supportedLocales[i] isEqualToString:code]) {
			return code;
		}
	}
	return @"US";
}

-(void)setLocaleCode:(NSString *)code {
	for (int i = 0; i < sizeof(supportedLocales)/sizeof(NSString *); i++) {
		if ([supportedLocales[i] isEqualToString:code]) {
			[dataDict setValue:code forKey:LOCALE_CODE];
		}
	}
}

-(NSString *)description {
	NSAssert(self.ReturnURL.length > 0, @"ReturnURL not defined.");
	NSAssert(self.CancelURL.length > 0, @"CancelURL not defined.");
	NSAssert(self.PaymentDetails.count > 0, @"PaymentDetails not defined.");
	NSAssert(self.PaymentDetails.count <= 10, @"PaymentDetails contains more than 10 items.");
	
	NSMutableString *buf = [NSMutableString string];
	
	[buf appendString:@"<SetExpressCheckoutReq xmlns=\"urn:ebay:api:PayPalAPI\">\
	 <SetExpressCheckoutRequest>\
	 <Version xmlns=\"urn:ebay:apis:eBLBaseComponents\">60.0</Version>\
	 <SetExpressCheckoutRequestDetails xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
	
	for (NSString *key in [dataDict keyEnumerator]) {
		if ([[dataDict valueForKey:key] isKindOfClass:[NSArray class]]) {
			for (NSObject *object in (NSArray *)[dataDict valueForKey:key]) {
				[buf appendFormat:@"<%@>%@</%@>", key, object, key];
			}
		} else if ([key rangeOfString:@"MaxAmount"].location != NSNotFound || [key rangeOfString:@"GiftWrapAmount"].location != NSNotFound) {
			[buf appendFormat:@"<%@ currencyID=\"%@\">%@</%@>", key, [ECNetworkHandler sharedInstance].currencyCode, [dataDict valueForKey:key], key];
		} else {
			[buf appendFormat:@"<%@>%@</%@>", key, [dataDict valueForKey:key], key];
		}
	}
	
	[buf appendString:@"</SetExpressCheckoutRequestDetails></SetExpressCheckoutRequest></SetExpressCheckoutReq>"];
	
	return buf;
}

@end
