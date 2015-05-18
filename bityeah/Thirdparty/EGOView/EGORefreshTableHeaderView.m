//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

@interface EGORefreshTableHeaderView ()
@end

@implementation EGORefreshTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self config];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = self.textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _lastUpdatedLabel=label;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = self.textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    UIImageView *layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.arrow]];
    layer.frame = CGRectMake(25.0f, self.frame.size.height - 65.0f, 30.0f, 55.0f);
    
    [self addSubview:layer];
    _arrowImage=layer;
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.frame = CGRectMake(25.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
    [self addSubview:view];
    _activityView = view;
    
    
    [self setState:EGOOPullRefreshNormal];
}

- (void)config {
    _textColor = TEXT_COLOR;
    _arrow = @"blueArrow";
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceLastUpdated:)]) {
		
		NSDate *date = [self.delegate egoRefreshTableDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最近更新: %@", [dateFormatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

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
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.layer.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = @"加载中...";//NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
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


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
        [UIView animateWithDuration:0.25 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(offset+self.originInsets.top, 0.0f, 0.0f, 0.0f);
        }];
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
			_loading = [self.delegate egoRefreshTableDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -[self refreshHeight] && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -[self refreshHeight] && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = self.originInsets;
		}
    }
}

- (CGFloat)refreshHeight {
    return 65 + self.originInsets.top;
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	BOOL _loading = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
		_loading = [self.delegate egoRefreshTableDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - [self refreshHeight] && !_loading) {
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTable:DidTriggerRefresh:)]) {
			[self.delegate egoRefreshTable:scrollView DidTriggerRefresh:EGORefreshHeader];
		}
		
		[self setState:EGOOPullRefreshLoading];
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:0.25];
//		scrollView.contentInset = UIEdgeInsetsMake(60.0f + self.originInsets.top, 0.0f, 0.0f, 0.0f);
//		[UIView commitAnimations];
		
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    [self performSelector:@selector(finishLoadingState) withObject:nil afterDelay:0.3];
}

- (void)finishLoadingState
{
    if (self.superScrollView) {
        [self setState:EGOOPullRefreshNormal];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.superScrollView setContentInset:self.originInsets];
        [UIView commitAnimations];
    }
}

- (void)refreshAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.2 animations:^{
            [self.superScrollView setContentInset:UIEdgeInsetsMake([self refreshHeight], 0, 0, 0)];
            [self.superScrollView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        }];
    } else {
        [self.superScrollView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [self.superScrollView setContentInset:UIEdgeInsetsMake([self refreshHeight], 0, 0, 0)];
    }
    [self setState:EGOOPullRefreshLoading];
}

- (void)didMoveToSuperview {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView*)self.superview;
        self.originInsets = ((UIScrollView*)self.superview).contentInset;
    }
}


@end
