//
//  HHEmotionManager.h
//  HChat
//
//  Created by Sasori on 13-8-23.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TQRichTextEmojiDelegate.h"

@interface HHEmotionManager : NSObject <TQRichTextEmojiDelegate>
@property (nonatomic, readonly) NSDictionary* emotions;
+ (HHEmotionManager*)sharedManager;
- (NSString*)faceKeyForFaceValue:(NSString*)value;
- (NSString*)gifKeyForFaceValue:(NSString*)value;
- (NSString*)replaceFaceKeyWithValue:(NSString*)content;
- (NSString *)replaceFaceValueWithKey:(NSString *)content;
- (NSString*)faceValueForFaceKey:(NSString*)key;
@end
