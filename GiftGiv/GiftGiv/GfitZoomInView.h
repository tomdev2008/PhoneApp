//
//  GfitZoomInView.h
//  GiftGiv
//
//  Created by Srinivas G on 09/11/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GfitZoomInView;

@protocol GfitZoomInViewDelegate <NSObject>

@required // Delegate protocols

- (void)contentView:(GfitZoomInView *)contentView touchesBegan:(NSSet *)touches;

@end

@interface GfitZoomInView : UIScrollView <UIScrollViewDelegate>
{
@private // Instance variables


	UIImageView *theContainerView;

	CGFloat zoomAmount;
}

@property (nonatomic, assign, readwrite) id <GfitZoomInViewDelegate> message;


@property (nonatomic, assign) UIImageView *theContainerView;

- (id)singleTap:(UITapGestureRecognizer *)recognizer;

- (void)zoomIncrement;
- (void)zoomDecrement;
- (void)zoomReset;

-(void)fullZoomToPoint:(UITapGestureRecognizer *)recognizer;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

