//
//  CCFeedModel.m
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCFeedModel.h"
#import "CCUserInfoProvider.h"

@implementation CCFeedModel

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CCFeedModel class]]) {
        return NO;
    }
    CCFeedModel* model = (CCFeedModel*)object;
    return model.feedId == self.feedId;
}

@end


@implementation CCFeedCommentCountModel


@end