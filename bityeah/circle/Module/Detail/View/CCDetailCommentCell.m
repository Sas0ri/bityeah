//
//  CCDetailCommentCell.m
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCDetailCommentCell.h"
#import "CCUtils.h"
#import "TQRichTextUserNameRun.h"
#import "TQRichTextURLRun.h"
#import "UIColor+FlatUI.h"

@interface CCDetailCommentCell() <TQRichTextViewDelegate, HHRoundImageViewDelegate>
@property (nonatomic, assign) BOOL showArrow;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@end

@implementation CCDetailCommentCell

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.titleView.font = [UIFont systemFontOfSize:15];
    self.commentView.font = [UIFont systemFontOfSize:14];
    self.titleView.delegate = self;
    self.commentView.delegate = self;
    self.avatarView.delegate = self;
    self.bgView.image = [[UIImage imageNamed:@"bg_comment_list"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 100)];
    self.sepLine.backgroundColor = [UIColor colorFromHexCode:@"e2e3e5"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment:(CCFeedComment *)comment {
    _comment = comment;
    
    NSString* avatar = [self.userInfoProvider avatarForUid:comment.authorId];
    [self.avatarView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    self.titleView.text = [self.class authorForComment:comment];
    
    CGRect r = self.commentView.frame;
    r.size.width = self.bounds.size.width - 100;
    self.commentView.frame = r;
    
    self.commentView.text = comment.comment;
    [self.commentView sizeToFit];
    
    self.timeLabel.text = [CCUtils timeStringFromTimeStamp:comment.timeStamp];
}

+ (CGFloat)heightForComment:(NSString *)comment forWidth:(CGFloat)width {
    TQRichTextView* textView = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 0, width - 109, 0)];
    textView.font = [UIFont systemFontOfSize:14];
    textView.text = comment;
    [textView sizeToFit];
    return textView.bounds.size.height + 38;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.timeLabel.frame;
    r.origin.x = self.bounds.size.width - self.timeLabel.frame.size.width - 20;
    r.origin.y = 8;
    if (self.showArrow) {
        r.origin.y += 8;
    }
    self.timeLabel.frame = r;
    
    r = self.commentIcon.frame;
    r.origin.x = 22;
    r.origin.y = 26 - CGRectGetHeight(self.commentIcon.frame)/2;
    if (self.showArrow) {
        r.origin.y += 4;
    }
    self.commentIcon.frame = r;
    
    r = self.avatarView.frame;
    r.origin.y = 8;
    if (self.showArrow) {
        r.origin.y += 8;
    }
    self.avatarView.frame = r;
    
    r = self.titleView.frame;
    r.origin.y = 7;
    if (self.showArrow) {
        r.origin.y += 8;
    }
    self.titleView.frame = r;
    
    r = self.commentView.frame;
    r.origin.y = 28;
    if (self.showArrow) {
        r.origin.y += 8;
    }
    self.commentView.frame = r;
    
    r = self.bgView.frame;
    r.size.width = self.bounds.size.width - 20;
    if (self.showArrow) {
        r.size.height = CGRectGetHeight(self.frame);
    } else {
        r.size.height = CGRectGetHeight(self.frame) + 9;
    }
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height;
    self.bgView.frame = r;
    
    r = self.sepLine.frame;
    r.origin.x = self.avatarView.frame.origin.x;
    r.size.width = self.contentView.frame.size.width - self.avatarView.frame.origin.x - 10;
    r.origin.y = self.frame.size.height - .5;
    r.size.height = .5;
    self.sepLine.frame = r;
}

- (void)setCommentIconHidden:(BOOL)hidden {
    self.commentIcon.hidden = hidden;
}

+ (NSString *)authorForComment:(CCFeedComment*)comment {
    NSMutableString* string = [NSMutableString string];
    if (comment.authorId != [[CCUserInfoProvider sharedProvider] uid] || (comment.authorId == [[CCUserInfoProvider sharedProvider] uid] && comment.toUserId == 0)) {
        [string appendString:[TQRichTextUserNameRun runTextWihtUid:comment.authorId]];
    }
    
    if (comment.toUserId != 0) {
        [string appendFormat:@"回复%@", [TQRichTextUserNameRun runTextWihtUid:comment.toUserId]];
    }
    return string;
}

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run {
    if ([run isKindOfClass:[TQRichTextUserNameRun class]]) {
        NSString* uidString = [[run.originalText componentsSeparatedByString:@"-"] objectAtIndex:1];
        [self.delegate cell:self didSelectUid:uidString.longLongValue];
    }
    if ([run isKindOfClass:[TQRichTextURLRun class]]) {
        [self.delegate cell:self didSelectURL:run.originalText];
    }
}

- (void)didTapOnView:(HHRoundImageView *)view {
    [self.delegate cell:self didSelectUid:self.comment.authorId];
}

- (void)hideArrow:(BOOL)hide {
    self.showArrow = !hide;
}

- (void)showSepLine:(BOOL)show {
    self.sepLine.hidden = !show;
}
@end
