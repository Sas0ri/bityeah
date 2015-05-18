//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HHZoomScrollViewDelegate <NSObject>

@optional
- (void)zoomScrollViewOperation;

@end

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSString* url;
@property (assign, nonatomic) id <HHZoomScrollViewDelegate> opDelegate;
@property (retain, nonatomic) UIButton *opBtn;


- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
@end
