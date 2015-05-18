//
//  NSString+URLEncode.m
//  HChat
//
//  Created by Sasori on 15/3/26.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

- (NSString *)encodedString {
    if ([self rangeOfString:@"%"].location != NSNotFound) {
        return self;
    }
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
