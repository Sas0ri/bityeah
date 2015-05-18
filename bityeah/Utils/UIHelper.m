//
//  UIHelper.m
//  HChat
//
//  Created by Sasori on 13-9-6.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import "UIHelper.h"
#import "UIColor+FlatUI.h"
#define kNavButtonTitleFont [UIFont boldFlatFontOfSize:16]
#import "BYDefinitions.h"

@implementation UIHelper

+ (UIButton*)navRightButtonWithIconNormal:(UIImage *)iconNormal iconHighlighted:(UIImage *)iconHighlighted
{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_button_bg.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_button_bg_down.png"] forState:UIControlStateHighlighted];
    [button setImage:iconNormal forState:UIControlStateNormal];
	[button setImage:iconHighlighted forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 14, 0, -14)];
    return button;
}

+ (FUIButton *)navLeftButtonWithTitle:(NSString *)title
{
	UIFont *font = kNavButtonTitleFont;
	CGRect frame = CGRectMake(0, 12, 44.0, 20);
    CGFloat textWidth = [title sizeWithFont:font
                          constrainedToSize:CGSizeMake(160, 30)
                              lineBreakMode:NSLineBreakByTruncatingTail].width;
    textWidth += 15;
    frame.size.width = MAX(textWidth, frame.size.width);
    frame.origin.x = 0;
    
	FUIButton* button = [[FUIButton alloc] initWithFrame:frame];
	button.buttonColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [button setTitleColor:[UIColor colorFromHexCode:@"333333"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHexCode:@"333333"] forState:UIControlStateSelected];
	[button setTitle:title forState:UIControlStateNormal];
	
	UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
	[button addSubview:image];
	button.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
	[button setShadowHeight:0];
	return button;
}

+ (FUIButton *)navRightButtonWithTitle:(NSString *)title
{
	UIFont *font = kNavButtonTitleFont;
    CGRect frame = CGRectMake(0, 7, 44.0, 30.0);
    CGFloat textWidth = [title sizeWithFont:font
                          constrainedToSize:CGSizeMake(160, 30)
                              lineBreakMode:NSLineBreakByTruncatingTail].width;
//    textWidth += 16;
    frame.size.width = MAX(textWidth, frame.size.width);
    frame.origin.x = 320 - frame.size.width;
	FUIButton* button = [[FUIButton alloc] initWithFrame:frame];
	button.buttonColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [button setTitleColor:[UIColor colorFromHexCode:@"06bf04"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHexCode:@"06bf04"] forState:UIControlStateSelected];
	[button setTitle:title forState:UIControlStateNormal];
	return button;
}

+ (UIButton*)navLeftButtonWithIconNormal:(UIImage *)iconNormal iconHighlighted:(UIImage *)iconHighlighted
{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
    [button setImage:iconNormal forState:UIControlStateNormal];
	[button setImage:iconHighlighted forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    return button;
}

+ (UIButton*)navDoneButton
{
    return [self navRightButtonWithIconNormal:[UIImage imageNamed:@"nav_done.png"] iconHighlighted:[UIImage imageNamed:@"nav_done_down.png"]];
}

+ (UILabel *)naviTitleLabelWithTitle:(NSString *)title
{
	CGRect frame = CGRectMake(0.0, 0.0, 200.0, 44);
    UILabel* _navTitleView = [[UILabel alloc] initWithFrame:frame];
    _navTitleView.textAlignment = NSTextAlignmentCenter;
    _navTitleView.backgroundColor = [UIColor clearColor];
    _navTitleView.textColor = [UIColor blackColor];
    _navTitleView.font = [UIFont boldSystemFontOfSize:18];
    _navTitleView.text = title;
    _navTitleView.lineBreakMode = NSLineBreakByTruncatingMiddle;
	return _navTitleView;
}

+ (UIView*)noContentViewWithText:(NSString *)text  inView:(UIView *)view {
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height-108)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, bgView.bounds.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.textColor = [UIColor lightGrayColor];
    [bgView addSubview:label];
    return bgView;
}

+ (UIButton *)submitButtonWithTitle:(NSString *)title {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"button_normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_disabled"] forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateDisabled];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    return button;
}

+ (void)setNavigationBar:(UINavigationBar *)navigationBar translucent:(BOOL)b {
    if (b) {
        UIImage *navBarImage = [UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0] cornerRadius:0];
        [navigationBar setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
        navigationBar.shadowImage = navBarImage;
    } else {
        [navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        navigationBar.shadowImage = nil;
    }
}

+ (void)setToolbar:(UIToolbar *)navigationBar translucent:(BOOL)b {
    if (b) {
        UIImage *navBarImage = [UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0] cornerRadius:0];
        [navigationBar setBackgroundImage:navBarImage forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
        [navigationBar setShadowImage:navBarImage forToolbarPosition:UIBarPositionTop];
    } else {
        [navigationBar setBackgroundImage:nil forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
        [navigationBar setShadowImage:nil forToolbarPosition:UIBarPositionTop];
    }
}


+ (void)setNavigationBarLineHidden:(UINavigationBar *)navigationBar hidden:(BOOL)isHidden
{
    if ([navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list = navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                NSArray *list2 = imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2 = (UIImageView *)obj2;
                        imageView2.hidden = isHidden;
                    }
                }
            }
        }
    }
}

+ (void)setNavigationBar:(UINavigationBar *)navigationBar textColor:(BOOL)isBlack
{
    if (isBlack) {
        [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }else{
        [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
}

@end

