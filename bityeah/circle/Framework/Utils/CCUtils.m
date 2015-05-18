//
//  CCUtils.m
//  testCircle
//
//  Created by Sasori on 14/12/17.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCUtils.h"
#import "NSDate+convenience.h"

@implementation CCUtils

+ (NSString *)timeStringFromTimeStamp:(int64_t)timeStamp {
    timeStamp = timeStamp/1000;
    NSString* result = @"";
    NSDate* nowDate = [NSDate date];
    NSDate* timeDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeStamp];
    int64_t nowStamp = [nowDate timeIntervalSince1970];
    int64_t delta = nowStamp - timeStamp;
    if (delta < 60) {
        result = @"现在";
    } else if (delta < 60*60) {
        result = [NSString stringWithFormat:@"%lld分钟前", delta/60];
    } else if (delta < 60*60*24) {
        result = [NSString stringWithFormat:@"%lld小时前", delta/60/60];
    } else if (delta < 60*60*48 && nowDate.day == [timeDate offsetDay:1].day) {
        result = @"昨天";
    } else if (delta < 60*60*24*28) {
        int day = [nowDate timeIntervalSinceDate:timeDate]/24/60/60;
        result = [NSString stringWithFormat:@"%d天前", day];
    } else if (nowDate.year == timeDate.year) {
        result = [NSString stringWithFormat:@"%2d-%2d", timeDate.month, timeDate.day];
    } else {
        result = [NSString stringWithFormat:@"%04d-%02d-%02d", timeDate.year, timeDate.month, timeDate.day];
    }
    return result;
}

@end
