//
//  CustomPageControl.m
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "CustomPageControl.h"
#import "AppDelegate.h"
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
    AppDelegate *appdel=[[UIApplication sharedApplication]delegate];
   UIViewController *currentVC = appdel.navController.visibleViewController;
    if([currentVC isMemberOfClass:NSClassFromString(@"GiftOptionsVC")]){
        for (int i = 0; i < [self.subviews count]; i++)
        {
            if(i==0){
                UIImageView* dot = [self.subviews objectAtIndex:i];
                if (i == self.currentPage){
                    dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 14, 14.5);
                    dot.image =[[ImageAllocationObject loadImageObjectName:@"searchicon" ofType:@"png"] retain];
                }
                else{
                    dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 14, 14.5);
                    dot.image = [[ImageAllocationObject loadImageObjectName:@"searchicon" ofType:@"png"] retain];
                }
                    
                
            }
            else{
                UIImageView* dot = [self.subviews objectAtIndex:i];
                if (i == self.currentPage)
                    dot.image = activeImage;
                else
                    dot.image = inactiveImage;
                
            }
        }

    }
    else{
        for (int i = 0; i < [self.subviews count]; i++)
        {
            UIImageView* dot = [self.subviews objectAtIndex:i];
            if (i == self.currentPage)
                dot.image = activeImage;
            else
                dot.image = inactiveImage;
        }
        
    }
     
}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    
    //Need to check the iOS6.0 respected to the subviews for page control
    //if(currentiOSVersion<6.0)
        [self updateDots];
    //else{
        //Enable the below statements when the project is compiled with iOS 6.0 and change the colors for the dots
        /*[self setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0]];
         [self setPageIndicatorTintColor:[UIColor colorWithRed:0.4431 green:0.8902 blue:0.9254 alpha:1.0]];*/
    //}
        
}

@end
