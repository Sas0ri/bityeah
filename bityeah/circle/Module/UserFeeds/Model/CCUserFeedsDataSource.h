//
//  CCUserFeedsDataSource.h
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PBSystemSender;
@interface CCUserFeedsDataSource : NSObject
- (void)updateSuccess:(void (^)())success failure:(void (^)())failure;
- (void)loadMoreSuccess:(void (^)())success failure:(void (^)())failure;
@property (nonatomic, strong) NSMutableArray* feeds;
@property (nonatomic, assign) int64_t userId;
@property (nonatomic, strong) PBSystemSender* systemSender;
@property (nonatomic, assign) BOOL hasMore;
@end
