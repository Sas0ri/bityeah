//
//  TQRichTextEmojiRun.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-21.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextEmojiRun.h"
#import "TQRichTextEmotionManager.h"

@interface TQRichTextEmojiRun()
@property (nonatomic, strong) UIImageView* imageView;
@end

@implementation TQRichTextEmojiRun

static NSMutableSet* _sharedSet = nil;

+ (NSMutableSet*)sharedSet {
    if (_sharedSet == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedSet = [NSMutableSet set];
        });
    }
    return _sharedSet;
}

+ (void)clearSharedSet {
    _sharedSet = nil;
}

+ (UIImageView*)dequeueImageView {
    UIImageView* imageView = [[TQRichTextEmojiRun sharedSet] anyObject];
    if (imageView) {
        [[TQRichTextEmojiRun sharedSet] removeObject:imageView];
    }
    return imageView;
}

+ (void)enqueueImageView:(UIImageView*)imageView {
    [[TQRichTextEmojiRun sharedSet] addObject:imageView];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextEmojiRunType;
        self.isResponseTouch = NO;
    }
    return self;
}

- (BOOL)drawRunWithRect:(CGRect)rect inView:(UIView *)view
{
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:self.originalText];
    
    if (image)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextDrawImage(context, rect, image.CGImage);
//        CGAffineTransform textTran = CGAffineTransformIdentity;
//        textTran = CGAffineTransformMakeTranslation(0.0, view.bounds.size.height);
//        textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
//        rect = CGRectApplyAffineTransform(rect, textTran);
//        
//        UIImageView* imageView = [TQRichTextEmojiRun dequeueImageView];
//        if (!imageView) {
//            imageView = [[UIImageView alloc] init];
//        }
//        imageView.frame = rect;
//        imageView.image = image;
//        
//        [view addSubview:imageView];
//        self.imageView = imageView;
    }
    
    return YES;
}

+ (NSArray *)analyzeText:(NSMutableAttributedString *)string
{
    if (!string) {
        return nil;
    }
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    [ps setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSInteger offset = 0;
    
    NSError *error;
    NSString *regulaStr = @"\\[/[^\\]]*\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string.string options:0 range:NSMakeRange(0, [string length])];
    
    NSMutableArray* runArray = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSRange matchRange = NSMakeRange(match.range.location + offset, match.range.length);

        NSString* substringForMatch = [string.string substringWithRange:matchRange];
        NSString* emotion = [substringForMatch substringWithRange:NSMakeRange(2, substringForMatch.length -3)];
        
        NSString* faceValue = [[TQRichTextEmotionManager sharedMamanger] faceValueForFaceKey:emotion];
        if (faceValue.length == 0) {
            continue;
        }
        @autoreleasepool {
            TQRichTextEmojiRun* attach = [[TQRichTextEmojiRun alloc] init];
            attach.range = matchRange;
            attach.originalText = emotion;
            
            CGFloat length = attach.range.length;
            [attach replaceTextWithAttributedString:string];
            offset += attach.range.length - length;
            
            [runArray addObject:attach];
        }
    }
    return runArray;
}

- (void)dealloc {
//    [self.imageView removeFromSuperview];
//    if (self.imageView) {
//        [TQRichTextEmojiRun enqueueImageView:self.imageView];
//    }
}

@end
