//
//  SvGifView.m
//  SvGifSample
//
//  Created by maple on 3/28/13.
//  Copyright (c) 2013 smileEvday. All rights reserved.
//
//  QQ: 1592232964

#import "SvGifView.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/CoreAnimation.h>

/*
 * @brief resolving gif information
 */

@interface SvGifView() {
    NSMutableArray *_frames;
    NSMutableArray *_frameDelayTimes;
    
    CGFloat _totalTime;         // seconds
    CGFloat _width;
    CGFloat _height;
}
@property (nonatomic, assign) BOOL animating;
- (void)didBecomeActive;
- (void)commonInit;
@end

@implementation SvGifView


- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
		[self commonInit];
        
        if (fileURL) {
			[SvGifView getFrameInfo:(CFURLRef)fileURL frames:_frames delays:_frameDelayTimes totalTime:&_totalTime gifWidth:&_width gifHeight:&_height];
        }
        
        self.center = center;
    }
    
    return self;
}

- (id)init
{
	if (self = [super init]) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	_frames = [[NSMutableArray alloc] init];
	_frameDelayTimes = [[NSMutableArray alloc] init];
	
	_width = 0;
	_height = 0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didBecomeActive
{
	if (self.animating) {
		[self startGif];
	}
}

+ (NSArray*)framesInGif:(NSURL *)fileURL
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
	[SvGifView getFrameInfo:(CFURLRef)fileURL frames:frames delays:delays totalTime:nil gifWidth:nil gifHeight:nil];
    return frames;
}

- (void)startGif
{
	[self stopGif];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    int count = (int)_frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[_frames objectAtIndex:i]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = _totalTime;
    animation.delegate = self;
    animation.repeatCount = HUGE_VALF;
    
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
	self.animating = YES;
}

- (void)stopGif
{
    [self.layer removeAllAnimations];
	self.animating = NO;
}

- (void)setGifData:(HHGifData *)gifData
{
	_gifData = gifData;
	_frames = (NSMutableArray*)gifData.frames;
	_frameDelayTimes = (NSMutableArray*)gifData.delays;
	_totalTime = gifData.totalTime;
}

+ (void)getFrameInfo:(CFURLRef)url frames:(NSMutableArray *)frames delays:(NSMutableArray *)delayTimes totalTime:(CGFloat *)totalTime gifWidth:(CGFloat *)gifWidth gifHeight:(CGFloat *)gifHeight
{
	{
		CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
		
		// get frame count
		size_t frameCount = CGImageSourceGetCount(gifSource);
		for (size_t i = 0; i < frameCount; ++i) {
			// get each frame
			CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
			[frames addObject:(__bridge id)frame];
			CGImageRelease(frame);
			
			// get gif info with each frame
			NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
			
			// get gif size
			//        if (gifWidth != NULL && gifHeight != NULL) {
			//            *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
			//            *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
			//        }
			
			// kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
			NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
			[delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
			
			if (totalTime) {
				*totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
			}
		}
		CFRelease(gifSource);
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


