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
    
    //GGLog(@"%d",[components day]);
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
        //Special case for December,January month events
        if([[[startDateString componentsSeparatedByString:@" "] objectAtIndex:0]isEqualToString:@"Dec"] && [[[endDateString componentsSeparatedByString:@" "] objectAtIndex:0]isEqualToString:@"Jan"]){

            //If the current date is December 31st and the event is placed on 1st January, we should show that it is tomorrow's event
            if([[[startDateString componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"31"] && [[[endDateString componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"01"])
                return @"Tomorrow";

            //otherwise return the date instead of Recent as it treated that January is less than December event by default.
            return endDateString;
        }
            
        
        return @"Recent";
    }
    else{
        //Special case for December,January month events
        if([[[startDateString componentsSeparatedByString:@" "] objectAtIndex:0]isEqualToString:@"Jan"] && [[[endDateString componentsSeparatedByString:@" "] objectAtIndex:0]isEqualToString:@"Dec"]){
            
            //If the current date is January 1st and the event is placed on 31st December, we should show that it is Yesterday's event
            if([[[startDateString componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"01"]&&[[[endDateString componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"31"])
                return @"Yesterday";
            //Otherwise return with "Recent" instead of date as it treated that December is upcoming event by default.
            return @"Recent";
        }
        return endDateString;
    }
    return nil;
   
}
@end
