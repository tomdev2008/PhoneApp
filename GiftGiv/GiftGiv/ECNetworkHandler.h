//
//  NetworkHandler.h
//  ExpressCheckout
//
//  Class for doing all EC network calls in client.  This is not recommended because the calls require
//  the merchant's API credentials to function, meaning the merchant's API credentials are stored in the
//  application binary, which is a security concern.
//
//  This class uses the classes in the ECObjects directory to serialize and parse the XML EC calls.
//

#import <Foundation/Foundation.h>

typedef enum ECUserActions {
	ECUSERACTION_CONTINUE,
	ECUSERACTION_COMMIT,
} ECUserAction;

@class SetExpressCheckoutRequestDetails;
@class DoExpressCheckoutPaymentRequestDetails;

@protocol ExpressCheckoutResponseHandler <NSObject>

@required
- (void)expressCheckoutResponseReceived:(NSObject *)response;

@end


@interface ECNetworkHandler : NSObject <NSXMLParserDelegate> {
@private
	NSURLConnection* connection;
	NSMutableData* data;
	id<ExpressCheckoutResponseHandler> delegate;
	
	NSString *ecToken;
	
	NSMutableString *currentElemVal;
	NSMutableArray *objectStack;
	
	NSString *username;
	NSString *password;
	NSString *signature;
	
	NSString *currencyCode;
	NSString *deviceReferenceToken;
	
	ECUserAction userAction;
}

@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) id<ExpressCheckoutResponseHandler> delegate;

@property (nonatomic, retain) NSString *ecToken;

@property (nonatomic, retain) NSMutableString *currentElemVal;
@property (nonatomic, retain) NSMutableArray *objectStack;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *signature;

@property (nonatomic, retain) NSString *currencyCode;
@property (nonatomic, retain) NSString *deviceReferenceToken;

@property (nonatomic, assign) ECUserAction userAction;

@property (nonatomic, readonly) NSString *redirectURL;
@property (nonatomic, readonly) NSString *ecURL;

+ (ECNetworkHandler *)sharedInstance; //singleton pattern because we only do one network call at a time
- (void)setExpressCheckoutWithRequest:(SetExpressCheckoutRequestDetails *)req withDelegate:(id<ExpressCheckoutResponseHandler>)del;
- (void)getExpressCheckoutDetailsWithToken:(NSString *)token withDelegate:(id<ExpressCheckoutResponseHandler>)del;
- (void)doExpressCheckoutWithRequest:(DoExpressCheckoutPaymentRequestDetails *)req withDelegate:(id<ExpressCheckoutResponseHandler>)del;

@end
