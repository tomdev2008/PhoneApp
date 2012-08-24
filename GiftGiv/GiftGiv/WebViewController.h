//
//  WebViewController.h
//  ExpressCheckout
//
//  This view controller handles displaying the PayPal login and review screens.
//

#import <UIKit/UIKit.h>
#import "ECNetworkHandler.h"

//ExpressCheckoutResponseHandler is not part of the Express Checkout library and should
//generally not be used because doing the Express Checkout calls on the device requires
//that the merchant API credentials be stored in the executable, which is a security risk.
@interface WebViewController : UIViewController <UIWebViewDelegate, ExpressCheckoutResponseHandler> {
	@private
	NSString *startURL;
	NSString *returnURL;
	NSString *cancelURL;
	NSUInteger step;
}

@property (nonatomic, retain) NSString *startURL;
@property (nonatomic, retain) NSString *returnURL;
@property (nonatomic, retain) NSString *cancelURL;
@property (nonatomic, assign) NSUInteger step;
@property (nonatomic, readonly) UIActivityIndicatorView *loadingView;

- (id)initWithURL:(NSString *)theURL returnURL:(NSString *)theReturnURL cancelURL:(NSString *)theCancelURL;

@end
