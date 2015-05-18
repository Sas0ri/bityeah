//
//  CCWaveParser.m
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCWaveParser.h"
#import "CCFeedComment.h"
#import "CCUserInfoProvider.h"
#import "PBWaveComment+Transform.h"
#import "CCFeedPicture.h"
#import "PBWaveBody+Transform.h"
#import "TQRichTextUserNameRun.h"

@implementation CCWaveParser

+ (CCFeedModel *)parseWave:(PBWave *)wave {
    CCFeedModel* model = [CCFeedModel new];
    model.feedId = wave.id;
    model.updateAt = wave.updatedAt;
    model.createAt = wave.createdAt;
    model.senderId = wave.senderPassportId;
    model.type = wave.type;
    model.firstPageComments = [NSArray array];
    
    CCFeedCommentCountModel* cm = [CCFeedCommentCountModel new];
    model.commentCountModel = cm;
    
    model.senderName = [TQRichTextUserNameRun runTextWihtUid:wave.systemSender.id name:wave.systemSender.name];
    model.systemSender = wave.systemSender;
    model.redPacket = wave.redPacket;
    
    NSMutableArray* pics = [NSMutableArray array];
    [wave.body.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PBWaveBodyItem* item = (PBWaveBodyItem*)obj;
//        if (item.type == PBWaveBodyItemTypeTypeText) {
//            model.content = item.text;
//        }
        model.itemType = item.type;
        if (item.type == PBWaveBodyItemTypeTypePicture && item.hasPicture) {
            CCFeedPicture* fp = [CCFeedPicture new];
            fp.size = CGSizeMake(item.picture.width, item.picture.height);
            fp.relativeURLString = item.picture.pictureUrl;
            [pics addObject:fp];
        }else if (item.type == PBWaveBodyItemTypeTypeLink){
            model.title = item.link.title;
            model.link = item.link.url;
            model.content = item.text;
            model.imageURL = item.link.pictureUrl;
        }
    }];
    if (wave.type == PBWaveTypeTypeCommon) {
        model.content = [wave.body stringValue];
    }
    model.pictures = [pics copy];
    return model;
}

@end
