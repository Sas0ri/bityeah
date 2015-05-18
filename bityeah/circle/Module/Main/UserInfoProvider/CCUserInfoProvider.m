//
//  CCUserInfoProvider.m
//  testCircle
//
//  Created by Sasori on 14/12/2.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCUserInfoProvider.h"
#import "Context.h"

@implementation CCUserInfoProvider

+ (instancetype)sharedProvider {
    static CCUserInfoProvider* _sharedProvider = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedProvider = [CCUserInfoProvider new];
    });
    return _sharedProvider;
}

- (NSString *)findNameForUid:(int64_t)uid {
    NSString* result = [self.provider findNameForUid:uid];
    if ([result hasPrefix:@"会员"]) {
        [self.provider getUserBaseInfo:uid];
    }
    return result;
}

- (NSString *)avatarForUid:(int64_t)uid {
    return [self.provider avatarForUid:uid];
}

- (int64_t)uid {
    return [self.provider uid];
}

- (void)getUserBaseInfo:(int64_t)uid {
    [self.provider getUserBaseInfo:uid];
}

@end
