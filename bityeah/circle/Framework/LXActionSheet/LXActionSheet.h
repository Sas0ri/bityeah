//
//  LXActionSheet.h
//  LXActionSheetDemo
//
//  Created by lixiang on 14-3-10.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXActionSheet;

@protocol LXActionSheetDelegate <NSObject>
- (void)actionSheet:(LXActionSheet*)actionSheet didClickOnButtonIndex:(NSInteger)buttonIndex;
@optional
- (void)actionSheetDidClickOnDestructiveButton:(LXActionSheet*)actionSheet ;
- (void)actionSheetDidClickOnCancelButton:(LXActionSheet*)actionSheet ;
@end

@interface LXActionSheet : UIView
- (id)initWithTitle:(NSString *)title delegate:(id<LXActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitlesArray;
- (void)showInView:(UIView *)view;

@end
