//
//  SendEmailRequest.m
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "SendEmailRequest.h"

@implementation SendEmailRequest

@synthesize sendEmailDelegate;

-(void)makeReqToSendMail:(NSMutableURLRequest *)request{
	
    
	//Asynchronous URL connection
	theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if( theConnection ){
		webData = [[NSMutableData alloc] init];
	}
	else
		NSLog(@"theConnection is NULL");
}
#pragma mark -
#pragma mark Connection delegates
//connection received data

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	[webData appendData:data];
}

//Connection finished successful
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	NSString * theXML = [[NSString alloc] initWithData:(NSData*) webData encoding:NSASCIIStringEncoding];
	[webData release];
	NSString *updated_XML=[theXML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    [theXML release];
  	NSString *convertedStr=[updated_XML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
   
    webData=(NSMutableData*)[convertedStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:webData];
	
	[xmlParser setDelegate:self];
    receivedResponse=[[NSMutableString alloc]init];
	
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		[sendEmailDelegate responseForSendEmail:receivedResponse];
	}
	[receivedResponse  release];
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[sendEmailDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
	
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
	
	if(!currentElementValue) 
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
	
}

-(void) parser:(NSXMLParser*) parser didEndElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName
{
	
	if([argElementName isEqualToString:@"SendEmailResult"]){
        receivedResponse=currentElementValue;
    }
    
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
