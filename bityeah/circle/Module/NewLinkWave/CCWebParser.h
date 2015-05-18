//
//  CCWebParser.h
//  HChat
//
//  Created by Sasori on 15/4/8.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadTitleImageBlock)(NSString* title, NSString* imageSrc);

@interface CCWebParser : NSObject
- (void)loadURL:(NSString*)url completion:(LoadTitleImageBlock)block;
@end
