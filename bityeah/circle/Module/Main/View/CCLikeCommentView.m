//
//  CCLikeCommentView.m
//  testCircle
//
//  Created by Sasori on 14/12/2.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCLikeCommentView.h"

@implementation CCLikeCommentView

- (void)awakeFromNib {
    self.bgView.image = [[UIImage imageNamed:@"circle_likecomment_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 8, 8)];
}

- (void)setHasLiked:(BOOL)hasLiked {
    _hasLiked = hasLiked;
    if (hasLiked) {
        [self.likeButton setTitle:@"取消" forState:UIControlStateNormal];
    } else {
        [self.likeButton setTitle:@"赞" forState:UIControlStateNormal];
    }
}

- (IBAction)likeAction:(id)sender {
    if (self.hasLiked) {
        [self.delegate unlikeAtIndex:self.index];
    } else {
        [self.delegate likeAtIndex:self.index];
    }
}

- (IBAction)commentAction:(id)sender {
    [self.delegate commentActionAtIndex:self.index];
}

@end
