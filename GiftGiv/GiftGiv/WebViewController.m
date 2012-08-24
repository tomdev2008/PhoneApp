//
//  WebViewController.m
//  ExpressCheckout
//
//  This view controller handles displaying the PayPal login and review screens.
//

#import "WebViewController.h"
#import "PayPal.h"
#import "SuccessVC.h"
#import "GiftSummaryVC.h"
#import "GetExpressCheckoutDetailsResponseDetails.h"
#import "DoExpressCheckoutPaymentRequestDetails.h"
#import "DoExpressCheckoutPaymentResponseDetails.h"


@implementation WebViewController

@synthesize startURL, returnURL, cancelURL, step;
@dynamic loadingView;

- (id)initWithURL:(NSString *)theURL returnURL:(NSString *)theReturnURL cancelURL:(NSString *)theCancelURL {
    if (self = [super init]) {
		self.startURL = theURL;
		self.returnURL = theReturnURL;
		self.cancelURL = theCancelURL;
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:startURL]]];
	self.view = webView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
	//self.navigationItem.hidesBackButton = TRUE;
}

#define LOADING_TAG 6543
-(UIActivityIndicatorView *)loadingView {
	UIActivityIndicatorView *lv = (UIActivityIndicatorView *)[self.view viewWithTag:LOADING_TAG];
	if (lv == nil) {
		lv = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		[lv setHidesWhenStopped:TRUE];
		CGRect frame = lv.frame;
		frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.);
		frame.origin.y = round((self.view.frame.size.height - frame.size.height) / 2.);
		lv.frame = frame;
		lv.tag = LOADING_TAG;
		[self.view addSubview:lv];
	}
	return lv;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//self.loadingView;
	[self.navigationController setNavigationBarHidden:TRUE animated:FALSE];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:TRUE animated:FALSE];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.startURL = nil;
	self.returnURL = nil;
	self.cancelURL = nil;
	((UIWebView *)self.view).delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark payment result handling methods

-(void)paymentSuccess:(NSString *)transactionID {
		
	SuccessVC *paymentSuccess = [[[SuccessVC alloc] initWithNibName:@"SuccessVC" bundle:nil] autorelease];
	UINavigationController *navController = self.navigationController;
	//paymentSuccess.transactionID = transactionID;
	[navController popViewControllerAnimated:FALSE];
	[navController pushViewController:paymentSuccess animated:TRUE];	
}

-(void)paymentCanceled {
	[self.navigationController popViewControllerAnimated:TRUE];
    
    AlertWithMessageAndDelegate(@"Order cancelled", @"You canceled your order. Touch \"Pay with PayPal\" to try again.", nil);
	
}

-(void)paymentFailed {
	[self.navigationController popViewControllerAnimated:TRUE];
    
    AlertWithMessageAndDelegate(@"Order failed", @"Your order failed. Touch \"Pay with PayPal\" to try again.", nil);
	
}

#pragma mark UIWebViewDelegate methods

//In webView:shouldStartLoadWithRequest:navigationType: we intercept attempts to redirect to the return or cancel URL
//and instead transition to our own success screen or return to shopping cart screen.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request.URL absoluteString] lowercaseString];
	if (urlString.length > 0) {
		//80 is the default HTTP port.
		//The PayPal server may add the default port to the URL.
		//This will break our string comparisons.
		if ([request.URL.port intValue] == 80) {
			urlString = [urlString stringByReplacingOccurrencesOfString:@":80" withString:@""];
		}
		
		if ([urlString rangeOfString:@"_flow"].location != NSNotFound) {
			step++;
		}
		if ([urlString rangeOfString:[cancelURL lowercaseString]].location != NSNotFound) {
			[self paymentCanceled];
			return FALSE;
		}
		if ([urlString rangeOfString:[returnURL lowercaseString]].location != NSNotFound) {
			//In this example, we are doing the Express Checkout calls completely in the client.  This is discouraged
			//because it exposes the merchant API credentials within the iPhone application.
			//If we get this far, it means the user successfully logged in on PayPal's site and authorized payment.
			//Now we call getExpressCheckoutDetails and handle the response below in expressCheckoutResponseReceived:
			[[ECNetworkHandler sharedInstance] getExpressCheckoutDetailsWithToken:nil withDelegate:self]; //pass nil to use cached token
			return FALSE;
		}
	}
	return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.title = @"Connecting to PayPal...";
	[self.loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.title = [NSString stringWithFormat:@"Step %d", step];
	[self.loadingView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	self.title = @"Connection failed";
	[self.loadingView stopAnimating];
}


#pragma mark -
#pragma mark ExpressCheckoutResponseHandler methods

//In this example, we do the Express Checkout calls completely on the device.  This is not recommended because
//it requires the merchant API credentials to be stored in the app on the device, and this is a security risk.
- (void)expressCheckoutResponseReceived:(NSObject *)response {
	if ([response isKindOfClass:[NSError class]]) {
		//If we get back an error, display an alert.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment failed" 
														message:[(NSError *)response localizedDescription]
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if ([response isKindOfClass:[GetExpressCheckoutDetailsResponseDetails class]]) {
		//If we get back a GetExpressCheckoutDetailsResponseDetails object, create a
		//DoExpressCheckoutPaymentRequestDetails object and call doExpressCheckout, handling
		//the response below.
		GetExpressCheckoutDetailsResponseDetails *gres = (GetExpressCheckoutDetailsResponseDetails *)response;
		
		if (gres.PayerInfo.PayerID.length > 0) {
			DoExpressCheckoutPaymentRequestDetails *dreq = [[[DoExpressCheckoutPaymentRequestDetails alloc] init] autorelease];
			dreq.PayerID = gres.PayerInfo.PayerID;
			dreq.PaymentAction = PAYMENT_ACTION_SALE;
			for (PaymentDetails *paymentDetails in gres.PaymentDetails) {
				[dreq addPaymentDetails:paymentDetails];
			}
			[[ECNetworkHandler sharedInstance] doExpressCheckoutWithRequest:dreq withDelegate:self];
		} else {
			[self paymentFailed];
		}
	} else if ([response isKindOfClass:[DoExpressCheckoutPaymentResponseDetails class]]) {
		//If we get back a DoExpressCheckoutPaymentResponseDetails object, check for success
		//or failure and transition to the appropriate screen.
		DoExpressCheckoutPaymentResponseDetails *dres = (DoExpressCheckoutPaymentResponseDetails *)response;
		
		if (dres.PaymentInfo.count > 0 && ((PaymentInfo *)[dres.PaymentInfo objectAtIndex:0]).TransactionID.length > 0) {
			[self paymentSuccess:((PaymentInfo *)[dres.PaymentInfo objectAtIndex:0]).TransactionID];
		} else {
			[self paymentFailed];
		}
	}
}

@end
