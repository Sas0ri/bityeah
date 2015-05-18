//
//  UIView+MBProgressView.m
//  HChat
//
//  Created by Sasori on 3/7/14.
//  Copyright (c) 2014 Huhoo. All rights reserved.
//

#import "UIView+MBProgressView.h"
#import "MBProgressHUD.h"

#define kHudTag    1241251251

@implementation UIView (MBProgressView)

- (void)showHudWithText:(NSString *)text indicator:(BOOL)show
{
    [self showHudWithText:text indicator:show scale:1];
}

- (void)showHudWithText:(NSString *)text indicator:(BOOL)show scale:(CGFloat)scale {
    MBProgressHUD* hud = (MBProgressHUD*)[self viewWithTag:kHudTag];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self];
        hud.tag = kHudTag;
        hud.color = [UIColor grayColor];
        [self addSubview:hud];
    }
    hud.transform = CGAffineTransformMakeScale(scale, scale);
    hud.detailsLabelText = text;
    hud.mode = show ? MBProgressHUDModeIndeterminate : MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:NO];
}

- (void)hideHud
{
	MBProgressHUD* hud = (MBProgressHUD*)[self viewWithTag:kHudTag];
	if (hud) {
		[hud hide:YES];
	}
}

- (void)hideHudAfterDelay:(NSTimeInterval)delay
{
	MBProgressHUD* hud = (MBProgressHUD*)[self viewWithTag:kHudTag];
	if (hud) {
		[hud hide:YES afterDelay:delay];
	}
}

@end
