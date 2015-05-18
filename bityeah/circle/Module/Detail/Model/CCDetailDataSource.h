//
//  CCDetailDataSource.h
//  testCircle
//
//  Created by Sasori on 14/12/16.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFeedModel.h"
#import "CCFeedComment.h"
#import "CCBaseDataSource.h"

@interface CCDetailDataSource : CCBaseDataSource
@property (nonatomic, assign) int64_t waveId;
@property (nonatomic, strong) CCFeedModel* feedModel;
@property (nonatomic, strong) NSMutableArray* likeComments;
@property (nonatomic, strong) NSMutableArray* comments;
@property (nonatomic, assign) BOOL hasMore;
- (void)updateCommentsSuccess:(void (^)())success failure:(void (^)())failure;
- (void)loadMoreCommentsSuccess:(void (^)())success failure:(void (^)())failure;
- (void)deleteWaveSuccess:(void (^)())success failure:(void (^)())failure;
- (void)getWaveSuccess:(void (^)(CCFeedModel*))success failure:(void (^)())failure;
@end
