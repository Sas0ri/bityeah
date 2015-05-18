//
//  CCBaseDataSource.h
//  testCircle
//
//  Created by Sasori on 14/12/16.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFeedComment.h"
#import "CCFeedModel.h"
#import "CCPersistentDataStore.h"
#import "AFHTTPClient.h"

@interface CCBaseDataSource : NSObject
@property (nonatomic, strong) CCPersistentDataStore* persistentDataStore;
@property (nonatomic, strong) AFHTTPClient* client;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

- (void)findCommentsByIds:(NSArray*)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure;
- (void)findWavesByIds:(NSArray*)ids success:(void (^)(NSArray *))success failure:(void (^)())failure;
- (void)findWaveById:(int64_t)waveId success:(void (^)(CCFeedModel*))success failure:(void (^)())failure;
- (void)sendComment:(NSString*)comment waveId:(int64_t)waveId  to:(int64_t)to success:(void (^)(CCFeedComment*))success failure:(void (^)())failure;
- (void)deleteCommentWithId:(int64_t)commentId waveId:(int64_t)waveId type:(int)type success:(void (^)())success failure:(void (^)())failure;
- (void)likeWithWaveId:(int64_t)waveId success:(void (^)(CCFeedComment*))success failure:(void (^)())failure;
- (void)sendWaveWithText:(NSString*)text pictures:(NSArray*)pictures success:(void (^)(CCFeedModel* model))success failure:(void (^)())failure;
- (void)getWaveById:(int64_t)waveId success:(void (^)(CCFeedModel*))success failure:(void (^)())failure;
- (void)getCommentsByIds:(NSArray*)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure;
- (void)clearMyCommentSuccess:(void (^)())success failure:(void (^)())failure;
- (CCFeedModel*)parseWave:(PBWave*)wave;
- (CCFeedComment*)parseComment:(PBWaveComment*)comment;
@end
