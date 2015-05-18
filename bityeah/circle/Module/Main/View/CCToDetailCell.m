//
//  CCToDetailCell.m
//  HChat
//
//  Created by Sasori on 15/1/27.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCToDetailCell.h"

@interface CCToDetailCell()
@end

@implementation CCToDetailCell

- (void)awakeFromNib {
    self.bgView.image = [[UIImage imageNamed:@"bg_comment_list"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 100)];
    self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect r = self.commentView.frame;
    r.size.width = self.bounds.size.width - 60 - 14;
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height - 5;
    self.commentView.frame = r;
    
    r = self.bgView.frame;
    r.size.width = self.bounds.size.width - 60 - 14;
    r.size.height = CGRectGetHeight(self.commentView.frame) + 18;
    r.origin.y = CGRectGetHeight(self.frame) - r.size.height;
    self.bgView.frame = r;
    
    r = self.ellipsisImageView.frame;
    r.size.width = 27/2;
    r.size.height = 5/2;
    self.ellipsisImageView.frame = r;
    
}

@end
