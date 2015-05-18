//
//  CCFeedImageCell.m
//  testCircle
//
//  Created by Sasori on 14/11/27.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCFeedImageCell.h"

@implementation CCFeedImageCell

- (void)setIsLongPress:(BOOL)isLongPress
{
    self.imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [self.imageView addGestureRecognizer:longPress];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        return;
    }
    [self.delegate longPressImage:sender.self.view.tag imageRect:sender.self.view.frame image:self.imageView.image];
}


@end
