//
//  LinkedInContactsRequest.m
//  GiftGiv
//
//  Created by Srinivas G on 10/30/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "LinkedInContactsRequest.h"

@implementation LinkedInContactsRequest
@synthesize lnContactsDelegate;

-(void)getLnContactsForRequest:(NSMutableURLRequest *)request{
    
	//Asynchronous URL connection
	theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if( theConnection ){
		webData = [[NSMutableData alloc] init];
	}
	else
		GGLog(@"theConnection is NULL");
    
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
    
	[xmlParser parse];
    
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[lnContactsDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
    
    if([argElementName isEqualToString:@"FacebookUser"]){
        lnContact=[[FacebookContactObject alloc]init];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
	
}

-(void) parser:(NSXMLParser*) parser didEndElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName
{
    //GGLog(@"%@,%@",argElementName,currentElementValue);
    if([argElementName isEqualToString:@"GetLinkedInListResult"]){
        
        currentElementValue=(NSMutableString*)[currentElementValue stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-16\"?>" withString:@""];
        
        receivedResponse=[[NSMutableArray alloc]init];
        
        
        NSXMLParser *tempParaser=[[NSXMLParser alloc]initWithData:[currentElementValue dataUsingEncoding:NSUTF8StringEncoding]];
        currentElementValue=nil;
        tempParaser.delegate=self;
        if([tempParaser parse]){
            GGLog(@"parsed successfully");
            //if([fbContactsDelegate respondsToSelector(receivedFBContacts:) withObject:receivedResponse])
            [lnContactsDelegate receivedLnContacts:receivedResponse];
        }
        else
            GGLog(@"parsing failed..");
        [receivedResponse  release];
        [tempParaser release];
        
    }
    
    
    else if([argElementName isEqualToString:@"UserId"])
        lnContact.userId=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    else if([argElementName isEqualToString:@"firstname"]){
        
        lnContact.firstname=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    
    else if([argElementName isEqualToString:@"lastname"]){
        lnContact.lastname=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"profilepicUrl"]){
        lnContact.profilepicUrl=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"dob"]){
        //0001-01-01T00:00:00
        NSString *dateOfBirth=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //GGLog(@"%@",dateOfBirth);
        lnContact.dob=[[dateOfBirth componentsSeparatedByString:@"T"] objectAtIndex:0];
    }
    else if([argElementName isEqualToString:@"location"]){
        
        lnContact.location=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"FacebookUser"]){
        [receivedResponse addObject:lnContact];
        [lnContact release];
    }
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
