//
//  ImageAllocationObject.h
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

/*Image Object*/

#import <Foundation/Foundation.h>

@interface ImageAllocationObject : NSObject {

}
//Alloc the image  and returned it
+(UIImage*) loadImageObjectName:(NSString*)imageName ofType:(NSString*)extensionType;
@end
