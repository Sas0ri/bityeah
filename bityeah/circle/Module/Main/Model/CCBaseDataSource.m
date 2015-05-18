//
//  CCBaseDataSource.m
//  testCircle
//
//  Created by Sasori on 14/12/16.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCBaseDataSource.h"
#import "PBWaveBody+Transform.h"
#import "PBWaveComment+Transform.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "CCUserInfoProvider.h"
#import "CCURLDefine.h"
#import "UIImage+fixOrientation.h"
#import "CCFeedPicture.h"
#import "Circle.pb.h"
#import "File.pb.h"
#import "CCEncodeUtils.h"
#import "NSData+CommonCrypto.h"
#import "CCWaveParser.h"
#import "Context.h"

@interface CCBaseDataSource()
@end

@implementation CCBaseDataSource

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
        _backgroundQueue = dispatch_queue_create("CCBaseDataSource", 0);
    }
    return _backgroundQueue;
}

- (void)sendComment:(NSString *)comment waveId:(int64_t)waveId to:(int64_t)to success:(void (^)(CCFeedComment*))success failure:(void (^)())failure {
    PBWaveCommentBuilder* builder = [PBWaveComment builder];
    [builder setWaveId:waveId];
    if (to > 0) {
        [builder setToPassportId:to];
    }
    [builder setFromPassportId:[[CCUserInfoProvider sharedProvider] uid]];
    [builder setType:PBWaveCommentTypeTypeComment];
    
    
    PBWaveBody* body = [[[PBWaveBody builder] setItemsArray:[PBWaveBody itemsWithString:comment]] build];
    [builder setBody:body];
    
    PBSendWaveCommentReq* req = [[[PBSendWaveCommentReq builder] setComment:[builder build]] build];
    
    PBFrame* frame = [[[[PBFrame builder] setCmd:PBFrameCmdCmdSendWaveComment] setExtension:[CircleRoot sendWaveCommentReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* frame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBSendWaveCommentResp* resp = [frame getExtension:[CircleRoot sendWaveCommentResp]];
        if (frame.errorCode == 0) {
            PBWaveComment* c = resp.comment;
            [self.persistentDataStore saveComment:c];
            
            PBFetchWaveIdsRespPBWaveAbstract* ab = [self.persistentDataStore abstractForId:c.waveId];
            if (ab) {
                NSMutableArray* commentIds = [NSMutableArray array];
                [commentIds addObject:@(c.id)];
                if (ab.topTextCommentIds.count > 0) {
                    [commentIds addObject:@([ab.topTextCommentIds int64AtIndex:0])];
                }
                PBFetchWaveIdsRespPBWaveAbstractBuilder* aBuilder = [PBFetchWaveIdsRespPBWaveAbstract builder];
                [aBuilder mergeFrom:ab];
                [aBuilder setTextCommentCount:ab.textCommentCount+1];
                NSMutableArray* arr = [NSMutableArray array];
                [arr addObject:@(c.id)];
                [ab.topTextCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [arr addObject:obj];
                }];
                [aBuilder setTopTextCommentIdsArray:arr];
                [self.persistentDataStore saveAbstract:[aBuilder build]];
            }
            CCFeedComment* comment = [self parseComment:c];
            success(comment);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)likeWithWaveId:(int64_t)waveId success:(void (^)(CCFeedComment*))success failure:(void (^)())failure {
    PBWaveCommentBuilder* builder = [PBWaveComment builder];
    [builder setWaveId:waveId];
    [builder setFromPassportId:[[CCUserInfoProvider sharedProvider] uid]];
    [builder setType:PBWaveCommentTypeTypeLike];
    
    PBSendWaveCommentReq* req = [[[PBSendWaveCommentReq builder] setComment:[builder build]] build];

    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdSendWaveComment] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot sendWaveCommentReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* frame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBSendWaveCommentResp* resp = [frame getExtension:[CircleRoot sendWaveCommentResp]];
        if (frame.errorCode == 0) {
            PBWaveComment* c = resp.comment;
            PBFetchWaveIdsRespPBWaveAbstract* ab = [self.persistentDataStore abstractForId:c.waveId];
            if (ab) {
                ab = [[[[[ab builder] mergeFrom:ab] setLikeCommentCount:ab.likeCommentCount+1] setYouLikeCommentId:c.id] build];
                [self.persistentDataStore saveAbstract:ab];
            }
            
            CCFeedComment* fc = [self parseComment:resp.comment];
            success(fc);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)deleteCommentWithId:(int64_t)commentId waveId:(int64_t)waveId type:(int)type success:(void (^)())success failure:(void (^)())failure {
    PBDeleteWaveCommentReq* req = [[[PBDeleteWaveCommentReq builder] setWaveCommentIdsArray:@[@(commentId)]] build];
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdDeleteWaveComment] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot deleteWaveCommentReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBDeleteWaveCommentResp* resp = [respFrame getExtension:[CircleRoot deleteWaveCommentResp]];
        if (resp.deletedWaveCommentIds.count > 0) {
            PBFetchWaveIdsRespPBWaveAbstract* ab = [self.persistentDataStore abstractForId:waveId];
            PBFetchWaveIdsRespPBWaveAbstractBuilder* aBuilder = [[PBFetchWaveIdsRespPBWaveAbstract builder] mergeFrom:ab];
            if (type == PBWaveCommentTypeTypeLike) {
                [aBuilder setYouLikeCommentId:0];
                [aBuilder setLikeCommentCount:ab.likeCommentCount-1];
            } else {
                [aBuilder setTextCommentCount:ab.textCommentCount-1];
                NSMutableArray* arr = [NSMutableArray array];
                [ab.topTextCommentIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSNumber* cid = (NSNumber*)obj;
                    if (commentId != cid.longLongValue) {
                        [arr addObject:cid];
                    }
                }];
                [aBuilder setTopTextCommentIdsArray:arr];
            }
            [self.persistentDataStore saveAbstract:[aBuilder build]];
            success();
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)sendWaveWithText:(NSString *)text pictures:(NSArray *)pictures success:(void (^)(CCFeedModel*))success failure:(void (^)())failure {
    NSInteger count = pictures.count;
    NSMutableArray* pics = [NSMutableArray array];
    NSMutableDictionary* picDic = [NSMutableDictionary dictionary];
    if (count > 0) {
        dispatch_async(self.backgroundQueue, ^{
            for (int i=0; i<pictures.count;i++) {
                UIImage* image = pictures[i];
                UIImage* fixedImage = [image fixOrientation];
                NSData* data = UIImageJPEGRepresentation(fixedImage, 0.6);
                [self uploadImageData:data success:^(NSString *url) {
                    if (url.length == 0) {
                        failure();
                        return ;
                    }
                    CCFeedPicture* fp = [CCFeedPicture new];
                    fp.size = fixedImage.size;
                    fp.relativeURLString = url;
                    [picDic setObject:fp forKey:@(i)];
                    if (picDic.allValues.count == count) {
                        for (int i=0; i<pictures.count; i++) {
                            [pics addObject:picDic[@(i)]];
                        }
                        [self sendWaveWithText:text pictureItems:pics success:^(PBWave* wave){
                            [self.persistentDataStore saveWave:wave];
                            [self.persistentDataStore addFirstPageWaveId:wave.id];
                            CCFeedModel* model = [self parseWave:wave];
                            success(model);
                        } failure:^{
                            failure();
                        }];
                    }
                } failure:^{
                    failure();
                }];
            }
        });
    } else {
        [self sendWaveWithText:text pictureItems:nil success:^(PBWave* wave){
            [self.persistentDataStore saveWave:wave];
            [self.persistentDataStore addFirstPageWaveId:wave.id];
            CCFeedModel* model = [self parseWave:wave];
            success(model);
        } failure:^{
            failure();
        }];
    }
}

- (void)sendWaveWithText:(NSString*)text pictureItems:(NSArray*)pictures success:(void (^)(PBWave*))success failure:(void (^)())failure {
    
    PBWaveBuilder* wb = [[PBWave builder] setType:PBWaveTypeTypeCommon];
    [wb setSenderPassportId:[[CCUserInfoProvider sharedProvider] uid]];
    PBWaveBodyBuilder* bb = [PBWaveBody builder];
    NSMutableArray* items = [NSMutableArray arrayWithArray:[PBWaveBody itemsWithString:text]];
    for (CCFeedPicture* pic in pictures) {
        PBWaveBodyItemPicture* bip = [[[[[PBWaveBodyItemPicture builder] setPictureUrl:pic.relativeURLString] setWidth:pic.size.width] setHeight:pic.size.height] build];
        PBWaveBodyItem* item = [[[[[PBWaveBodyItem builder] setPicture:bip] setType:PBWaveBodyItemTypeTypePicture] setPictureUrl:pic.relativeURLString] build];
        [items addObject:item];
    }
    [bb setItemsArray:items];
    [wb setBody:[bb build]];
    
    PBSendWaveReq* req = [[[[PBSendWaveReq builder] setWave:[wb build]] setParkId:[Context sharedContext].parkId] build];
    
    PBFrame* frame = [[[[PBFrame builder] setCmd:PBFrameCmdCmdSendWave] setExtension:[CircleRoot sendWaveReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBSendWaveResp* respWave = [respFrame getExtension:[CircleRoot sendWaveResp]];
        if ([respWave hasWave]) {
            success(respWave.wave);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *url))success failure:(void (^)())failure {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"signature"] = [CCEncodeUtils getSignature:params];
    params[@"sender_passport_id"] = @([[CCUserInfoProvider sharedProvider] uid]);
    params[@"type"] = @(PBFileTypeTypePicture);
    params[@"belong_app"] = @(PBFileAppAppCircle);
    int timeStamp = [[NSDate date] timeIntervalSince1970]*1000;
    NSString* fileName = [NSString stringWithFormat:@"%d", timeStamp];
    params[@"original_name"] = fileName;
    params[@"md5"] = [CCEncodeUtils hexStringFromData:[imageData MD5Sum]];
    
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kStoreUploadUrl]];
    NSMutableURLRequest* req = [client multipartFormRequestWithMethod:@"POST" path:nil parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"uploadfile" fileName:@"123.jpg" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBUploadFileResp* fileResp = [PBUploadFileResp parseFromData:responseObject];
        if (fileResp.file) {
            success(fileResp.file.relativeUrl);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [op start];
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

- (void)getCommentsByIds:(NSArray*)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure {
    PBFetchWaveCommentReqBuilder* rb = [PBFetchWaveCommentReq builder];
    [rb setCommentIdsArray:commentIds];
    
    PBFrame* frame = [[[[[PBFrame builder] setCmd:PBFrameCmdCmdFetchWaveComment] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] setExtension:[CircleRoot fetchWaveCommentReq] value:[rb build]] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    request.HTTPBody = [frame data];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBFetchWaveCommentResp* resp = [respFrame getExtension:[CircleRoot fetchWaveCommentResp]];
        if (respFrame.errorCode == 0) {
            NSMutableArray* result = [NSMutableArray array];
            for (PBWaveComment* comment in resp.comments) {
                CCFeedComment* c = [self parseComment:comment];
                [result addObject:c];
            }
            [self sortComments:result];
            success(result);
            dispatch_async(self.backgroundQueue, ^{
                [self.persistentDataStore saveComments:resp.comments];
            });
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)findCommentsByIds:(NSArray *)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure {
    NSMutableArray* commentsToGet = [NSMutableArray array];
    NSMutableArray* result = [NSMutableArray array];
    for (NSNumber* commentId in commentIds) {
        PBWaveComment* comment = [self.persistentDataStore commentForId:commentId.longLongValue];
        if (comment) {
            CCFeedComment* c = [self parseComment:comment];
            [result addObject:c];
        } else {
            [commentsToGet addObject:commentId];
        }
    }
    if (commentsToGet.count > 0) {
        [self getCommentsByIds:commentsToGet success:^(NSArray *comments) {
            [result addObjectsFromArray:comments];
            [self sortComments:result];
            success(result);
        } failure:^{
            failure();
        }];
    } else {
        [self sortComments:result];
        success(result);
    }
}

- (void)sortComments:(NSMutableArray*)arr {
    NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"commentId" ascending:NO];
    [arr sortUsingDescriptors:@[sd]];
}

- (void)findWavesByIds:(NSArray*)ids success:(void (^)(NSArray *))success failure:(void (^)())failure {
    dispatch_async(self.backgroundQueue, ^{
        NSMutableArray* arr = [NSMutableArray array];
        NSMutableArray* idsToGet = [NSMutableArray array];
        for (NSNumber* waveId in ids) {
            PBWave* wave = [self.persistentDataStore waveForId:waveId.longLongValue];
            if (!wave || wave.type == PBWaveTypeTypeRedPacket) {
                [idsToGet addObject:waveId];
            } else {
                CCFeedModel* model = [self parseWave:wave];
                PBFetchWaveIdsRespPBWaveAbstract* ab = [self.persistentDataStore abstractForId:waveId.longLongValue];
                CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
                cm.likedId = ab.youLikeCommentId;
                cm.likeCount = ab.likeCommentCount;
                cm.commentCount = ab.textCommentCount;
                model.commentCountModel = cm;
                [arr addObject:model];
            }
        }
        if (idsToGet.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(arr);
            });
        } else {
            [self getWavesByIds:idsToGet success:^(NSArray *waves) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [arr addObjectsFromArray:waves];
                    success(arr);
                });
            } failure:^{
                failure();
            }];
        }
        
    });
}

- (void)findWaveById:(int64_t)waveId success:(void (^)(CCFeedModel *))success failure:(void (^)())failure {
    PBWave* wave = [self.persistentDataStore waveForId:waveId];
    if (!wave) {
        [self getWaveById:waveId success:^(CCFeedModel *model) {
            success(model);
        } failure:^{
            failure();
        }];
    } else {
        CCFeedModel* model = [self parseWave:wave];
        PBFetchWaveIdsRespPBWaveAbstract* ab = [self.persistentDataStore abstractForId:waveId];
        CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
        cm.likedId = ab.youLikeCommentId;
        cm.likeCount = ab.likeCommentCount;
        cm.commentCount = ab.textCommentCount;
        model.commentCountModel = cm;
        success(model);
    }
}

- (void)getWaveById:(int64_t)waveId success:(void (^)(CCFeedModel *))success failure:(void (^)())failure {
    [self getWavesByIds:@[@(waveId)] success:^(NSArray * waves) {
        success([waves firstObject]);
    } failure:^{
        failure();
    }];
}

- (void)clearMyCommentSuccess:(void (^)())success failure:(void (^)())failure {
    
    [self.persistentDataStore saveUnread:[NSArray array]];

    PBFrame* frame = [[[[PBFrame builder] setCmd:PBFrameCmdCmdClearMyWaveComment] setPassportId:[[CCUserInfoProvider sharedProvider] uid]] build];
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        if (respFrame.errorCode == 0) {
            if (success) {
                success();
            }
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [op start];
}

- (CCFeedModel*)parseWave:(PBWave*)wave {
    return [CCWaveParser parseWave:wave];
}

- (CCFeedComment*)parseComment:(PBWaveComment*)com {
    PBWaveComment* c = com;
    CCFeedComment* comment = [CCFeedComment new];
    comment.comment = [c comment];
    comment.authorId = c.fromPassportId;
    comment.toUserId = c.toPassportId;
    comment.commentId = c.id;
    comment.timeStamp = c.createdAt;
    comment.feedId = com.waveId;
    comment.type = com.type;
    return comment;
}

@end
