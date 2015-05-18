//
//  CCDetailDataSource.m
//  testCircle
//
//  Created by Sasori on 14/12/16.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCDetailDataSource.h"
#import "Circle.pb.h"
#import "CCUserInfoProvider.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "CCURLDefine.h"
#import "CCPersistentDataStore.h"
#import "CCWaveParser.h"
#import "CCBaseDataSource.h"

@interface CCDetailDataSource()
@property (nonatomic, strong) NSMutableArray* commentIds;

@end

@implementation CCDetailDataSource

- (NSMutableArray *)comments {
    if (_comments == nil) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

- (NSMutableArray *)likeComments {
    if (_likeComments == nil) {
        _likeComments = [NSMutableArray array];
    }
    return _likeComments;
}

- (void)getWaveSuccess:(void (^)(CCFeedModel *))success failure:(void (^)())failure {
    [self findWaveById:self.waveId success:^(CCFeedModel *model) {
        self.feedModel = model;
        success(model);
    } failure:^{
        failure();
    }];
}

- (void)updateCommentsSuccess:(void (^)())success failure:(void (^)())failure {
    PBFetchWaveCommentIdsReq* req = [[[PBFetchWaveCommentIdsReq builder] setWaveId:self.waveId] build];
    
    PBFrame* frame = [[[[[PBFrame builder] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setCmd:PBFrameCmdCmdFetchWaveCommentIds] setExtension:[CircleRoot fetchWaveCommentIdsReq] value:req] build];
    if (!self.feedModel.commentCountModel) {
        CCFeedCommentCountModel* countModel = [CCFeedCommentCountModel new];
        self.feedModel.commentCountModel = countModel;
    }
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    request.HTTPBody = [frame data];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBFetchWaveCommentIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveCommentIdsResp]];
        if (respFrame.errorCode == 0) {
            self.feedModel.commentCountModel.commentCount = resp.totalTextCommentCount;

            self.hasMore = resp.hasMore;
            __block int unfinished = 0;
            if (resp.ids.likeCommentIds.count > 0 ) {
                unfinished += 1;
            }
            if (resp.ids.textCommentIds.count > 0) {
                unfinished +=1;
            }
            if (!unfinished) {
                success();
            }
            if (resp.ids.likeCommentIds.count > 0) {
                NSMutableArray* commentIds = [NSMutableArray array];
                [resp.ids.likeCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [commentIds addObject:obj];
                }];
                [self findCommentsByIds:commentIds success:^(NSArray * comments) {
                    unfinished-=1;
                    self.likeComments = [comments mutableCopy];
                    self.feedModel.commentCountModel.likeCount = comments.count;
                    [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        CCFeedComment* c = (CCFeedComment*)obj;
                        if (c.authorId == [[CCUserInfoProvider sharedProvider] uid]) {
                            self.feedModel.commentCountModel.likedId = c.commentId;
                            *stop = YES;
                        }
                    }];
                    if (!unfinished) {
                        success();
                    }
                } failure:^{
                    failure();
                }];
            }
            if (resp.ids.textCommentIds.count > 0) {
                NSMutableArray* commentIds = [NSMutableArray array];
                [resp.ids.textCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [commentIds addObject:obj];
                }];
                [self findCommentsByIds:commentIds success:^(NSArray * comments) {
                    self.comments = [comments mutableCopy];
                    unfinished-=1;
                    if (!unfinished) {
                        success();
                    }
                } failure:^{
                    failure();
                }];
            }
 
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)loadMoreCommentsSuccess:(void (^)())success failure:(void (^)())failure {
    CCFeedComment* comment = [self.comments lastObject];
    int64_t lastCommentId = comment.commentId;
    
    PBFetchWaveCommentIdsReq* req = [[[[PBFetchWaveCommentIdsReq builder] setWaveId:self.waveId] setBeforeTextCommentId:lastCommentId] build];
    
    PBFrame* frame = [[[[[PBFrame builder] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setCmd:PBFrameCmdCmdFetchWaveCommentIds] setExtension:[CircleRoot fetchWaveCommentIdsReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    request.HTTPBody = [frame data];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBFetchWaveCommentIdsResp* resp = [respFrame getExtension:[CircleRoot fetchWaveCommentIdsResp]];
        if (respFrame.errorCode == 0) {
            self.hasMore = resp.hasMore;
           
            if (resp.ids.textCommentIds.count > 0) {
                NSMutableArray* commentIds = [NSMutableArray array];
                [resp.ids.textCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [commentIds addObject:obj];
                }];
                [self getCommentsByIds:commentIds success:^(NSArray * comments) {
                    [self.comments addObjectsFromArray:comments];
                    success();
                } failure:^{
                    failure();
                }];
            } else {
                success();
            }
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)deleteWaveSuccess:(void (^)())success failure:(void (^)())failure {
    PBDeleteWaveReq* req = [[[PBDeleteWaveReq builder] setWaveIdsArray:@[@(self.waveId)]] build];
    
    PBFrame* frame = [[[[[PBFrame builder] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setCmd:PBFrameCmdCmdDeleteWave] setExtension:[CircleRoot deleteWaveReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    request.HTTPBody = [frame data];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        if (respFrame.errorCode == 0) {
            [self.persistentDataStore deleteWaveById:self.waveId];
            success();
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (CCFeedModel*)parseWave:(PBWave*)wave {
    return [CCWaveParser parseWave:wave];
}

@end
