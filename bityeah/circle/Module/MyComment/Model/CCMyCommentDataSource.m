//
//  CCMyCommentDataSource.m
//  testCircle
//
//  Created by Sasori on 14/12/18.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMyCommentDataSource.h"
#import "CCMyCommentModel.h"
#import "CCFeedPicture.h"

@implementation CCMyCommentDataSource

- (void)getMyCommentsByIds:(NSArray *)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure {
    [self getCommentsByIds:commentIds success:^(NSArray *comments) {
        NSMutableArray* arr = [NSMutableArray array];
        for (CCFeedComment* comment in comments) {
            [arr addObject:@(comment.feedId)];
        }
        [self findWavesByIds:arr success:^(NSArray *waves) {
            NSMutableDictionary* waveDic = [NSMutableDictionary dictionary];
            for (CCFeedModel* model in waves) {
                waveDic[@(model.feedId)] = model;
            }
            NSMutableArray* result = [NSMutableArray array];
            for (CCFeedComment* comment in comments) {
                CCFeedModel* model = waveDic[@(comment.feedId)];
                CCMyCommentModel* cm = [CCMyCommentModel new];
                cm.comment = comment;
                cm.feedContent = model.content;
                CCFeedPicture* fp = [model.pictures firstObject];
                cm.feedPicutre = fp.relativeURLString;
       
                [result addObject:cm];
            }
            
            NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"comment.timeStamp" ascending:NO];
            [result sortUsingDescriptors:@[sd]];
            success(result);
        } failure:^{
            failure();
        }];
    } failure:^{
        failure();
    }];
}

- (void)clearMyCommentSuccess:(void (^)())success failure:(void (^)())failure {
    [super clearMyCommentSuccess:success failure:failure];
    [self.persistentDataStore removeMyCommentIds];
}

- (void)clearServerMyCommentSuccess:(void (^)())success failure:(void (^)())failure {
    [super clearMyCommentSuccess:success failure:failure];
}

- (NSArray*)loadMyCommentIds {
    NSArray* myCommentIds = [self.persistentDataStore findMyCommentIds];
    return myCommentIds;
}

@end
