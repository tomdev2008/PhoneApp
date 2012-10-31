//
//  CustomDateDisplay.m
//  GiftGiv
//
//  Created by Srinivas G on 21/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "CustomDateDisplay.h"

@implementation CustomDateDisplay

static NSDateFormatter *customDateFormat=nil;
static NSCalendar *gregorianCalendar=nil;

+ (NSString*)updatedDateToBeDisplayedForTheEvent:(id)eventDate{
    
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    NSString *endDateString;
    
    if([eventDate isKindOfClass:[NSString class]]){
        
        eventDate=[NSString stringWithFormat:@"%@",eventDate];
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *tempDate = [customDateFormat dateFromString:eventDate];
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:tempDate];
    }
    else{
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:(NSDate*)eventDate];
    }
    
    NSString *startDateString=[customDateFormat stringFromDate:[NSDate date]]; //current date
    if(gregorianCalendar==nil)
        gregorianCalendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:[customDateFormat dateFromString:startDateString] toDate:[customDateFormat dateFromString:endDateString] options:0];
    
    //NSLog(@"%d",[components day]);
    //[gregorianCalendar release];
    
    switch ([components day]) {
        case -1:
            return @"Yesterday";
            
            break;
        case 0:
            return @"Today";
            break;
        case 1:
            return @"Tomorrow";
            break;
            
    }
    if([components day]<-1){
        return @"Recent";
    }
    if([components day]>1){
        
        return endDateString;
    }
    return nil;
}
@end
