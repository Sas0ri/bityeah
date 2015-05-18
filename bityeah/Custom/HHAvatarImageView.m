//
//  HHAvatarImageView.m
//  HChat
//
//  Created by Sasori on 14/11/4.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHAvatarImageView.h"
#import "UIColor+FlatUI.h"

@implementation HHAvatarImageView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2-1, 0, 2*M_PI, YES);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorFromHexCode:@"efeff4"].CGColor);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

@end
