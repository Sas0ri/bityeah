//
//  TQRichTextUserNameRun.h
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "TQRichTextBaseRun.h"

@interface TQRichTextUserNameRun : TQRichTextBaseRun
+ (NSArray *)analyzeText:(NSMutableAttributedString *)string;
+ (NSString*)runTextWihtUid:(int64_t)uid;
- (int64_t)uid;
- (NSString*)name;
+ (NSString *)runTextWihtUid:(int64_t)uid name:(NSString*)name;
@end
