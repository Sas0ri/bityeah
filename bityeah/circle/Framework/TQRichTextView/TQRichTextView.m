//
//  TQRichTextView.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-12.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextView.h"
#import <CoreText/CoreText.h>
#import "TQRichTextEmojiRun.h"
#import "TQRichTextURLRun.h"
#import "TQRichTextUserNameRun.h"

@interface TQRichTextView()
@property (nonatomic, strong) NSAttributedString* attributedString;
@end

@implementation TQRichTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        //_textAnalyzed = [self analyzeText:_text];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _text = @"";
    _font = [UIFont systemFontOfSize:14.0];
    _textColor = [UIColor blackColor];
    _lineSpacing = 1.5;
    //
    _richTextRunsArray = [[NSMutableArray alloc] init];
    _richTextRunRectDic = [[NSMutableDictionary alloc] init];
    
    UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tg.cancelsTouchesInView = YES;
    [self addGestureRecognizer:tg];

    UILongPressGestureRecognizer* pg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    pg.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:pg];
}

- (void)setupAttributeString {
    _attributedString = [self analyzeText:_text];
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect
{
    if (!self.attributedString) {
        return;
    }
    //绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);

    //绘制
    int lineCount = 0;
    CFRange lineRange = CFRangeMake(0,0);
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
    float drawLineX = 0;
    float drawLineY = self.bounds.origin.y + self.bounds.size.height - self.font.ascender;
    BOOL drawFlag = YES;
    [self.richTextRunRectDic removeAllObjects];
    
    while(drawFlag)
    {
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location,self.bounds.size.width);
        lineRange = CFRangeMake(lineRange.location,testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter,lineRange);
        
        //如果超过指定行数，或者超过最大高度，画省略号
        if ((self.numberOfLines > 0 && lineCount == self.numberOfLines - 1)|| (self.maxHeight > 0 && (self.lineSpacing + self.font.ascender - self.font.descender)*(lineCount+2) > self.maxHeight) ) {
            static NSString* const kEllipsesCharacter = @"\u2026";
            
            CFRange lastLineRange = CTLineGetStringRange(line);
            if (lineRange.location + lineRange.length < (CFIndex)self.attributedString.length) {
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                
                NSDictionary *tokenAttributes = [self.attributedString attributesAtIndex:truncationAttributePosition
                                                                          effectiveRange:NULL];
                NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter
                                                                                  attributes:tokenAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
                
                NSMutableAttributedString *truncationString = [[self.attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any whitespace at the end of the line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
                    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                }
                [truncationString appendAttributedString:tokenString];
                
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.bounds.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }
                CFRelease(truncationLine);
                CFRelease(truncationToken);
                
                //                CTLineDraw(truncatedLine, context);
                //                CFRelease(truncatedLine);
                CFRelease(line);
                line = truncatedLine;
                
                drawFlag = NO;
            }
        }
        
        //绘制普通行元素
        drawLineX = CTLineGetPenOffsetForFlush(line,0,self.bounds.size.width);
        CGContextSetTextPosition(context,drawLineX,drawLineY);
        CTLineDraw(line,context);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        //绘制替换过的特殊文本单元
        for (int i = 0; i < CFArrayGetCount(runs); i++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            TQRichTextBaseRun *textRun = [attributes objectForKey:@"TQRichTextAttribute"];
            if (textRun)
            {
                CGFloat runAscent,runDescent;
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runHeight = runAscent + (-runDescent);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat runPointY = drawLineY - (-runDescent);
                
                CGRect runRect = CGRectMake(runPointX, runPointY, runWidth, runHeight);
                
                BOOL isDraw = [textRun drawRunWithRect:runRect inView: self];
                if (textRun.isResponseTouch)
                {
                    if (isDraw)
                    {
                        [self.richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                    }
                    else
                    {
                        runRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
                        runRect.origin.x = runPointX;
                        [self.richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                    }
                }
            }
        }
        
        CFRelease(line);
        
        if(lineRange.location + lineRange.length >= self.attributedString.length)
        {
            drawFlag = NO;
        }
        
        lineCount++;
        drawLineY -= self.font.ascender + (- self.font.descender) + self.lineSpacing;
        lineRange.location += lineRange.length;
    }
    CFRelease(typeSetter);
}

- (CGSize)sizeThatFits:(CGSize)size {
//    _textAnalyzed = [self analyzeText:_text];
    
    if (!self.attributedString) {
        return CGSizeZero;
    }
    CGFloat width = 0;

    int lineCount = 0;
    CFRange lineRange = CFRangeMake(0,0);
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
    float drawLineX = 0;
    float drawLineY = self.bounds.origin.y + self.bounds.size.height - self.font.ascender;
    BOOL drawFlag = YES;
    
    while(drawFlag)
    {
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location, size.width);

        lineRange = CFRangeMake(lineRange.location,testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter,lineRange);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        //边界检查
        CTRunRef lastRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
        CGFloat lastRunAscent;
        CGFloat laseRunDescent;
        CGFloat lastRunWidth  = CTRunGetTypographicBounds(lastRun, CFRangeMake(0,0), &lastRunAscent, &laseRunDescent, NULL);
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(lastRun).location, NULL);
        
        width = width < lastRunPointX + lastRunWidth? lastRunPointX+lastRunWidth : width;

        CFRelease(line);
        if(lineRange.location + lineRange.length >= self.attributedString.length)
        {
            drawFlag = NO;
        }
        
        lineCount++;
        drawLineY -= self.font.ascender + (- self.font.descender) + self.lineSpacing;
        lineRange.location += lineRange.length;
    }
    CFRelease(typeSetter);
    CGSize result = CGSizeMake(ceil(width), ceil(lineCount*(self.lineSpacing + self.font.ascender - self.font.descender)-self.lineSpacing));
    return result;
}

