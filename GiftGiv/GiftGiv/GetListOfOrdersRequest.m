//
//  GetListOfOrdersRequest.m
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetListOfOrdersRequest.h"

@implementation GetListOfOrdersRequest
@synthesize listOfOrdersDelegate;

-(void)getListOfOrdersRequest:(NSMutableURLRequest *)request{
	
    
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
    //NSLog(@"%@",convertedStr);
    //[theXML release];
    webData=(NSMutableData*)[convertedStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:webData];
	
	[xmlParser setDelegate:self];
    listOfOrders=[[NSMutableArray alloc]init];
	
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		[listOfOrdersDelegate receivedListOfOrder:listOfOrders];
	}
	[listOfOrders  release];
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[listOfOrdersDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
	if([argElementName isEqualToString:@"Table"]){
        order=[[OrderObject alloc]init];
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
	if([argElementName isEqualToString:@"Table"]){
        NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:order,@"OrderDetails", nil];
        [listOfOrders addObject:tempDict];
        [order release];
        [tempDict release];
        order=nil;
    }
    else if([argElementName isEqualToString:@"Id"]){
        order.orderId=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"Details"]){
        order.details=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    else if([argElementName isEqualToString:@"ProfilePictureUrl"]){
        order.profilePictureUrl=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        /*NSData *picData=[NSData dataWithContentsOfURL:[NSURL URLWithString:order.profilePictureUrl]];
        //NSLog(@"%@",order.profilePictureUrl);
        if(picData!=nil){
            order.profilePicImg=[UIImage imageWithData:picData];
        }
        else{
            order.profilePicImg=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
        }*/
    }
    else if([argElementName isEqualToString:@"RecipientName"]){
        order.recipientName=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"RecipientId"]){
        order.recipientId=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"Status"]){
        order.status=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"OrderUpdatedDate"]){
        order.orderUpdatedDate=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"UserMessage"]){
        order.userMessage=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"AddressLine1"]){
        order.addressLine1=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"AddressLine2"]){
        order.addressLine2=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"City"]){
        order.city=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"State"]){
        order.state=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"ZIP"]){
        order.zip=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"ItemId"]){
        order.itemId=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"Price"]){
        order.price=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"DateofCreation"]){
        order.dateofCreation=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"phone"]){
        order.phone=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"email"]){
        order.email=(NSMutableString*)[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
	
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
