//
//  CoomonRequestCreationObject.h
//  GiftGiv
//
//  Created by Srinivas G on 07/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Constants.h"

@interface CoomonRequestCreationObject : NSObject

+(NSMutableURLRequest *)soapRequestMessage:(NSString *)soapMsg withAction:(NSString*)soapAction;

@end
