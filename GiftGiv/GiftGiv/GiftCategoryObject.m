//
//  GiftCategoryObject.m
//  GiftGiv
//
//  Created by Srinivas G on 22/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftCategoryObject.h"

@implementation GiftCategoryObject
@synthesize catId;
@synthesize catName;


-(void)dealloc{
    [catId release];
    [catName release];
    [super dealloc];
    
}

@end
