//
//  HHRefreshTableHeaderView.m
//  HChat
//
//  Created by Sasori on 14/11/26.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHRefreshTableHeaderView.h"
#import "HHPullProgressView.h"
#import "UIColor+FlatUI.h"

@interface HHRefreshTableHeaderView()
@property (nonatomic, strong) HHPullProgressView* progressView;
@end

@implementation HHRefreshTableHeaderView
@synthesize arrow = _arrow, textColor = _textColor;

- (void)config {
    _arrow = @"refresh_arrow";
    _textColor = [UIColor colorFromHexCode:@"666666"];
}

- (void)commonInit {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.backgroundColor = [UIColor colorFromHexCode:@"f4f4f4"];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 40.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textColor = self.textColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    UIImageView *layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.arrow]];
    layer.frame = CGRectMake(90, self.frame.size.height - 40, 20, 20);
    layer.contentMode = UIViewContentModeCenter;
    
    [self addSubview:layer];
    _arrowImage=layer;
    
    HHPullProgressView *view = [[HHPullProgressView alloc] init];
    view.frame = CGRectMake(88, self.frame.size.height - 42, 24, 24);
    [self addSubview:view];
    _progressView = view;
    
    
    [self setState:EGOOPullRefreshNormal];
}

- (void)setState:(EGOPullRefreshState)aState{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            
            _statusLabel.text = @"松开即可刷新...";//NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            break;
        case EGOOPullRefreshNormal:
            
            if (_state == EGOOPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.layer.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            
            _statusLabel.text = @"下拉可以刷新...";//NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
            [_progressView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.layer.transform = CATransform3DIdentity;
            [CATransaction commit];
            break;
        case EGOOPullRefreshLoading:
            
            _statusLabel.text = @"加载中...";//NSLocalizedString(@"Loading...", @"Loading Status");
            [_progressView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    _state = aState;
}

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    [super egoRefreshScrollViewDidScroll:scrollView];
    if (scrollView.isDragging && (_state == EGOOPullRefreshNormal || _state == EGOOPullRefreshPulling)) {
        [self updateProgressByContentOffset:scrollView.contentOffset];
    }
}

- (void)updateProgressByContentOffset:(CGPoint)contentOffset {
    CGFloat progress = (-self.originInsets.top-contentOffset.y)/([self refreshHeight]- self.originInsets.top);
    self.progressView.progress = progress;
}

@end
