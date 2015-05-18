//
//  HHGifData.h
//  Huhoo
//
//  Created by Sasori on 13-4-25.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHGifData : NSObject
@property (nonatomic, strong) NSArray* frames;
@property (nonatomic, strong) NSArray* delays;
@property (nonatomic, assign) CGFloat totalTime;
@end
