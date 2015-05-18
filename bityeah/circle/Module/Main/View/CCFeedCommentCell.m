//
//  CCFeedCommentCell.m
//  testCircle
//
//  Created by Sasori on 14/12/3.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCFeedCommentCell.h"
#import "TQRichTextUserNameRun.h"
#import "TQRichTextURLRun.h"

@interface CCFeedCommentCell() <TQRichTextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *sepLine;

@end

@implementation CCFeedCommentCell

- (void)awakeFromNib {
    self.bgView.image = [[UIImage imageNamed:@"bg_comment_list"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 100)];
    self.commentView.delegate = self;
    self.commentView.font = [UIFont systemFontOfSize:14];
    self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setComment:(CCFeedComment *)comment {
    _comment = comment;
    NSString* author = [self.class authorForComment:comment];

    NSString* commentString = [NSString stringWithFormat:@"%@：%@", author, comment.comment];
    self.commentView.text = commentString;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.commentView sizeToFit];
    CGRect r = self.commentView.frame;
    r.size.width = self.bounds.size.width - 60 - 14;
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height - 5;
    self.commentView.frame = r;
    
    r = self.bgView.frame;
    r.size.width = self.bounds.size.width - 60 - 14;
    r.size.height = CGRectGetHeight(self.commentView.frame) + 18;
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height;
    self.bgView.frame = r;
    
    r = self.sepLine.frame;
    r.size.height = 0.5;
    r.origin.x = CGRectGetMinX(self.bgView.frame) + 4;
    r.size.width = CGRectGetWidth(self.bgView.frame) - 8;
    r.origin.y = CGRectGetHeight(self.frame) - .5;
    self.sepLine.frame = r;
}

+ (CGFloat)heightForModel:(CCFeedComment *)comment forWidth:(CGFloat)width {
    TQRichTextView* textView = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 0, width-78, 0)];
    NSString* author = [self.class authorForComment:comment];
    NSString* commentString = [NSString stringWithFormat:@"%@：%@", author, comment.comment];
    textView.text = commentString;
    [textView sizeToFit];
    return textView.bounds.size.height + 10;
}

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run {
    if ([run isKindOfClass:[TQRichTextUserNameRun class]]) {
        NSString* uidString = [[run.originalText componentsSeparatedByString:@"-"] objectAtIndex:1];
        [self.delegate cell:self didSelectUid:uidString.longLongValue];
    }
    if ([run isKindOfClass:[TQRichTextURLRun class]]) {
        [self.delegate cell:self didSelectURL:run.originalText];
    }
    if (run == nil) {
        [self.delegate cellDidSelect:self];
    }
}

- (void)showSepLine:(BOOL)show {
    self.sepLine.hidden = !show;
    [self.contentView bringSubviewToFront:self.sepLine];
}

@end
