//
//  CCUserLinkTableCell.m
//  HChat
//
//  Created by Sasori on 15/4/8.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCUserLinkTableCell.h"

@interface CCUserLinkTableCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutWidth;
@end

@implementation CCUserLinkTableCell

- (void)setModel:(CCFeedModel *)model {
    [super setModel:model];
    self.contentLabel.text = model.content;
    [self.userNameButton setTitle:self.sendName forState:UIControlStateNormal];
    CGSize size = [self.sendName sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(200, MAXFLOAT)];
    self.layoutWidth.constant = ceil(size.width);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.contentLabel.frame;
    if (self.model.content.length > 0) {
        r.size.width = self.contentView.bounds.size.width - 70;
        r.origin.x = 60;
        r.origin.y = 45;
        self.contentLabel.frame = r;
        [self.contentLabel sizeToFit];
    } else {
        self.contentLabel.frame = CGRectMake(60, 45, 0, 0);
    }
    
    r = self.linkBaseView.frame;
    r.origin.y = CGRectGetMaxY(self.contentLabel.frame) + 8;
    self.linkBaseView.frame = r;
    
    r = self.likeButton.frame;
    r.origin.y = CGRectGetMaxY(self.linkBaseView.frame) + 10;
    self.likeButton.frame = r;
    
    r = self.commentButton.frame;
    r.origin.y = CGRectGetMaxY(self.linkBaseView.frame) + 10;
    self.commentButton.frame = r;
}

+ (CGFloat)heightForModel:(CCFeedModel *)model {
    CGFloat height = 145;
    if (model.content.length > 0) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 70, 0)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = model.content;
        [label sizeToFit];
        height += label.bounds.size.height;
    }
    return height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
