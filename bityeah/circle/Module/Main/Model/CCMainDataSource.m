//
//  CCMainDataSource.m
//  testCircle
//
//  Created by Sasori on 14/12/4.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMainDataSource.h"
#import "CCUserInfoProvider.h"
#import "AFHTTPClient.h"
#import "Circle.pb.h"
#import "CCFeedModel.h"
#import "AFHTTPRequestOperation.h"
#import "PBWaveBody+Transform.h"
#import "UIImage+fixOrientation.h"
#import "CCEncodeUtils.h"
#import "File.pb.h"
#import "NSData+CommonCrypto.h"
#import "CCNewFeedCountModel.h"
#import "CCURLDefine.h"
#import "PBWaveComment+Transform.h"
#import "CCFeedComment.h"
#import "CCFeedPicture.h"
#import "CCWaveParser.h"
#import "CCMyCommentModel.h"
#import "CCPersistentDataStore.h"
#import "Context.h"

@interface CCMainDataSource()
@property (nonatomic, strong) AFHTTPRequestOperation* loadMoreOperation;
@end

@implementation CCMainDataSource

- (void)loadLocalSuccess:(void (^)(NSArray*))success failure:(void (^)())failure {
    dispatch_async(self.backgroundQueue, ^{
        NSArray* abs = [self.persistentDataStore loadFirstPageAbstracts];
        NSMutableArray* feeds = [NSMutableArray array];
        for (PBFetchWaveIdsRespPBWaveAbstract* ab in abs) {
            PBWave* wave = [self.persistentDataStore waveForId:ab.waveId];
            CCFeedModel* model = [self parseWave:wave];
            CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
            cm.likeCount = ab.likeCommentCount;
            cm.commentCount = ab.textCommentCount;
            cm.likedId = ab.youLikeCommentId;
            model.commentCountModel = cm;
            [feeds addObject:model];
            
            NSMutableArray* comments = [NSMutableArray array];
            [ab.topTextCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSNumber* commentId = (NSNumber*)obj;
                PBWaveComment* c = [self.persistentDataStore commentForId:commentId.longLongValue];
                if (c) {
                    CCFeedComment* comment = [self parseComment:c];
                    [comments addObject:comment];
                }
            }];
            model.firstPageComments = comments;
        }
        CCNewFeedCountModel* fc = [CCNewFeedCountModel new];
        fc.commentIds = [self.persistentDataStore getUnread];
        self.myCommentModel = fc;
        self.hasMore = feeds.count >= 20;
        if (feeds.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                success(feeds);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), failure);
        }
    });
}

- (void)updateSuccess:(void (^)(NSArray*))success failure:(void (^)())failure {
    [self.loadMoreOperation cancel];
    
    PBFetchWaveIdsReqBuilder* req = [[PBFetchWaveIdsReq builder] setSystemSenderId:[Context sharedContext].parkId];
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaveIds] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWaveIdsReq] value:[req build]] build];
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(self.backgroundQueue, ^{
            PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
            PBFetchWaveIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveIdsResp]];
            self.hasMore = resp.hasMore;
            self.redPackets = resp.redPackets;
            
            CCNewFeedCountModel* cm = [CCNewFeedCountModel new];
            NSMutableArray* commentIds = [NSMutableArray array];
            [resp.myCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [commentIds addObject:obj];
            }];
            cm.commentIds = commentIds;
            self.myCommentModel = cm;
            
            [self.persistentDataStore addMyCommentIds:commentIds];
            [self loadWavesAndCommentsForAbstracts:resp.abstracts success:^(NSArray *feeds) {
                
                dispatch_async(self.backgroundQueue, ^{
                    NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"feedId" ascending:NO];
                    NSArray* result = [feeds sortedArrayUsingDescriptors:@[sd]];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        success(result);
                    });
                    [self.persistentDataStore saveFirstPageAbstracts:resp.abstracts];
                    [self.persistentDataStore saveUnread:commentIds];
                });
            } failure:^{
                failure();
            }];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.hasMore = NO;
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
    
}

