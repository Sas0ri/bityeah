//
//  CCFeedCellDelegate.h
//  testCircle
//
//  Created by Sasori on 14/12/2.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCFeedModel;

@protocol CCFeedCellDelegate <NSObject>
@optional

- (void)cellDidLike:(UITableViewCell*)cell;
- (void)cellDidComment:(UITableViewCell *)cell;
- (void)likeCommentAction:(id)sender onModel:(CCFeedModel*)model;
- (void)cell:(UITableViewCell*)cell didSelectImageAtIndex:(NSInteger)index;
- (void)cell:(UITableViewCell *)cell longPressImageAtIndex:(NSInteger)index;
- (void)cell:(UITableViewCell *)cell longPressTextView:(UIView *)textView;

@required
- (void)cell:(UITableViewCell *)cell didSelectUid:(int64_t)uid;
- (void)cell:(UITableViewCell *)cell didSelectURL:(NSString*)URL;
- (void)cellDidSelect:(UITableViewCell*)cell;
@end
