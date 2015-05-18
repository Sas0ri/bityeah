//
//  CCTransModel.h
//  HChat
//
//  Created by Wong on 15/4/23.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

//图片、文字转发
@interface CCTransModel : NSObject

@property (nonatomic, strong) UIImage *circleSendImage;
@property (nonatomic, strong) NSString *content;

+ (CCTransModel *)share;


@end
