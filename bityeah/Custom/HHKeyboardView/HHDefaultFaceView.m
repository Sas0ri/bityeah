//
//  HHDefaultFaceView.m
//  HChat
//
//  Created by Sasori on 14/10/23.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHDefaultFaceView.h"
#import "KeybaordDefine.h"
#import "UIColor+FlatUI.h"

@interface HHDefaultFaceView() <FacialViewDelegate, UIScrollViewDelegate>
- (void)changePage:(UIPageControl*)pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;
@end

#define kPageNumber 3

@implementation HHDefaultFaceView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, keyboardHeight- 38)];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        for (int i = 0; i < kPageNumber; i++) {
            FacialView *fview = [[FacialView alloc] initWithFrame:CGRectMake(16+CGRectGetWidth(self.frame)*i, 25, CGRectGetWidth(self.frame) - 16*2, facialViewHeight)];
            [fview setBackgroundColor:[UIColor clearColor]];
            [fview loadFacialView:i size:CGSizeMake(40, 40) middleSpace:(CGRectGetWidth(fview.frame) - 7*40)/6];
            fview.delegate = self;
            [scrollView addSubview:fview];
        }
        
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * kPageNumber, keyboardHeight - 38);
        
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        _scrollView = scrollView;
        [self addSubview:scrollView];
        
        UIPageControl* pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(85, frame.size.height - 30, 150, 30)];
        CGPoint center = CGPointMake(CGRectGetMidX(self.frame), pageControl.center.y);
        pageControl.center = center;
        [pageControl setCurrentPage:0];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor colorFromHexCode:@"06bf04"]];
        [pageControl setPageIndicatorTintColor:[UIColor colorFromHexCode:@"D5D5D5"]];
        pageControl.numberOfPages = kPageNumber;//指定页面个数
        [pageControl setBackgroundColor:[UIColor clearColor]];
        [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        _pageControl = pageControl;
        [self addSubview:pageControl];
        
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / CGRectGetWidth(self.frame);//通过滚动的偏移量来判断目前页面所对应的小白点
    self.pageControl.currentPage = page;//pagecontroll响应值的变化
}
//pagecontroll的委托方法

- (void)changePage:(UIPageControl*)pageControl
{
    NSInteger page = pageControl.currentPage;//获取当前pagecontroll的值
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

- (void)selectedFacialView:(NSString *)str
{
    [self.delegate selectedFacialView:str];
}

@end
