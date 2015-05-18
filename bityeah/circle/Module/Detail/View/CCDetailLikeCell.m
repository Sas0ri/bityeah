//
//  CCDetailLikeCell.m
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCDetailLikeCell.h"
#import "TQRichTextURLRun.h"
#import "TQRichTextUserNameRun.h"
#import "UIColor+FlatUI.h"
#import "CCFeedModel.h"

@interface CCDetailLikeCell() <TQRichTextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@end

@implementation CCDetailLikeCell

- (void)awakeFromNib {
    self.likePeopleView.delegate = self;
    self.likePeopleView.font = [UIFont systemFontOfSize:15];
    self.bgView.image = [[UIImage imageNamed:@"bg_comment_list"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 100)];
    self.sepLine.backgroundColor = [UIColor colorFromHexCode:@"e2e3e5"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    CGRect r = self.likePeopleView.frame;
    r.size.width = self.bounds.size.width - 56;
    self.likePeopleView.frame = r;
    self.likePeopleView.numberOfLines = self.expanded ? NSIntegerMax : 1;
    self.likePeopleView.text = content;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.likePeopleView.frame;
    r.size.height = self.bounds.size.height - 37;
    r.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(r))/2;
    r.origin.y += 8;
    self.likePeopleView.frame = r;
    
    r = self.likeIcon.frame;
    r.origin.x = 22;
    r.origin.y = 57/2 - CGRectGetHeight(self.likeIcon.frame)/2;
    r.origin.y += 8;
    self.likeIcon.frame = r;
    
    r = self.bgView.frame;
    r.size.width = self.bounds.size.width - 20;
    r.size.height = CGRectGetHeight(self.frame);
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height;
    self.bgView.frame = r;
    
    r = self.sepLine.frame;
    r.origin.x = self.bgView.frame.origin.x;
    r.size.width = self.bgView.frame.size.width;
    r.origin.y = self.frame.size.height - .5;
    r.size.height = .5;
    self.sepLine.frame = r;
}

+ (CGFloat)heightForString:(NSString *)text forWidth:(CGFloat)width expanded:(BOOL)expanded {
    CGFloat result = 0;
    if (!expanded) {
        result = 55;
    } else {
        TQRichTextView* textView = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 0, width - 56, 0)];
        textView.font = [UIFont systemFontOfSize:15];
        textView.text = text;
        [textView sizeToFit];
        result = textView.bounds.size.height + 37;
        if (result < 55) {
            result = 55;
        }
    }
    return result;
}

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run {
    if ([run isKindOfClass:[TQRichTextUserNameRun class]]) {
        NSString* uidString = [[run.originalText componentsSeparatedByString:@"-"] objectAtIndex:1];
        CCFeedModel* model = [CCFeedModel new];
        model.senderId = uidString.longLongValue;
        self.model = model;
        [self.delegate cell:self didSelectUid:uidString.longLongValue];
    }
    if ([run isKindOfClass:[TQRichTextURLRun class]]) {
        [self.delegate cell:self didSelectURL:run.originalText];
    }
}

- (void)showSepLine:(BOOL)show {
    self.sepLine.hidden = !show;
}

@end
