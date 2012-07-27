//
//  ApplicationHelpers.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//
/*
 Inline functions to alert the user
 */
#import <Foundation/Foundation.h>

void AlertWithMessageAndDelegate(NSString *title, NSString *message, id theDelegate);


void AlertWithMessageAndDelegateActionHandling(NSString *title, NSString *message,NSArray *buttonTitles, id theDelegate);