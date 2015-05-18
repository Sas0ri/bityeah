//
//  CCURLDefine.m
//  testCircle
//
//  Created by Sasori on 14/12/9.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCURLDefine.h"

@implementation CCURLDefine

+ (NSString *)HDPath:(NSString *)path {
    NSString* result = kStoreDownloadUrl;
    if ([path hasPrefix:@"/"]) {
        result = [result stringByAppendingString:path];
    } else {
        result = [result stringByAppendingFormat:@"/%@", path];
    }
    return result;
}

+ (NSString *)thumbnailPath:(NSString *)path {
    return [[self HDPath:path] stringByAppendingString:@"_thumbnail"];
}

@end
