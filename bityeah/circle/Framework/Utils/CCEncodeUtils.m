//
//  CCEncodeUtils.m
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCEncodeUtils.h"
#import "NSData+CommonCrypto.h"

@implementation CCEncodeUtils

static NSString* kToken = @"kdkf1afg14adfad3do23244p;.flinefadfeoidfaodif";

+ (NSString *)getSignature:(NSMutableDictionary *)params {
    int64_t timeStamp = (int64_t)([[NSDate date] timeIntervalSince1970]*1000);
    int nonce = arc4random();
    params[@"timestamp"] = @(timeStamp);
    params[@"nonce"] = @(nonce);
    
    NSMutableArray* arr = [NSMutableArray array];
    for (NSNumber* number in params.allValues) {
        [arr addObject:[NSString stringWithFormat:@"%@", number]];
    }
    [arr addObject:kToken];
    [arr sortUsingSelector:@selector(compare:)];
    
    NSString* temp = [arr componentsJoinedByString:@""];
    NSData* tempData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    tempData = [tempData SHA1Hash];
    temp = [CCEncodeUtils hexStringFromData:tempData];
    return temp;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

@end
