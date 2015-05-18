//
//  CCUserInfoProvider.h
//  testCircle
//
//  Created by Sasori on 14/12/2.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCUserInfoProviderDelegate <NSObject>
- (int64_t)uid;
- (NSString*)findNameForUid:(int64_t)uid;
- (NSString*)avatarForUid:(int64_t)uid;
- (void)getUserBaseInfo:(int64_t)uid;
@end

@interface CCUserInfoProvider : NSObject <CCUserInfoProviderDelegate>
+ (instancetype)sharedProvider;
@property (nonatomic, weak) id<CCUserInfoProviderDelegate> provider;
@end