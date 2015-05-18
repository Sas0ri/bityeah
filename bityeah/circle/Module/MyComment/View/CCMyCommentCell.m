//
//  CCMyCommentCell.m
//  testCircle
//
//  Created by Sasori on 14/12/12.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMyCommentCell.h"
#import "TQRichTextUserNameRun.h"
#import "CCURLDefine.h"
#import "UIImageView+WebCache.h"
#import "CCUtils.h"
#import "TQRichTextURLRun.h"
#import "Circle.pb.h"

@interface CCMyCommentCell() <TQRichTextViewDelegate, HHRoundImageViewDelegate>

@end

@implementation CCMyCommentCell

- (void)awakeFromNib {
    self.authorView.font = [UIFont systemFontOfSize:14];
    self.contentTextView.font = [UIFont systemFontOfSize:14];
    self.feedContentView.font = [UIFont systemFontOfSize:13];
    self.feedContentView.maxHeight = 61;
    self.feedContentView.userInteractionEnabled = NO;
    self.contentTextView.userInteractionEnabled = NO;
    self.authorView.delegate = self;
    self.avatarView.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.contentTextView.frame;
    r.size.height = self.bounds.size.height - 60;
    self.contentTextView.frame = r;
}

- (void)setModel:(CCMyCommentModel *)model {
    _model = model;
    
    self.authorView.text = [TQRichTextUserNameRun runTextWihtUid:model.comment.authorId];
    NSString* avatar = [self.userInfoProvider avatarForUid:model.comment.authorId];
    [self.avatarView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.likeView.hidden = model.comment.type != 1;
    self.contentTextView.text = model.comment.comment;
    self.timeLabel.text = [CCUtils timeStringFromTimeStamp:model.comment.timeStamp];
    self.feedContentView.text = model.feedContent;

    if (model.linkPicture.length > 0) {
        [self.feedImageView setImageWithURL:[NSURL URLWithString:model.linkPicture] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    } else {
        [self.feedImageView setImageWithURL:[NSURL URLWithString:[CCURLDefine thumbnailPath:model.feedPicutre]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    self.feedImageView.hidden = model.feedPicutre.length == 0 && model.linkPicture.length == 0;
    self.feedContentView.hidden = !self.feedImageView.hidden;
}

+ (CGFloat)heightForModel:(CCMyCommentModel *)model forWidth:(CGFloat)width {
    TQRichTextView* textView = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 0, width - 160, 0)];
    textView.font = [UIFont systemFontOfSize:14];
    
    textView.text = model.comment.comment;
    [textView sizeToFit];
    CGFloat height = textView.bounds.size.height;
    height = height < 17 ? 17 : height;
    return height + 60;
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
    [self.delegate cell:self didSelectUid:self.model.comment.authorId];
}

- (void)dealloc {
    
}

@end
