//
//  PBWaveComment+Transform.m
//  testCircle
//
//  Created by Sasori on 14/12/4.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "PBWaveComment+Transform.h"
#import "CCUserInfoProvider.h"
#import "PBWaveBody+Transform.h"

@implementation PBWaveComment (Transform)



- (NSString*)comment {
    return [self.body stringValue];
}

@end
