//
//  TQRichTextEmotionManager.m
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "TQRichTextEmotionManager.h"
#import "HHEmotionManager.h"

@implementation TQRichTextEmotionManager

+ (instancetype)sharedMamanger {
    static TQRichTextEmotionManager* _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [TQRichTextEmotionManager new];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = [HHEmotionManager sharedManager];
    }
    return self;
}

- (NSString *)faceValueForFaceKey:(NSString *)key {
    return [self.delegate faceValueForFaceKey:key];
}


@end
