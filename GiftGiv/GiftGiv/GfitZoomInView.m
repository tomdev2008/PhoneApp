//
//  GfitZoomInView.m
//  GiftGiv
//
//  Created by Srinivas G on 09/11/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//


#import "GfitZoomInView.h"

#import <QuartzCore/QuartzCore.h>

@implementation GfitZoomInView

#pragma mark Constants

#define ZOOM_LEVELS 4

//#if (READER_SHOW_SHADOWS == TRUE) // Option
//	#define CONTENT_INSET 4.0f
//#else
	#define CONTENT_INSET 2.0f
//#endif // end of READER_SHOW_SHADOWS Option

//#define PAGE_THUMB_LARGE 540 // Specify the height
//#define PAGE_THUMB_SMALL 144 // Specify the height

#pragma mark Properties

@synthesize message;
@synthesize theContainerView;

#pragma mark ReaderContentView functions

static inline CGFloat ZoomScaleThatFits(CGSize target, CGSize source)
{
	CGFloat w_scale = (target.width / source.width);
	CGFloat h_scale = (target.height / source.height);

	return ((w_scale < h_scale) ? w_scale : h_scale);
}

#pragma mark ReaderContentView instance methods

- (void)updateMinimumMaximumZoom
{
	CGRect targetRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

	CGFloat zoomScale = ZoomScaleThatFits(targetRect.size, theContainerView.bounds.size);

	self.minimumZoomScale = zoomScale; // Set the minimum and maximum zoom scales

	self.maximumZoomScale = (zoomScale * ZOOM_LEVELS); // Max number of zoom levels

	zoomAmount = ((self.maximumZoomScale - self.minimumZoomScale) / ZOOM_LEVELS);
}

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor whiteColor];
		self.userInteractionEnabled = YES;
		//self.autoresizesSubviews = YES;
		self.bouncesZoom = YES;
		self.delegate = self;
        
        GGLog(NSStringFromCGRect(self.bounds));
		theContainerView = [[UIImageView alloc] initWithFrame:self.bounds];
        //theContentView.bounds=CGRectInset(theContentView.bounds, 4, 4);
		//theContainerView.autoresizesSubviews = NO;
        theContainerView.userInteractionEnabled = NO;
        theContainerView.contentMode = UIViewContentModeScaleAspectFit;
        //theContainerView.autoresizingMask = UIViewAutoresizingNone;
        theContainerView.backgroundColor = [UIColor clearColor];
        
        self.contentSize = theContainerView.bounds.size; // Content size same as view size
        self.contentOffset = CGPointMake((0.0f - CONTENT_INSET), (0.0f - CONTENT_INSET)); // Offset
        self.contentInset = UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
        
        
        [self addSubview:theContainerView]; // Add the container view to the scroll view
        
        [self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales
        
        self.zoomScale = self.minimumZoomScale; // Set zoom to fit page content
		
        
		[self addObserver:self forKeyPath:@"frame" options:0 context:NULL];
		
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif

	[self removeObserver:self forKeyPath:@"frame"];

	[theContainerView release], theContainerView = nil;

	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif
    
	if ((object == self) && [keyPath isEqualToString:@"frame"])
	{
        ////NSLog(@"Page = %d Contentview %@",self.tag,NSStringFromCGRect(self.bounds));
        
		CGFloat oldMinimumZoomScale = self.minimumZoomScale;

		[self updateMinimumMaximumZoom]; // Update zoom scale limits

		if (self.zoomScale == oldMinimumZoomScale) // Old minimum
		{
			self.zoomScale = self.minimumZoomScale;
		}
		else // Check against minimum zoom scale
		{
			if (self.zoomScale < self.minimumZoomScale)
			{
				self.zoomScale = self.minimumZoomScale;
			}
			else // Check against maximum zoom scale
			{
				if (self.zoomScale > self.maximumZoomScale)
				{
					self.zoomScale = self.maximumZoomScale;
				}
			}
		}
	}
}

- (void)layoutSubviews
{
#ifdef DEBUGX
	//NSLog(@"%s Start", __FUNCTION__);
#endif

	[super layoutSubviews];
    
    
    CGRect viewBounds=CGRectZero;
    viewBounds.size=[self bounds].size;//CGSizeMake(320, 460);
       
    if (!CGSizeEqualToSize(viewBounds.size, self.frame.size))self.frame=viewBounds;
                
	CGSize boundsSize = self.bounds.size;
	CGRect viewFrame = theContainerView.frame;

	if (viewFrame.size.width < boundsSize.width)
		viewFrame.origin.x = (((boundsSize.width - viewFrame.size.width) / 2.0f) + self.contentOffset.x);
	else
		viewFrame.origin.x = 0.0f;

	if (viewFrame.size.height < boundsSize.height)
		viewFrame.origin.y = (((boundsSize.height - viewFrame.size.height) / 2.0f) + self.contentOffset.y);
	else
		viewFrame.origin.y = 0.0f;

	theContainerView.frame = viewFrame;
    
    
#ifdef DEBUGX
    //NSLog(@"%s Finish", __FUNCTION__);
#endif
}

- (id)singleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif
    return nil;
	//return [theContentView singleTap:recognizer];
}

#pragma mark-
#pragma mark Zoom Helpers

- (void)zoomIncrement
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif

	CGFloat zoomScale = self.zoomScale;

	if (zoomScale < self.maximumZoomScale)
	{
		zoomScale += zoomAmount; // += value

		if (zoomScale > self.maximumZoomScale)
		{
			zoomScale = self.maximumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomDecrement
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif

	CGFloat zoomScale = self.zoomScale;

	if (zoomScale > self.minimumZoomScale)
	{
		zoomScale -= zoomAmount; // -= value

		if (zoomScale < self.minimumZoomScale)
		{
			zoomScale = self.minimumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

-(void)fullZoomToPoint:(UITapGestureRecognizer *)recognizer{
    if (self.zoomScale>self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
        return;
    }
    CGRect zoomRect=[self zoomRectForScale:self.maximumZoomScale withCenter:[recognizer locationInView:theContainerView]];
    [self zoomToRect:zoomRect animated:YES];
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // contentScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    ////NSLog(@"\n self.frame = %@ \n zoomRect=%@",NSStringFromCGRect(self.frame),NSStringFromCGRect(zoomRect));
    
    return zoomRect;
}
- (void)zoomReset
{
#ifdef DEBUGX
	//NSLog(@"%s", __FUNCTION__);
#endif

	if (self.zoomScale > self.minimumZoomScale)
	{
		self.zoomScale = self.minimumZoomScale;
	}
}

#pragma mark UIScrollViewDelegate methods

- (UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return theContainerView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}
#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass

	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event]; // Message superclass
    [message contentView:self touchesBegan:touches]; // Message delegate
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

@end


