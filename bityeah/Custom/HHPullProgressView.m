//
//  HHPullProgressView.m
//  HChat
//
//  Created by Sasori on 14/11/26.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHPullProgressView.h"
#import "UIColor+FlatUI.h"

@implementation HHPullProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor colorFromHexCode:@"06bf04"];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_progress < 0) {
        _progress = 0;
    }
    if (_progress > 1) {
        _progress = 1;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.progress == 0) {
        return;
    }
    CGFloat radius = rect.size.width > rect.size.height ? rect.size.height/2-1 : rect.size.width/2-1;
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [path addArcWithCenter:center radius:radius startAngle:-M_PI_2 + M_PI*0.1 endAngle:M_PI*1.8*self.progress-M_PI_2 + M_PI*0.1 clockwise:YES];
    [path setLineWidth:1];
    [self.tintColor set];
    [path stroke];
}

-(void) startAnimating
{
    self.progress = 1;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopAnimating
{
    self.progress = 0;
    [self.layer removeAllAnimations];
}
@end
