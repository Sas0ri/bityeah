//
//  UIView+MBProgressView.h
//  HChat
//
//  Created by Sasori on 3/7/14.
//  Copyright (c) 2014 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface UIView (MBProgressView)
- (void)showHudWithText:(NSString*)text indicator:(BOOL)show;
- (void)hideHud;
- (void)hideHudAfterDelay:(NSTimeInterval)delay;
- (void)showHudWithText:(NSString*)text indicator:(BOOL)show scale:(CGFloat)scale;
@end