#pragma mark - Analyze Text
//-- 解析文本内容
- (NSMutableAttributedString *)analyzeText:(NSString *)string
{
    [self.richTextRunsArray removeAllObjects];
    [self.richTextRunRectDic removeAllObjects];
    
    if (!string || string.length == 0) {
        return nil;
    }
    
    NSMutableArray *array = self.richTextRunsArray;
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:string];
    
    //设置字体
    CTFontRef aFont = CTFontCreateWithName((CFStringRef)_font.fontName, _font.pointSize, NULL);
    [attString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:NSMakeRange(0,attString.length)];
    CFRelease(aFont);
    
    //设置颜色
    [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)_textColor.CGColor range:NSMakeRange(0,attString.length)];
    
    NSArray* arr = [TQRichTextEmojiRun analyzeText:attString];
    [array addObjectsFromArray:arr];

    arr = [TQRichTextURLRun analyzeText:attString];
    [array addObjectsFromArray:arr];

    arr = [TQRichTextUserNameRun analyzeText:attString];
    [array addObjectsFromArray:arr];

    [self.richTextRunsArray makeObjectsPerformSelector:@selector(setOriginalFont:) withObject:self.font];

    return attString;
}



- (void)tapAction:(UITapGestureRecognizer*)sender {
    CGPoint location = [sender locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(richTextView: touchBeginRun:)])
    {
        __weak TQRichTextView *weakSelf = self;
        __block BOOL hasResponse = NO;
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             CGRect rect = [((NSValue *)key) CGRectValue];
             TQRichTextBaseRun *run = obj;
             if(CGRectContainsPoint(rect, runLocation))
             {
                 [weakSelf.delegate richTextView:weakSelf touchBeginRun:run];
                 hasResponse = YES;
             }
         }];
        if (!hasResponse) {
            [weakSelf.delegate richTextView:weakSelf touchBeginRun:nil];
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan ) {
        [self.delegate richTextView:self longPress:sender];
    }
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    __block BOOL hasResponse = NO;
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(richTextView: touchBeginRun:)])
//    {
//        __weak TQRichTextView *weakSelf = self;
//        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//         {
//             CGRect rect = [((NSValue *)key) CGRectValue];
//             TQRichTextBaseRun *run = obj;
//             if(CGRectContainsPoint(rect, runLocation))
//             {
//                 [weakSelf.delegate richTextView:weakSelf touchBeginRun:run];
//                 hasResponse = YES;
//             }
//         }];
//    }
//    if (!hasResponse) {
////        [super touchesBegan:touches withEvent:event];
//        [self.delegate richTextView:self touchBeginRun:nil];
//    }
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(richTextView: touchEndRun:)])
//    {
//        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//         {
//             __weak TQRichTextView *weakSelf = self;
//             CGRect rect = [((NSValue *)key) CGRectValue];
//             TQRichTextBaseRun *run = obj;
//             if(CGRectContainsPoint(rect, runLocation))
//             {
//                 [weakSelf.delegate richTextView:weakSelf touchEndRun:run];
//             }
//         }];
//    }
//}

#pragma mark - Set
- (void)setText:(NSString *)text
{
    [self setNeedsDisplay];
    _text = text;
    [self setupAttributeString];
}

- (void)setFont:(UIFont *)font
{
    [self setNeedsDisplay];
    _font = font;
    [self setupAttributeString];
}

- (void)setTextColor:(UIColor *)textColor
{
    [self setNeedsDisplay];
    _textColor = textColor;
    [self setupAttributeString];
}

- (void)setLineSpacing:(float)lineSpacing
{
    [self setNeedsDisplay];
    _lineSpacing = lineSpacing;
    [self setupAttributeString];
}

- (void)dealloc {
    
}

@end
















