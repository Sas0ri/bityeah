//
//  SvGifView.h
//  SvGifSample
//
//  Created by maple on 3/28/13.
//  Copyright (c) 2013 smileEvday. All rights reserved.
//
//  QQ: 1592232964


#import <UIKit/UIKit.h>
#import "HHGifData.h"


@interface SvGifView : UIView

@property (nonatomic, strong) HHGifData* gifData;
/*
 * @brief desingated initializer
 */
- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;

/*
 * @brief start Gif Animation
 */
- (void)startGif;

/*
 * @brief stop Gif Animation
 */
- (void)stopGif;

/*
 * @brief get frames image(CGImageRef) in Gif
 */
+ (NSArray*)framesInGif:(NSURL*)fileURL;
+ (void)getFrameInfo:(CFURLRef)url frames:(NSMutableArray *)frames delays:(NSMutableArray *)delayTimes totalTime:(CGFloat *)totalTime gifWidth:(CGFloat *)gifWidth gifHeight:(CGFloat *)gifHeight;


@end
