//
//  ValidationOfTheTokenRequest.h
//  GiftGiv
//
//  Created by Srinivas G on 11/29/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ValidationOfTheTokenRequest;

@protocol ValidationOfTheTokenRequestDelegate

-(void) statusOfValidation:(NSString*)response;
-(void) requestFailed;

@end
@interface ValidationOfTheTokenRequest : NSObject<NSXMLParserDelegate>
{
  	
    NSURLConnection *theConnection;
    
    NSMutableString *statusResponse;
	
	NSMutableString *currentElementValue; //parsed string
	NSMutableData *webData;  //data while parsing the response
}
@property(nonatomic,assign) id <ValidationOfTheTokenRequestDelegate> validateTokenDelegate;

//parsed the request which as parameter
-(void)validateTheTokenRequest:(NSMutableURLRequest *)request;
@end
