//
//  CCFeedComment.h
//  testCircle
//
//  Created by Sasori on 14/12/9.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCFeedComment : NSObject
@property (nonatomic, assign) int64_t commentId;
@property (nonatomic, assign) int64_t authorId;
@property (nonatomic, assign) int64_t toUserId;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, assign) int64_t timeStamp;
@property (nonatomic, assign) int64_t feedId;
@property (nonatomic, assign) int type;
@end
