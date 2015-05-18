//
//  CCFeedCommentCell.h
//  testCircle
//
//  Created by Sasori on 14/12/3.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "CCFeedComment.h"
#import "CCUserInfoProvider.h"
#import "CCFeedCellDelegate.h"

@interface CCFeedCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TQRichTextView *commentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (strong, nonatomic) CCFeedComment* comment;
@property (nonatomic, weak) id<CCUserInfoProviderDelegate> userInfoProvider;
@property (nonatomic, weak) id<CCFeedCellDelegate> delegate;
- (void)showSepLine:(BOOL)show;
+ (CGFloat)heightForModel:(CCFeedComment*)comment forWidth:(CGFloat)width;
@end
