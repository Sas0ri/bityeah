//
//  TQRichTextEmotionManager.h
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TQRichTextEmojiDelegate.h"

@interface TQRichTextEmotionManager : NSObject <TQRichTextEmojiDelegate>
+ (instancetype)sharedMamanger;
@property (nonatomic, weak) id<TQRichTextEmojiDelegate> delegate;
@end
