//
//  CCWaveParser.h
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCFeedModel.h"
#import "Circle.pb.h"

@interface CCWaveParser : NSObject
+ (CCFeedModel*)parseWave:(PBWave*)wave;
@end
