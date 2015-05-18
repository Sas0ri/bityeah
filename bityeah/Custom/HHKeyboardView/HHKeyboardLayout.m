//
//  HHKeyboardLayout.m
//  HChat
//
//  Created by Sasori on 14/10/29.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHKeyboardLayout.h"

@implementation HHKeyboardLayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 40;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end
