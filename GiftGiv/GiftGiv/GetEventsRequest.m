//
//  GetEventsRequest.m
//  GiftGiv
//
//  Created by Srinivas G on 30/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetEventsRequest.h"

@implementation GetEventsRequest


@synthesize eventsDelegate;

-(void)getListOfEvents:(NSMutableURLRequest *)request{
	
    
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
    
	listOfEvents=[[NSMutableArray alloc]init];
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		[eventsDelegate receivedAllEvents:listOfEvents];
	}
	[listOfEvents  release];
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[eventsDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
    
	if([argElementName isEqualToString:@"Event_Master"]){
        event=[[EventObject alloc]init];
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
   
	if([argElementName isEqualToString:@"Event_Master"]){
       
        [listOfEvents addObject:event];
        [event release];
        event=nil;
    }
    else if([argElementName isEqualToString:@"UserId"]){
        event.userId=currentElementValue;
    }
    else if([argElementName isEqualToString:@"FB_Id"]){
        event.fb_FriendId=currentElementValue;
    }
    else if([argElementName isEqualToString:@"FB_EventId"]){
        event.fb_EventId=currentElementValue;
    }
    else if([argElementName isEqualToString:@"FB_Name"]){
        event.fb_Name=currentElementValue;
    }
    else if([argElementName isEqualToString:@"fb_Picture"]){
        event.fb_Picture=currentElementValue;
    }
    else if([argElementName isEqualToString:@"EventType"]){
        event.eventType=currentElementValue;
    }
    else if([argElementName isEqualToString:@"EventName"]){
        event.eventName=currentElementValue;
    }
    else if([argElementName isEqualToString:@"EventOccuringDate"]){
        event.eventdate=currentElementValue;
    }
    else if([argElementName isEqualToString:@"IsEventFromQuery"]){
        event.isEventFromQuery=currentElementValue;
    }
    
	
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
