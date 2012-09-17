//
//  FacebookContactsReq.m
//  GiftGiv
//
//  Created by Srinivas G on 12/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "FacebookContactsReq.h"

@implementation FacebookContactsReq
@synthesize fbContactsDelegate;

-(void)getFBContactsForRequest:(NSMutableURLRequest *)request{
    
	//Asynchronous URL connection
	/*theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if( theConnection ){
		webData = [[NSMutableData alloc] init];
	}
	else
		NSLog(@"theConnection is NULL");*/
    webData = [[NSMutableData alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"SampleXML" ofType:@"xml"]];
    
    NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:webData];
    [webData release];
	[xmlParser setDelegate:self];
    receivedResponse=[[NSMutableArray alloc]init];
	
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		
	}
}
#pragma mark -
#pragma mark Connection delegates
//connection received data

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	[webData appendData:data];
}

//Connection finished successful
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	 
    NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:webData];
    [webData release];
	[xmlParser setDelegate:self];
    receivedResponse=[[NSMutableArray alloc]init];
	
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		//[fbContactsDelegate receivedFBContacts:receivedResponse];
	}
    
	[receivedResponse  release];
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[fbContactsDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
    NSLog(@"%@,%@",argElementName,attributeDict);
    if([argElementName isEqualToString:@"FacebookUser"]){
        fbContact=[[FacebookContactObject alloc]init];
    }
        
}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    NSLog(@"found cdata");
    
    NSString *cDataStr=[[NSString alloc]initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    //NSLog(@"initial..%@",cDataStr);
    NSString *converted=[cDataStr stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-16\"?>\n" withString:@""];
    
    //NSLog(@"cDataStr..%@",[converted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
    NSXMLParser *xmlParser_2=[[NSXMLParser alloc]initWithData:[[converted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]dataUsingEncoding:NSUTF8StringEncoding]];
    [cDataStr release];
    xmlParser_2.delegate=self;
    if([xmlParser_2 parse]){
         NSLog(@"parsed successfully");
        [fbContactsDelegate receivedFBContacts:receivedResponse];
    }

    [xmlParser_2 release];
    
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
	
	if(!currentElementValue) 
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
	
}

-(void) parser:(NSXMLParser*) parser didEndElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName
{
    //NSLog(@"%@",argElementName);
    if([argElementName isEqualToString:@"UserId"])
        fbContact.userId=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    else if([argElementName isEqualToString:@"firstname"]){
        
        fbContact.firstname=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    
    else if([argElementName isEqualToString:@"lastname"]){
        fbContact.lastname=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"profilepicUrl"]){
        fbContact.profilepicUrl=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"dob"]){
        fbContact.dob=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"FacebookUser"]){
        [receivedResponse addObject:fbContact];
        [fbContact release];
    }
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
