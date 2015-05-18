//
//  UIHelper.h
//  HChat
//
//  Created by Sasori on 13-9-6.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlatUIKit.h"

@interface UIHelper : NSObject
+ (UIButton*)navRightButtonWithIconNormal:(UIImage *)iconNormal iconHighlighted:(UIImage *)iconHighlighted;
+ (FUIButton*)navLeftButtonWithTitle:(NSString*)title;
+ (FUIButton*)navRightButtonWithTitle:(NSString*)title;
+ (UIButton*)navLeftButtonWithIconNormal:(UIImage *)iconNormal iconHighlighted:(UIImage *)iconHighlighted;
+ (UIButton*)navDoneButton;
+ (UILabel*)naviTitleLabelWithTitle:(NSString*)title;
+ (UIView*)noContentViewWithText:(NSString*)text inView:(UIView*)view;
+ (UIButton*)submitButtonWithTitle:(NSString*)title;
+ (void)setNavigationBar:(UINavigationBar*)navigationBar translucent:(BOOL)b;
+ (void)setNavigationBarLineHidden:(UINavigationBar *)navigationBar hidden:(BOOL)isHidden;
+ (void)setNavigationBar:(UINavigationBar *)navigationBar textColor:(BOOL)isBlack;

+ (void)setToolbar:(UIToolbar *)navigationBar translucent:(BOOL)b;
@end
