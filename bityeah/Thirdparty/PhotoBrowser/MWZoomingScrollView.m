//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWZoomingScrollView.h"
#import "UIImageView+WebCache.h"

// Private methods and properties
@interface MWZoomingScrollView ()
@property (nonatomic, strong) UIImageView* photoImageView;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@property (assign, nonatomic) CGRect rectFrame;
- (void)displayImage:(UIImage*)image;
- (void)handleDoubleTap:(CGPoint)touchPoint;
@end

@implementation MWZoomingScrollView

- (id)initWithUrl:(NSString*)url {
    if ((self = [super init])) {
        self.url = url;
	}
    return self;
}

- (UIButton *)opBtn
{
    if (!_opBtn) {
        _opBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _opBtn.frame = CGRectMake(_rectFrame.size.width - 60, _rectFrame.size.height - 45, 27, 21);
        _opBtn.autoresizingMask = UIViewAutoresizingNone;
        [_opBtn setBackgroundImage:[UIImage imageNamed:@"moreOperation.png"] forState:UIControlStateNormal];
        [_opBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _opBtn;
}

- (void)moreOperation
{
    if (_opDelegate && [_opDelegate respondsToSelector:@selector(zoomScrollViewOperation)]) {
        [_opDelegate zoomScrollViewOperation];
    }
}

-(id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
        _rectFrame = frame;
		_photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_photoImageView.contentMode = UIViewContentModeScaleAspectFit;
		_photoImageView.userInteractionEnabled = YES;
		[self addSubview:_photoImageView];
		// Spinner
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.hidesWhenStopped = YES;
		_spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		_spinner.center = CGPointMake(frame.size.width/2, frame.size.height/2);
		[self addSubview:_spinner];
		
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.maximumZoomScale = 2.0;
		self.minimumZoomScale = 1.0;
		self.contentSize = _photoImageView.bounds.size;
		
//        [self addSubview:self.opBtn];
        
		UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] init];
		tg.numberOfTapsRequired = 1;
		[tg addTarget:self action:@selector(handleSingleTap:)];
		tg.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:tg];
		
		UITapGestureRecognizer* tg1 = [[UITapGestureRecognizer alloc] init];
		tg1.numberOfTapsRequired = 2;
		[tg1 addTarget:self action:@selector(handleDoubleTap:)];
		tg1.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:tg1];
		[tg requireGestureRecognizerToFail:tg1];
	}
	return self;
}

#pragma mark - Image

// Get and display image
- (void)displayImage:(UIImage*)image {
	if (_photoImageView.image == nil) {
		
		// Reset
		self.maximumZoomScale = 2;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
		
		if (image) {
			// Hide spinner
			[_spinner stopAnimating];
			
			// Set image
			_photoImageView.image = image;
			_photoImageView.hidden = NO;
			
			// Setup photo frame
			self.contentSize = _photoImageView.bounds.size;

			// Set zoom to minimum zoom
//			[self setMaxMinZoomScalesForCurrentBounds];
			
		} else {
			
			// Hide image view
			_photoImageView.hidden = YES;
			[_spinner startAnimating];
			
		}
		[self setNeedsLayout];
	}
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (_photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
	CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(_photoImageView.image.size.width/scale, _photoImageView.image.size.height/scale);
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
	CGFloat maxScale = MAX(xScale, yScale);
	// Calculate Max
//	CGFloat maxScale = 2.0; // Allow double scale

	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}     	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	// Reset position
	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
	_photoImageView.contentScaleFactor = scale;
	[self setNeedsLayout];

}

#pragma mark - Layout

//- (void)layoutSubviews {
//	
//	
//	// Spinner
//	if (!_spinner.hidden) {
//		_spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
//									  floorf(self.bounds.size.height/2.0));	
//	}	// Super
//	[super layoutSubviews];
//	
//    // Center the image as it becomes smaller than the size of the screen
//    CGSize boundsSize = self.bounds.size;
//    CGRect frameToCenter = _photoImageView.frame;
//    
//    // Horizontally
//    if (frameToCenter.size.width < boundsSize.width) {
//        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
//	} else {
//        frameToCenter.origin.x = 0;
//	}
//    
//    // Vertically
//    if (frameToCenter.size.height < boundsSize.height) {
//        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
//	} else {
//        frameToCenter.origin.y = 0;
//	}
//    
//	// Center
//	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
//		_photoImageView.frame = frameToCenter;
//	
//}

-(void)setUrl:(NSString *)url
{
	_url = url;
	__weak typeof(self) v = self;
	[_spinner startAnimating];
	[self.photoImageView setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
		[v.spinner stopAnimating];
//		v.photoImageView.image = nil;
//		[v displayImage:image];
	}];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [_opBtn removeFromSuperview];
	[UIView animateWithDuration:0.4f animations:^{
		self.transform = CGAffineTransformMakeScale(0.001, 0.001);
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {

//	// Zoom
//	if (self.zoomScale == self.maximumZoomScale) {
//		// Zoom out
//		[self setZoomScale:self.minimumZoomScale animated:YES];
//		
//	} else {
//		
//		// Zoom in
//		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
////		[self setZoomScale:self.maximumZoomScale animated:YES];
//		
//	}
	if (self.zoomScale != 1.0) {
		[self setZoomScale:1.0 animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
//		[self setZoomScale:2.0 animated:YES];
//		NSLog(@"self.scale is %f",self.zoomScale);
	}
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _photoImageView;
}

@end
