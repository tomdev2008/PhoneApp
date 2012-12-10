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
    
    activeImage = [[ImageAllocationObject loadImageObjectName:@"dotactive2" ofType:@"png"] retain];
    inactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive2" ofType:@"png"] retain];
    
    return self;
}

-(void) updateDots
{
    AppDelegate *appdel=[[UIApplication sharedApplication]delegate];
    UIViewController *currentVC = appdel.navController.visibleViewController;
    BOOL shouldShowSearchIconInHomeScreen=NO;
    BOOL isHomeScreen=NO;
    if([currentVC isMemberOfClass:NSClassFromString(@"HomeScreenVC")]){
        isHomeScreen=YES;
        if([[currentVC listOfContactsArray] count]){
            shouldShowSearchIconInHomeScreen=YES;
        }
        else{
            shouldShowSearchIconInHomeScreen=NO;
        }
    }
    for (int i = 0; i < [self.subviews count]; i++)
    {
        if(i==0 && isHomeScreen && shouldShowSearchIconInHomeScreen){
            UIImageView* dot = [self.subviews objectAtIndex:i];
            
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 12, 12);
            
            if (i == self.currentPage){
                
                dot.image =[ImageAllocationObject loadImageObjectName:@"searchdotactive2" ofType:@"png"] ;
            }
            else{
                
                dot.image = [ImageAllocationObject loadImageObjectName:@"searchdotinactive2" ofType:@"png"] ;
                
            }
           
            GGLog(@"dot frame..%@",NSStringFromCGRect(dot.frame));
        }
        else if(i==0 && !isHomeScreen){
            UIImageView* dot = [self.subviews objectAtIndex:i];
           
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 12, 12);
           
            if (i == self.currentPage){
                
                dot.image =[ImageAllocationObject loadImageObjectName:@"searchdotactive2" ofType:@"png"] ;
            }
            else{
                
                dot.image = [ImageAllocationObject loadImageObjectName:@"searchdotinactive2" ofType:@"png"] ;
            }
            
        }
        else{
            UIImageView* dot = [self.subviews objectAtIndex:i];
            
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 8, 12);
                     
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
    
    [self updateDots];
    
    
}

@end
