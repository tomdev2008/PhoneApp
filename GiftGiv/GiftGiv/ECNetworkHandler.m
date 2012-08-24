//
//  NetworkHandler.m
//  ExpressCheckout
//
//  Class for doing all EC network calls in client.  This is not recommended because the calls require
//  the merchant's API credentials to function, meaning the merchant's API credentials are stored in the
//  application binary, which is a security concern.
//
//  This class uses the classes in the ECObjects directory to serialize and parse the XML EC calls.
//

#import <objc/runtime.h>
#import "ECNetworkHandler.h"
#import "SetExpressCheckoutRequestDetails.h"
#import "GetExpressCheckoutDetailsResponseDetails.h"
#import "DoExpressCheckoutPaymentRequestDetails.h"
#import "DoExpressCheckoutPaymentResponseDetails.h"
#import "PayPal.h"


#define LIVE_REDIRECT_URL  @"https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout-mobile"
#define SANDBOX_REDIRECT_URL  @"https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout-mobile"

#define LIVE_URL @"https://api-3t.paypal.com/2.0/"
#define SANDBOX_URL @"https://api-3t.sandbox.paypal.com/2.0/"

@implementation ECNetworkHandler

@synthesize connection, data, delegate, ecToken, objectStack, currentElemVal, username, password, signature, userAction, currencyCode, deviceReferenceToken;
@dynamic redirectURL, ecURL;

//BEGIN SINGLETON STUFF

static ECNetworkHandler *instance = nil;

+(ECNetworkHandler *)sharedInstance {
	@synchronized(self) {
		if (instance == nil) {
			[[self alloc] init]; //assignment not done here
		}
	}
	return instance;
}

+(id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (instance == nil) {
			instance = [super allocWithZone:zone];
			return instance; //assign and return on first invocation
		}
	}
	return nil; //otherwise return nil
}

-(id)copyWithZone:(NSZone *)zone {
	return self;
}

-(id)retain {
	return self;
}

-(unsigned)retainCount {
	return UINT_MAX; //never release
}

-(void)release {
	//do nothing
}

-(id)autorelease {
	return self;
}

//END SINGLETON STUFF

-(id)init {
	if (self = [super init]) {
		//do any necessary initialization
		self.objectStack = [NSMutableArray array];
	}
	return self;
}

