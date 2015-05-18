//
//  CCPersistentDataStore.h
//  testCircle
//
//  Created by Sasori on 14/12/15.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.pb.h"

@interface CCPersistentDataStore : NSObject
@property (nonatomic, assign) int64_t uid;
- (NSArray*)loadFirstPageAbstracts;
- (void)saveFirstPageAbstracts:(NSArray*)firstPage;
- (PBFetchWaveIdsRespPBWaveAbstract*)abstractForId:(int64_t)waveId;
- (void)saveAbstract:(PBFetchWaveIdsRespPBWaveAbstract*)abstract;
- (PBWave*)waveForId:(int64_t)waveId;
- (PBWaveComment*)commentForId:(int64_t)commentId;
- (NSArray*)wavedsForIds:(NSArray*)waveIds;
- (NSArray*)commentsForIds:(NSArray*)commentIds;
- (void)saveWave:(PBWave*)wave;
- (void)saveComment:(PBWaveComment*)comment;
- (void)saveWaves:(NSArray*)waves;
- (void)saveComments:(NSArray*)comments;
- (void)deleteWaveById:(int64_t)waveId;
- (void)saveUnread:(NSArray*)commentIds;
- (void)addFirstPageWaveId:(int64_t)waveId;
- (NSArray*)getUnread;
- (void)addMyCommentIds:(NSArray*)commentsIds;
- (NSArray*)findMyCommentIds;
- (void)removeMyCommentIds;
@end
