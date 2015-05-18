//
//  CCDetailCommentCell.h
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHRoundImageView.h"
#import "TQRichTextView.h"
#import "CCFeedComment.h"
#import "CCUserInfoProvider.h"
#import "CCFeedCellDelegate.h"

@interface CCDetailCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *commentIcon;
@property (weak, nonatomic) IBOutlet HHRoundImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TQRichTextView *titleView;
@property (weak, nonatomic) IBOutlet TQRichTextView *commentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) id<CCFeedCellDelegate> delegate;
@property (nonatomic, strong) CCFeedComment* comment;
@property (nonatomic, weak) id<CCUserInfoProviderDelegate> userInfoProvider;
- (void)hideArrow:(BOOL)hide;
- (void)setCommentIconHidden:(BOOL)hidden;
+ (CGFloat)heightForComment:(NSString*)comment forWidth:(CGFloat)width;
- (void)showSepLine:(BOOL)show;
@end
