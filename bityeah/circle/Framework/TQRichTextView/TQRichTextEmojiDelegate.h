//
//  TQRichTextEmojiDelegate.h
//  testCircle
//
//  Created by Sasori on 14/12/1.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TQRichTextEmojiDelegate <NSObject>
- (NSString*)faceValueForFaceKey:(NSString*)key;
@end
