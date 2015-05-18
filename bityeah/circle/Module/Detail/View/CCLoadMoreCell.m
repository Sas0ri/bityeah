//
//  CCLoadMoreCellTableViewCell.m
//  testCircle
//
//  Created by Sasori on 14/12/17.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCLoadMoreCell.h"

@implementation CCLoadMoreCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHasMore:(BOOL)hasMore {
    _hasMore = hasMore;
    if (hasMore) {
        self.label.text = @"正在加载更多...";
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
    } else {
        self.label.text = @"没有更多了";
        self.activityView.hidden = YES;
        [self.activityView stopAnimating];
    }
}

@end
