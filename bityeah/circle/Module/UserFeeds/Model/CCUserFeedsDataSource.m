//
//  CCUserFeedsDataSource.m
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCUserFeedsDataSource.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "Circle.pb.h"
#import "CCFeedModel.h"
#import "CCWaveParser.h"
#import "CCUserInfoProvider.h"
#import "CCURLDefine.h"
#import "CCPersistentDataStore.h"

@interface CCUserFeedsDataSource()
@property (nonatomic, strong) AFHTTPRequestOperation* loadMoreOperation;
@property (nonatomic, strong) AFHTTPClient* client;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (nonatomic, strong) CCPersistentDataStore* persistentDataStore;
@end

@implementation CCUserFeedsDataSource

- (instancetype)init {
    if (self = [super init]) {
        _persistentDataStore = [CCPersistentDataStore new];
        _persistentDataStore.uid = [[CCUserInfoProvider sharedProvider] uid];
    }
    return self;
}

- (AFHTTPClient *)client {
    if (_client == nil) {
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    }
    return _client;
}

- (dispatch_queue_t)backgroundQueue {
    if (_backgroundQueue == NULL) {
        _backgroundQueue = dispatch_queue_create("CCUserFeedsDataSource", 0);
    }
    return _backgroundQueue;
}


- (void)updateSuccess:(void (^)())success failure:(void (^)())failure {
    [self.loadMoreOperation cancel];
    
    PBFetchWaveIdsReqBuilder* req = [PBFetchWaveIdsReq builder];
    if (self.userId > 0) {
        [req setSenderPassportId:self.userId];
    } else if (self.systemSender != nil) {
        [req setSystemSender:self.systemSender];
    }
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaveIds] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWaveIdsReq] value:[req build]] build];
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(self.backgroundQueue, ^{
            PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
            PBFetchWaveIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveIdsResp]];
            self.hasMore = resp.hasMore;
            
            __block BOOL failed = NO;
            NSMutableArray* feeds = [NSMutableArray array];
            for (PBFetchWaveIdsRespPBWaveAbstract* abstract in resp.abstracts) {
                [self loadWaveAndCommentForAbstract:abstract success:^(CCFeedModel *model) {
                    [feeds addObject:model];
                    if (feeds.count == resp.abstracts.count) {
                        NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"feedId" ascending:NO];
                        [feeds sortUsingDescriptors:@[sd]];
                        self.feeds = feeds;
                        NSMutableArray* feedIds = [NSMutableArray array];
                        for (CCFeedModel* feed in feeds) {
                            [feedIds addObject:@(feed.feedId)];
                        }
                        dispatch_async(dispatch_get_main_queue(), success);
                    }
                } failure:^{
                    if (!failed) {
                        failed = YES;
                        dispatch_async(dispatch_get_main_queue(), failure);
                    }
                }];
            }
            
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
    
}


- (void)loadMoreSuccess:(void (^)())success failure:(void (^)())failure {
    CCFeedModel* feed = [self.feeds lastObject];
    
    PBFetchWaveIdsReqBuilder* req = [PBFetchWaveIdsReq builder];
    if (self.userId > 0) {
        [req setSenderPassportId:self.userId];
    } else if (self.systemSender != nil) {
        [req setSystemSender:self.systemSender];
    }
    [req setBeforeWaveId:feed.feedId];
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaveIds] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWaveIdsReq] value:[req build]] build];
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(self.backgroundQueue, ^{
            PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
            PBFetchWaveIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveIdsResp]];
            self.hasMore = resp.hasMore;
            
            NSMutableArray* feeds = [NSMutableArray array];
            for (PBFetchWaveIdsRespPBWaveAbstract* abstract in resp.abstracts) {
                [self loadWaveAndCommentForAbstract:abstract success:^(CCFeedModel *model) {
                    [feeds addObject:model];
                    if (feeds.count == resp.abstracts.count) {
                        NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"feedId" ascending:NO];
                        [feeds sortUsingDescriptors:@[sd]];
                        [self.feeds addObjectsFromArray:feeds];
                        dispatch_async(dispatch_get_main_queue(), success);
                    }
                } failure:^{
                    dispatch_async(dispatch_get_main_queue(), failure);
                }];
            }
            
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    self.loadMoreOperation = op;
    [op start];
}

- (void)loadWaveAndCommentForAbstract:(PBFetchWaveIdsRespPBWaveAbstract*)abstract success:(void (^)(CCFeedModel*))success failure:(void (^)())failure {
    
    PBWave* wave = [self.persistentDataStore waveForId:abstract.waveId];
    if (!wave) {
        [self getWaveById:abstract.waveId success:^(CCFeedModel *model) {
            success(model);
        } failure:^{
            failure();
        }];
    } else {
        CCFeedModel* model = [self parseWave:wave];
        success(model);
    }
}

- (void)getWavesByIds:(NSArray*)waveIds success:(void (^)(NSArray *))success failure:(void (^)())failure {
    PBFetchWavesReqBuilder* rb = [PBFetchWavesReq builder];
    [rb setWaveIdsArray:waveIds];
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaves] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWavesReq] value:[rb build]] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    request.HTTPBody = [frame data];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBFetchWavesResp* resp = [respFrame getExtension:[CircleRoot fetchWavesResp]];
        if (respFrame.errorCode == 0) {
            NSMutableArray* result = [NSMutableArray array];
            for (PBWave* wave in resp.waves) {
                CCFeedModel* feed = [self parseWave:wave];
                [result addObject:feed];
            }
            success(result);
            dispatch_async(self.backgroundQueue, ^{
                [self.persistentDataStore saveWaves:resp.waves];
            });
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)getWaveById:(int64_t)waveId success:(void (^)(CCFeedModel *))success failure:(void (^)())failure {
    [self getWavesByIds:@[@(waveId)] success:^(NSArray * waves) {
        success([waves firstObject]);
    } failure:^{
        failure();
    }];
}

- (CCFeedModel*)parseWave:(PBWave*)wave {
    return [CCWaveParser parseWave:wave];
}

@end
