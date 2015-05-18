//
//  CCMainDataSource.h
//  testCircle
//
//  Created by Sasori on 14/12/4.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUserInfoProvider.h"
#import "CCBaseDataSource.h"
#import "CCNewFeedCountModel.h"

@interface CCMainDataSource : CCBaseDataSource
@property (nonatomic, assign) int64_t lastUpdateStamp;
@property (nonatomic, strong) CCNewFeedCountModel* myCommentModel;
@property (nonatomic, assign) BOOL hasMore;

// add by wong
@property (strong, nonatomic) NSArray *redPackets;
@property (strong, nonatomic) NSArray *abstractDatas;

- (void)loadLocalSuccess:(void (^)(NSArray*))success failure:(void (^)())failure;
- (void)updateSuccess:(void (^)(NSArray*))success failure:(void (^)())failure;
- (void)loadMoreWithWaveId:(int64_t)waveId success:(void (^)(NSArray*))success failure:(void (^)())failure;
@end
