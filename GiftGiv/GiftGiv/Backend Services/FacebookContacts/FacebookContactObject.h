//
//  FacebookContactObject.h
//  GiftGiv
//
//  Created by Abhishek Ganu on 12/09/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookContactObject : NSObject

@property (retain,nonatomic)NSString *userId;
@property (retain,nonatomic)NSString *firstname;
@property (retain,nonatomic)NSString *lastname;
@property (retain,nonatomic)NSString *profilepicUrl;
@property (retain,nonatomic)NSString *dob;


@end
