//
//  CCFeedComment.m
//  testCircle
//
//  Created by Sasori on 14/12/9.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCFeedComment.h"

@implementation CCFeedComment

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CCFeedComment class]]) {
        return NO;
    }
    CCFeedComment* comment = (CCFeedComment*)object;
    return comment.commentId == self.commentId;
}

@end
