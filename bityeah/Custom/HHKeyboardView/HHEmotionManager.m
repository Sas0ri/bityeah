//
//  HHEmotionManager.m
//  HChat
//
//  Created by Sasori on 13-8-23.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import "HHEmotionManager.h"
#import "MsgDefine.h"
#import "HHGifData.h"
#import "SvGifView.h"

@interface HHEmotionManager()
@end

@implementation HHEmotionManager

+ (HHEmotionManager *)sharedManager
{
	static HHEmotionManager* _sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[HHEmotionManager alloc] init];
	});
	return _sharedManager;
}

- (id)init
{
	if (self = [super init]) {
		NSString* path = [[NSBundle mainBundle] pathForResource:@"Emotion" ofType:@"plist"];
		_emotions = [NSDictionary dictionaryWithContentsOfFile:path];
	}
	return self;
}

- (NSString *)faceKeyForFaceValue:(NSString *)value
{
	NSArray* arr = [self.emotions allKeysForObject:value];
	NSString* result = nil;
	for (NSString* str in arr) {
		if ([str hasPrefix:@"face"]) {
			result = str;
			break;
		}
	}
	return result;
}

- (NSString *)faceValueForFaceKey:(NSString *)key {
    return self.emotions[key];
}

- (NSString *)gifKeyForFaceValue:(NSString *)value
{
	NSArray* arr = [self.emotions allKeysForObject:value];
	NSString* result = nil;
	for (NSString* str in arr) {
		if ([str hasPrefix:@"b"]) {
			result = str;
			break;
		}
	}
	return result;
}

- (NSString *)replaceFaceKeyWithValue:(NSString *)content
{
    if (content == nil) {
        return nil;
    }
    NSError* error = nil;
    NSString *regulaStr = @"\\[/[^\\]]*\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSMutableString* resultString = [content mutableCopy];
    __block NSInteger offset = 0;

    [regex enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = NSMakeRange(result.range.location + offset, result.range.length);

        NSString* faceKey = [content substringWithRange:result.range];
        faceKey = [faceKey substringWithRange:NSMakeRange(2, faceKey.length - 3)];
        NSString* value = self.emotions[faceKey];
        if (value.length > 0) {
            value = [NSString stringWithFormat:@"[/%@]", value];
            [resultString replaceCharactersInRange:range withString:value];
            offset += value.length - range.length;
        }
    }];
    return [resultString copy];
}

- (NSString *)replaceFaceValueWithKey:(NSString *)content
{
    if (content == nil) {
        return nil;
    }
    NSError* error = nil;
    //表情以[/xxxx]的形式存在，该正则表达式匹配所有形如[/xxxx]的格式
    NSString *regulaStr = @"\\[/[^\\]]*\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSMutableString* resultString = [content mutableCopy];
    __block NSInteger offset = 0;
    [regex enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = NSMakeRange(result.range.location + offset, result.range.length);

        NSString* faceValue = [content substringWithRange:result.range];
        faceValue = [faceValue substringWithRange:NSMakeRange(2, faceValue.length - 3)];
        NSString* faceKey = [self faceKeyForFaceValue:faceValue];
        if (faceKey.length > 0) {
            faceKey = [NSString stringWithFormat:@"[/%@]", faceKey];
            [resultString replaceCharactersInRange:range withString:faceKey];
            offset += faceKey.length - range.length;
        }
    }];
    return [resultString copy];
}

@end
