//
//  CustomPageControl.m
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    activeImage = [[ImageAllocationObject loadImageObjectName:@"dotactive" ofType:@"png"] retain];
    inactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive" ofType:@"png"] retain];
    
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage)
            dot.image = activeImage;
        else
            dot.image = inactiveImage;
    }
}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    
    //Need to check the iOS6.0 respected to the subviews for page control
    if(currentiOSVersion<6.0)
        [self updateDots];
    else{
        //Enable the below statements when the project is compiled with iOS 6.0 and change the colors for the dots
        /*[self setCurrentPageIndicatorTintColor:[UIColor blackColor]];
        [self setPageIndicatorTintColor:[UIColor redColor]];*/
    }
        
}

@end
