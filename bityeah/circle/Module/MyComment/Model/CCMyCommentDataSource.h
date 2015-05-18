//
//  CCMyCommentDataSource.h
//  testCircle
//
//  Created by Sasori on 14/12/18.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCBaseDataSource.h"

@interface CCMyCommentDataSource : CCBaseDataSource

- (NSArray*)loadMyCommentIds;
- (void)getMyCommentsByIds:(NSArray*)commentIds success:(void (^)(NSArray *))success failure:(void (^)())failure;
- (void)clearMyCommentSuccess:(void (^)())success failure:(void (^)())failure;
- (void)clearServerMyCommentSuccess:(void (^)())success failure:(void (^)())failure;
@end
