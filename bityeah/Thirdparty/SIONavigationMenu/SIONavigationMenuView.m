//
//  SINavigationMenuView.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SIONavigationMenuView.h"
#import "SIOMenuButton.h"
#import "QuartzCore/QuartzCore.h"

@interface SIONavigationMenuView  ()


@end

@implementation SIONavigationMenuView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.y += 1.0;
        self.menuButton = [[SIMenuButton alloc] initWithFrame:frame];
        self.menuButton.title.text = title;
		
        [self.menuButton addTarget:self action:@selector(onMenuButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.menuButton];
    }
    return self;
}

- (void)setMenuButtonActive:(BOOL)active
{
    if (active) {
        [self rotateArrow:M_PI];
    }
    else
    {
        [self rotateArrow:0];
    }
    self.menuButton.isActive = active;
}

- (void)onMenuButtonTap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedOnMen)]) {
        [self.delegate didTapedOnMen];
    }
}

- (void)rotateArrow:(float)degrees
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.menuButton.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:NULL];
}

@end
