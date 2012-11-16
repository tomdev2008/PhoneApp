//
//  GetGiftItemRequest.m
//  GiftGiv
//
//  Created by Srinivas G on 28/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GetGiftItemRequest.h"

@implementation GetGiftItemRequest

@synthesize giftItemDelegate;

-(void)makeGiftItemRequest:(NSMutableURLRequest *)request{
	
    
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
	
	NSString * theXML = [[NSString alloc] initWithData:(NSData*) webData encoding:NSASCIIStringEncoding];
	[webData release];
	NSString *updated_XML=[theXML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    [theXML release];
  	NSString *convertedStr=[updated_XML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    //GGLog(@"%@",convertedStr);
    webData=(NSMutableData*)[convertedStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:webData];
	
	[xmlParser setDelegate:self];
    
	
	//delegate method to send the response after parsing finished successfully
	if([xmlParser parse]){
		[giftItemDelegate receivedGiftItem:giftItem];
	}
	[giftItem  release];
	[xmlParser release];
	[theConnection release];
}

//connection failed

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	//delegate method to indicate connection failed
	[giftItemDelegate requestFailed];
	[webData release];
	[theConnection release];
}

#pragma mark -
#pragma mark xmlParser delegates
-(void) parser:(NSXMLParser*) parser didStartElement:(NSString*) argElementName namespaceURI:(NSString*) argNamespaceURI qualifiedName:(NSString*) argQualifiedName attributes:(NSDictionary*) attributeDict
{
	if([argElementName isEqualToString:@"Item_Master"]){
        giftItem=[[GetDetailedGiftItemObject alloc]init];
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
	if([argElementName isEqualToString:@"Id"])
        giftItem.giftId=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    else if([argElementName isEqualToString:@"Title"]){
        
        giftItem.giftTitle=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"Details"]){
        
        giftItem.giftDetails=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if([argElementName isEqualToString:@"ImageUrl"]){
        currentElementValue=(NSMutableString*)[[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        giftItem.giftImageUrl=currentElementValue;
        
    }
    else if([argElementName isEqualToString:@"ImageBackSideUrl"]){
        
        currentElementValue=(NSMutableString*)[[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        giftItem.giftImageBackSideUrl=currentElementValue;
        
    }
    else if([argElementName isEqualToString:@"ThumbnailUrl"]){
        currentElementValue=(NSMutableString*)[[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        giftItem.giftThumbnailUrl=currentElementValue;
        
    }
    else if([argElementName isEqualToString:@"CategoryId"]){
        
        giftItem.giftCategoryId=[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
      
    
	
	currentElementValue=nil;
	[currentElementValue release];
}
#pragma mark -
- (void) dealloc {
	
    
	[super dealloc];
}
@end
