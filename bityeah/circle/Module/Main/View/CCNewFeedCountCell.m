//
//  CCNewFeedCountCell.m
//  testCircle
//
//  Created by Sasori on 14/12/3.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCNewFeedCountCell.h"
#import "CCNewFeedCountModel.h"

@implementation CCNewFeedCountCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(CCNewFeedCountModel *)model {
    _model = model;
    self.countLabel.text = [NSString stringWithFormat:@"%@条新消息", @(model.commentIds.count)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.countLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
}

@end
