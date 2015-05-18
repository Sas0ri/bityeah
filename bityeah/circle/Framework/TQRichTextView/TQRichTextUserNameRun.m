//
//  TQRichTextUserNameRun.m
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "TQRichTextUserNameRun.h"
#import "UIColor+FlatUI.h"
#import "CCUserInfoProvider.h"

@implementation TQRichTextUserNameRun

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
    NSString* text = [self.originalText substringWithRange:NSMakeRange(2, self.originalText.length -3)];
    NSRange range = [text rangeOfString:@"-"];
    if (range.location == NSNotFound || range.location == text.length - 1) {
        return;
    }
    NSString* userName = [text substringFromIndex:range.location+1];
    if (userName) {
        [attributedString replaceCharactersInRange:self.range withString:userName];
        self.range = NSMakeRange(self.range.location, userName.length);
        
        [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorFromHexCode:@"586c93"].CGColor range:self.range];
        [super replaceTextWithAttributedString:attributedString];
    }
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
    NSString *regulaStr = @"\\[-[^\\]]*\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string.string options:0 range:NSMakeRange(0, [string length])];
    CGFloat offset = 0;
    NSMutableArray* runArray = [NSMutableArray array];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSRange matchRange = NSMakeRange(match.range.location + offset, match.range.length);
        NSString* substringForMatch = [string.string substringWithRange:matchRange];
        
        TQRichTextUserNameRun *attach = [[TQRichTextUserNameRun alloc] init];
        attach.range = matchRange;
        attach.originalText = substringForMatch;
        
        if ([attach uid] == 0 || [attach name].length == 0) {
            continue;
        }
        [runArray addObject:attach];
        
        CGFloat length = attach.range.length;
        [attach replaceTextWithAttributedString:string];
        offset += attach.range.length - length;
    }
     return [runArray copy];
}

+ (NSString *)runTextWihtUid:(int64_t)uid {
    NSString* name = [[CCUserInfoProvider sharedProvider] findNameForUid:uid];
    NSString* UserName = [NSString stringWithFormat:@"[-%@-%@]", @(uid), name];
    return UserName;
}

+ (NSString *)runTextWihtUid:(int64_t)uid name:(NSString *)name {
    NSString* UserName = [NSString stringWithFormat:@"[-%@-%@]", @(uid), name];
    return UserName;
}


- (int64_t)uid {
    NSString* text = [self.originalText substringWithRange:NSMakeRange(2, self.originalText.length -3)];
    NSRange range = [text rangeOfString:@"-"];
    if (range.location == NSNotFound || range.location == text.length - 1) {
        return 0;
    }
    NSString* userId = [text substringToIndex:range.location];
    return userId.longLongValue;
}

- (NSString*)name {
    NSString* text = [self.originalText substringWithRange:NSMakeRange(2, self.originalText.length -3)];
    NSRange range = [text rangeOfString:@"-"];
    if (range.location == NSNotFound || range.location == text.length - 1) {
        return @"";
    }
    NSString* userName = [text substringFromIndex:range.location+1];
    return userName;
}
@end