-(void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	self.connection = nil;
	self.data = nil;
	self.delegate = nil;
	self.ecToken = nil;
	self.objectStack = nil;
	self.currentElemVal = nil;
	self.username = nil;
	self.password = nil;
	self.signature = nil;
	self.currencyCode = nil;
	self.deviceReferenceToken = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark custom getters

- (NSString *)currencyCode {
	if (currencyCode.length == 0) {
		return @"USD";
	}
	return currencyCode;
}


#pragma mark -
#pragma mark objectStack manipulators

- (void)clear {
	[objectStack removeAllObjects];
	
	//BH - be sure all class definitions are loaded
	[PaymentDetails class];
	[PaymentDetailsItem class];
	[Address class];
	[ShippingOptions class];
	[PayerInfo class];
	[PersonName class];
	[BillingAgreementDetails class];
	[EnhancedCheckoutData class];
	[EnhancedItemData class];
	[OtherPaymentMethodDetails class];
	[BuyerDetails class];
	[SellerDetails class];
	[FMFDetails class];
	[FundingSourceDetails class];
	[EbayItemPaymentDetailsItem class];
	[PaymentInfo class];
	[EnhancedPaymentInfo class];
	[PaymentError class];
}

- (id)root {
	if (objectStack.count > 0) {
		return [objectStack objectAtIndex:0];
	}
	return nil;
}

- (id)peek {
	NSObject *object = [objectStack lastObject];
	if ((NSNull *)object == [NSNull null]) {
		return nil;
	}
	return object;
}

//modify the default push behavior to prevent pushing empty objects onto the root object
- (void)push:(id)object {
	if (object == nil) {
		if (objectStack.count > 1) {
			[objectStack addObject:[NSNull null]];
		}
	} else {
		[objectStack addObject:object];
	}
}

//modify the default pop behavior to prevent popping the root object
- (id)pop {
	NSObject *object = [self peek];
	if (objectStack.count > 1) {
		[objectStack removeLastObject];
	}
	return object;
}

#pragma mark Type determination

- (id)instanceOfProperty:(NSString *)elementName forClass:(NSObject *)container {
	objc_property_t property = class_getProperty([container class], [elementName UTF8String]);
	if (property != NULL) {
		const char *attrs = property_getAttributes(property);
		if (attrs != NULL) {
			static char buffer[256];
			const char *e = strchr(attrs, ',');
			if (e != NULL) {
				int len = (int)(e - attrs);
				memcpy(buffer, attrs, len);
				buffer[len] = '\0';
				
				e = strchr(buffer, '@');
				if (e == NULL) { //any basic type will be represented as a string
					return @"";
				}
				
				e = strstr(buffer, "NSMutableArray");
				if (e == NULL) { //this is an objective-c type that is not a mutable array
					//buffer contains string of the form T@"TypeName"
					buffer[len - 1] = '\0';
					e = strchr(buffer, '"');
					e++;
					NSString *className = [NSString stringWithFormat:@"%s", e];
					return [[[NSClassFromString(className) alloc] init] autorelease];
				}
				
				//deal with the case of a mutable array.  use the classOf<elementName> method (see ECMacros.h)
				NSString *selectorName = [NSString stringWithFormat:@"classOf%@", elementName];
				SEL sel = NSSelectorFromString(selectorName);
				if (sel != NULL && [container respondsToSelector:sel]) {
					return [[[(Class)[container performSelector:sel] alloc] init] autorelease];
				}
			}
		}
	}
#ifdef DEBUG
	NSLog(@"%@ does not contain %@", [container class], elementName);
#endif
	return nil;
}	

- (NSString *)redirectURL {
	if (ecToken.length > 0) {
		NSMutableString *url = [NSMutableString string];
		switch([PayPal getPayPalInst].environment) {
			default:
			case ENV_LIVE:
				[url appendString:LIVE_REDIRECT_URL];
				break;
			case ENV_SANDBOX:
				[url appendString:SANDBOX_REDIRECT_URL];
				break;
			case ENV_NONE:
				break;
		}

		NSString *action;
		switch (userAction) {
			case ECUSERACTION_COMMIT:
				action = @"commit";
				break;
			default:
			case ECUSERACTION_CONTINUE:
				action = @"continue";
				break;
		}
		
		[url appendFormat:@"&useraction=%@&token=%@", action, [ecToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if (deviceReferenceToken.length > 0) {
			[url appendFormat:@"&drt=%@", [deviceReferenceToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		
		NSLog(@"REDIRECT URL = [%@]", url);
		
		return url;
	}
	
	return nil;
}

- (NSString *)ecURL {
	switch ([PayPal getPayPalInst].environment) {
		default:
		case ENV_LIVE:
			return LIVE_URL;
		case ENV_SANDBOX:
			return SANDBOX_URL;
		case ENV_NONE:
			return nil;
	}
}

-(NSString *)toXML:(NSObject *)obj {
	NSMutableString *buf = [NSMutableString string];
	
	[buf appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\
	 <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
	 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\
	 xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\
	 <soap:Header>\
	 <RequesterCredentials xmlns=\"urn:ebay:api:PayPalAPI\">\
	 <Credentials xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
	
	if (username.length > 0) {
		[buf appendFormat:@"<Username>%@</Username>", username];
	}
	if (password.length > 0) {
		[buf appendFormat:@"<Password>%@</Password>", password];
	}
	if (signature.length > 0) {
		[buf appendFormat:@"<Signature>%@</Signature>", signature];
	}
	
	[buf appendString:@"</Credentials>\
	 </RequesterCredentials>\
	 </soap:Header>\
	 <soap:Body>"];
	
	[buf appendFormat:@"%@", obj];
	
	[buf appendString:@"</soap:Body></soap:Envelope>"];
	
	return buf;
}

- (void)performHttpPostWithObject:(NSObject *)obj {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.ecURL]];
	[request setHTTPMethod:@"POST"];
	NSString *reqXML = [self toXML:obj];
#ifdef DEBUG
	NSLog(@"*******Request******** to URL: %@\n%@", self.ecURL, reqXML);
#endif
	[request setHTTPBody:[reqXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	self.data = nil;
	
	if (self.connection) {
		[connection cancel];
	}
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)setExpressCheckoutWithRequest:(SetExpressCheckoutRequestDetails *)req withDelegate:(id<ExpressCheckoutResponseHandler>)del {
	self.ecToken = nil;
	self.delegate = del;
	
	[self clear];
	[self performHttpPostWithObject:req];
}

- (void)getExpressCheckoutDetailsWithToken:(NSString *)token withDelegate:(id<ExpressCheckoutResponseHandler>)del {
	if (token.length == 0) { //if no token present, set it
		token = ecToken;
	}
	self.delegate = del;
	
	NSAssert(token.length > 0, @"Express Checkout Token not present.  You must first obtain a token from a successful call to SetExpressCheckout.");
	
	NSString *req = [NSString stringWithFormat:@"<GetExpressCheckoutDetailsReq xmlns=\"urn:ebay:api:PayPalAPI\">\
					 <GetExpressCheckoutDetailsRequest><Version xmlns=\"urn:ebay:apis:eBLBaseComponents\">60.0</Version>\
					 <Token>%@</Token></GetExpressCheckoutDetailsRequest></GetExpressCheckoutDetailsReq>", token];
	
	[self clear];
	[self push:[[[GetExpressCheckoutDetailsResponseDetails alloc] init] autorelease]];
	[self performHttpPostWithObject:req];
}

- (void)doExpressCheckoutWithRequest:(DoExpressCheckoutPaymentRequestDetails *)req withDelegate:(id<ExpressCheckoutResponseHandler>)del {
	if (req.Token.length == 0) { //if no token present, set it
		req.Token = ecToken;
	}
	self.delegate = del;
	
	[self clear];
	[self push:[[[DoExpressCheckoutPaymentResponseDetails alloc] init] autorelease]];
	[self performHttpPostWithObject:req];
}

- (NSObject *)parseObjectFromSavedData {
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError) {
    }
	
	return objectStack.count > 0 ? [objectStack objectAtIndex:0] : ecToken;
}

//this gets called before data is sent and can be called multiple times if there is a redirect
-(void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
	[data setLength:0];
}

//the URL connection calls this repeatedly as data arrives
-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data == nil) {
		self.data = [NSMutableData data];
	} 
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
-(void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image 
	self.connection=nil;
	
#ifdef DEBUG
	NSLog(@"*******Response********\n%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
#endif	
	NSObject *obj = [self parseObjectFromSavedData];
	self.data = nil;
	
	if (delegate != nil) {
		id<ExpressCheckoutResponseHandler> listener = delegate;
		self.delegate = nil;
		
		[listener expressCheckoutResponseReceived:obj];
	}
}

//connection failed, pass the error back to the caller
-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	self.connection = nil;
	self.data = nil;
	
#ifdef DEBUG
	NSLog(@"*******Error********\n%@", [error localizedDescription]);
#endif	
	if (delegate != nil) {
		id<ExpressCheckoutResponseHandler> listener = delegate;
		self.delegate = nil;
		
		[listener expressCheckoutResponseReceived:error];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentElemVal = nil;	
	
	if ([self root] != nil) {
		[self push:[self instanceOfProperty:elementName forClass:[self peek]]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([self root] != nil) {
		NSObject *toStore = [self pop];
		if (toStore != nil) {
			if ([toStore isKindOfClass:[NSString class]]) {
				if (currentElemVal.length == 0) {
					return;
				}
				toStore = currentElemVal;
			}
			[[self peek] setValue:toStore forKey:elementName];
		}
	} else if ([@"Token" isEqualToString:elementName]) {
		self.ecToken = currentElemVal;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElemVal) {
        self.currentElemVal = [NSMutableString string];	
    }
    [currentElemVal appendString:string];	
}

@end
