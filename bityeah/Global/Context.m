//
//  Context.m
//  bityeah
//
//  Created by Sasori on 15/5/18.
//  Copyright (c) 2015年 bityeah. All rights reserved.
//

#import "Context.h"

@implementation Context

+ (Context *)sharedContext {
    static Context* _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [Context new];
    });
    return _shared;
}

- (BOOL)signedIn {
    return YES;
}

@end
