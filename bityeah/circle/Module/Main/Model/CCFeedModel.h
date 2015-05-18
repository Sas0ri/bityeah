//
//  CCFeedModel.h
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCFeedCommentCountModel;
@class PBWave;
@class PBRedPacket;
@class PBSystemSender;

@interface CCFeedModel : NSObject

@property (nonatomic, assign) int64_t feedId;
@property (nonatomic, assign) int64_t senderId;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSArray* pictures;
@property (nonatomic, strong) NSArray* firstPageComments;
@property (nonatomic, assign) int64_t updateAt;
@property (nonatomic, assign) int64_t createAt;
@property (nonatomic, strong) CCFeedCommentCountModel* commentCountModel;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) SInt32 type;
@property (nonatomic, assign) SInt32 itemType;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) PBSystemSender* systemSender;
@property (nonatomic, strong) PBRedPacket *redPacket;
@end


@interface CCFeedCommentCountModel : NSObject
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) int64_t likedId;

@end