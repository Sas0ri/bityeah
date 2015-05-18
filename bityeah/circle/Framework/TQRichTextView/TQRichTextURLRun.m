//
//  TQRichTextURLRun.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-23.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextURLRun.h"

@implementation TQRichTextURLRun

- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextURLRunType;
        self.isResponseTouch = YES;
    }
    return self;
}

//-- 替换基础文本
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString
{
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:self.range];
    [super replaceTextWithAttributedString:attributedString];
}

//-- 绘制内容
- (BOOL)drawRunWithRect:(CGRect)rect inView:(UIView *)view
{
    return NO;
}

//-- 解析文本内容
+ (NSArray *)analyzeText:(NSMutableAttributedString *)string
{
    if (!string) {
        return nil;
    }
    //((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
    NSError *error;
    //NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string.string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray* runArray = [NSMutableArray array];
    CGFloat offset1 = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [string.string substringWithRange:match.range];
        TQRichTextURLRun *attach = [[TQRichTextURLRun alloc] init];
        attach.range = match.range;
        attach.originalText = substringForMatch;
        
        [runArray addObject:attach];
        
        attach.range = NSMakeRange(attach.range.location + offset1, attach.range.length);
        CGFloat length = attach.range.length;
        [attach replaceTextWithAttributedString:string];
        offset1 += attach.range.length - length;
    }
    
    return [runArray copy];
}

@end
