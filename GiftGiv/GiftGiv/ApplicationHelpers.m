//
//  ApplicationHelpers.m
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "ApplicationHelpers.h"

void AlertWithMessageAndDelegate(NSString *title, NSString *message, id theDelegate)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:theDelegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

void AlertWithMessageAndDelegateActionHandling(NSString *title, NSString *message,NSArray *buttonTitles, id theDelegate){
        
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:theDelegate];
    for(int i=0;i<[buttonTitles count];i++)
        [alert addButtonWithTitle:[buttonTitles objectAtIndex:i]];
	[alert show];
	[alert release];
}