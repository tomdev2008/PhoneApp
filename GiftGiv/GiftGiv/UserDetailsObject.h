//
//  UserDetailsObject.h
//  GiftGiv
//
//  Created by Srinivas G on 27/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetailsObject : NSObject


@property (retain,nonatomic)NSMutableString *userId;
@property (retain,nonatomic)NSMutableString *userfbId;
@property (retain,nonatomic)NSMutableString *firstname;
@property (retain,nonatomic)NSMutableString *lastname;
@property (retain,nonatomic)NSMutableString *picUrl;
@property (retain,nonatomic)NSMutableString *userDOB;
@property (retain,nonatomic)NSMutableString *userEmail;


@end
