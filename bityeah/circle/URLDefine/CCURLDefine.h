//
//  CCURLDefine.h
//  testCircle
//
//  Created by Sasori on 14/12/8.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//




static NSString* kBaseUrl = @"http://api.circle.huhoo.com";
static NSString* kStoreUploadUrl = @"http://store.circle.huhoo.com/upload";
static NSString* kStoreDownloadUrl = @"http://store.circle.huhoo.com/download";

@interface CCURLDefine : NSObject

+ (NSString*)HDPath:(NSString*)path;
+ (NSString*)thumbnailPath:(NSString*)path;

@end