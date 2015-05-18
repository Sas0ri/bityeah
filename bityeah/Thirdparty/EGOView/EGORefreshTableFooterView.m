//
//  EGORefreshTableFooterView.m
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

#import "EGORefreshTableFooterView.h"

@interface EGORefreshTableFooterView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableFooterView

- (void)commonInit {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = self.textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
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
		layer.frame = CGRectMake(25.0f, 20.0f, 30.0f, 55.0f);
        layer.contentMode = UIViewContentModeCenter;
    
        [self addSubview:layer];
        _arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, 20.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		_refreshHeight = 65.0f;
		
		[self setState:EGOOPullRefreshNormal];
    
	
}

- (void)config {
    _textColor = TEXT_COLOR;
    _arrow = @"blueArrow";
}

- (id)initWithFrame:(CGRect)frame  {
    if (self = [super initWithFrame:frame]) {
        [self config];
        [self commonInit];
    }
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableDataSourceLastUpdated:self];
		
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
			
			_statusLabel.text = @"松开即可加载更多...";//NSLocalizedString(@"Release to load more...", @"Release to load more");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            _arrowImage.layer.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.layer.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = @"上拉可以加载更多...";//NSLocalizedString(@"Pull up to load more...", @"Pull up to load more");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			//_arrowImage.transform = CATransform3DIdentity;
            _arrowImage.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = @"加载中...";// NSLocalizedString(@"Loading...", @"Loading Status");
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
	CGFloat bottomOffset = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height;
	if (_state == EGOOPullRefreshLoading) {
		
//		CGFloat offset = MAX(bottomOffset, 0);
//		offset = MIN(offset, 60);

		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && bottomOffset < self.refreshHeight && bottomOffset > 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && 
                   bottomOffset > self.refreshHeight && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
		_loading = [self.delegate egoRefreshTableDataSourceIsLoading:self];
	}
    CGFloat bottomOffset = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height;
	if (bottomOffset > self.refreshHeight  && !_loading && scrollView.contentSize.height >= scrollView.bounds.size.height) {
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(egoRefreshTable:DidTriggerRefresh:)]) {
			[self.delegate egoRefreshTable:scrollView DidTriggerRefresh:EGORefreshFooter];
		}
		
		[self setState:EGOOPullRefreshLoading];
        [UIView animateWithDuration:.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top, 0.0f, self.refreshHeight, 0.0f);
        }];
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
        [self.superScrollView setContentInset:UIEdgeInsetsMake(self.superScrollView.contentInset.top, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
    }
}

- (void)didMoveToSuperview {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView*)self.superview;
    }
}

@end
