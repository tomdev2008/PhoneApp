//
//  CoomonRequestCreationObject.m
//  GiftGiv
//
//  Created by Srinivas G on 07/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "CoomonRequestCreationObject.h"

@implementation CoomonRequestCreationObject

+(NSMutableURLRequest *)soapRequestMessage:(NSString *)soapMsg withAction:(NSString*)soapAction{
	NSURL *url = [NSURL URLWithString:WebServiceURL];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMsg length]];
	
	[urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[urlRequest addValue: [NSString stringWithFormat:@"http://tempuri.org/IGiftGivService/%@",soapAction] forHTTPHeaderField:@"SOAPAction"];
    
	[urlRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
	return urlRequest;
}
@end
