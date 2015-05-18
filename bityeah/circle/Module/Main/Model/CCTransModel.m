//
//  CCTransModel.m
//  HChat
//
//  Created by Wong on 15/4/23.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCTransModel.h"

@implementation CCTransModel

+ (CCTransModel *)share
{
    static CCTransModel *shareModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareModel = [[CCTransModel alloc]init];
    });
    return shareModel;
}

@end
