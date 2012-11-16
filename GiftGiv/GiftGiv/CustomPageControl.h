//
//  CustomPageControl.h
//  GiftGiv
//
//  Created by Srinivas G on 20/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

/* page control dots (Colored images) may not work from iOS 6.0 */

#import <UIKit/UIKit.h>
#import "ImageAllocationObject.h"
//#import "Constants.h"


@interface CustomPageControl : UIPageControl
{
    UIImage* activeImage;
    UIImage* inactiveImage;
}
@end
