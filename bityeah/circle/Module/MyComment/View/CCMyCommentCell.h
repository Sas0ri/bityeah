//
//  CCMyCommentCell.h
//  testCircle
//
//  Created by Sasori on 14/12/12.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "HHAvatarImageView.h"
#import "CCMyCommentModel.h"
#import "CCUserInfoProvider.h"
#import "CCFeedCellDelegate.h"

@interface CCMyCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet HHAvatarImageView *avatarView;
@property (weak, nonatomic) IBOutlet TQRichTextView *authorView;
@property (weak, nonatomic) IBOutlet UIImageView *likeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TQRichTextView *contentTextView;
@property (weak, nonatomic) IBOutlet TQRichTextView *feedContentView;
@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;
@property (nonatomic, weak) id<CCFeedCellDelegate> delegate;
@property (nonatomic, strong) CCMyCommentModel* model;
@property (nonatomic, weak) id<CCUserInfoProviderDelegate> userInfoProvider;
+ (CGFloat)heightForModel:(CCMyCommentModel*)model forWidth:(CGFloat)width;
@end