- (void)loadWavesAndCommentsForAbstracts:(NSArray*)abstracts success:(void (^)(NSArray*))success failure:(void (^)())failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block NSMutableArray* waves = [NSMutableArray array];
        NSMutableArray* comments = [NSMutableArray array];
        NSMutableArray* commentsToGet = [NSMutableArray array];
        NSMutableArray* waveIds = [NSMutableArray array];
        NSMutableDictionary* abDic = [NSMutableDictionary dictionary];
        for (PBFetchWaveIdsRespPBWaveAbstract* abstract in abstracts) {
            abDic[@(abstract.waveId)] = abstract;
            [abstract.topTextCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSNumber* commentId = (NSNumber*)obj;
                PBWaveComment* c = [self.persistentDataStore commentForId:commentId.longLongValue];
                if (!c) {
                    [commentsToGet addObject:obj];
                } else {
                    CCFeedComment* fc = [self parseComment:c];
                    [comments addObject:fc];
                }
            }];
            [waveIds addObject:@(abstract.waveId)];
        }
        [self findWavesByIds:waveIds success:^(NSArray *arr) {
            waves = [arr mutableCopy];
            for (CCFeedModel* model in waves) {
                PBFetchWaveIdsRespPBWaveAbstract* ab = abDic[@(model.feedId)];
                [self compositeWave:model withAbstract:ab];
            }
            if (commentsToGet.count > 0) {
                [self getCommentsByIds:commentsToGet success:^(NSArray *comArray) {
                    [comments addObjectsFromArray:comArray];
                    [self compositeWaves:waves withComments:comments];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(waves);
                    });
                } failure:^{
                    failure();
                }];
            } else {
                [self compositeWaves:waves withComments:comments];
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(waves);
                });
            }
        } failure:^{
            failure();
        }];
    });
}

- (void)compositeWaves:(NSArray*)waves withComments:(NSArray*)comments {
    for (CCFeedModel* model in waves) {
        NSArray* waveComments = [comments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"feedId == %lld", model.feedId]];
        NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"commentId" ascending:NO];
        waveComments = [waveComments sortedArrayUsingDescriptors:@[sd]];
        model.firstPageComments = waveComments;
    }
}

- (void)compositeWave:(CCFeedModel*)model withAbstract:(PBFetchWaveIdsRespPBWaveAbstract*)abstract {
    PBFetchWaveIdsRespPBWaveAbstract* ab = abstract;
    CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
    cm.likedId = ab.youLikeCommentId;
    cm.likeCount = ab.likeCommentCount;
    cm.commentCount = ab.textCommentCount;
    model.commentCountModel = cm;
}

- (void)loadWaveAndCommentForAbstract:(PBFetchWaveIdsRespPBWaveAbstract*)abstract success:(void (^)(CCFeedModel*))success failure:(void (^)())failure {
    void (^commentsComplete)(NSArray* comments, CCFeedModel* model) = ^(NSArray* comments, CCFeedModel* model) {
        NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"commentId" ascending:NO];
        comments = [comments sortedArrayUsingDescriptors:@[sd]];
        model.firstPageComments = comments;
        success(model);
    };
    
    void (^waveComplete)(CCFeedModel* model) = ^(CCFeedModel* model) {
        NSMutableArray* comments = [NSMutableArray array];
        NSMutableArray* commentsToGet = [NSMutableArray array];
        [abstract.topTextCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber* commentId = (NSNumber*)obj;
            PBWaveComment* c = [self.persistentDataStore commentForId:commentId.longLongValue];
            if (!c) {
                [commentsToGet addObject:obj];
            } else {
                CCFeedComment* fc = [self parseComment:c];
                [comments addObject:fc];
            }
        }];
        
        if (commentsToGet.count > 0) {
            [self getCommentsByIds:commentsToGet success:^(NSArray *coms) {
                [comments addObjectsFromArray:coms];
                commentsComplete(comments, model);
            } failure:^{
                failure();
            }];
        } else {
            commentsComplete(comments, model);
        }
    };
    [self findWaveById:abstract.waveId success:^(CCFeedModel *model) {
        dispatch_async(self.backgroundQueue, ^{
            PBFetchWaveIdsRespPBWaveAbstract* ab = abstract;
            CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
            cm.likedId = ab.youLikeCommentId;
            cm.likeCount = ab.likeCommentCount;
            cm.commentCount = ab.textCommentCount;
            model.commentCountModel = cm;
            waveComplete(model);
        });
    } failure:^{
        failure();
    }];
}

- (void)loadMoreWithWaveId:(int64_t)waveId success:(void (^)(NSArray *))success failure:(void (^)())failure {
    PBFetchWaveIdsReqBuilder* req = [PBFetchWaveIdsReq builder];
    [req setBeforeWaveId:waveId];
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaveIds] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWaveIdsReq] value:[req build]] build];
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(self.backgroundQueue, ^{
            PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
            PBFetchWaveIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveIdsResp]];
            
            self.hasMore = resp.hasMore;
            
            [self loadWavesAndCommentsForAbstracts:resp.abstracts success:^(NSArray *feeds) {
                NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"feedId" ascending:NO];
                feeds =  [feeds sortedArrayUsingDescriptors:@[sd]];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    success(feeds);
                });

            } failure:^{
                failure();
            }];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    self.loadMoreOperation = op;
    [op start];
}

- (void)cancelLoadMore {
    [self.loadMoreOperation cancel];
}



@end
