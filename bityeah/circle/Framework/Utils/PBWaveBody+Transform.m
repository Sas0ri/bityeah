//
//  PBWaveBody+Transform.m
//  testCircle
//
//  Created by Sasori on 14/12/4.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "PBWaveBody+Transform.h"

@implementation PBWaveBody (Transform)

static NSString* kBeginFlag = @"[/";
static NSString* kEndFlag = @"]";

- (NSString *)stringValue {
    NSMutableString* string = [NSMutableString string];
    for (PBWaveBodyItem* item in self.items) {
        if (item.type == PBWaveBodyItemTypeTypeText) {
            [string appendString:item.text];
        }
        if (item.type == PBWaveBodyItemTypeTypeExpression) {
            [string appendFormat:@"%@face%@%@", kBeginFlag, @(item.expressionId), kEndFlag];
        }
    }
    return string;
}

+ (NSArray *)itemsWithString:(NSString *)string {
    NSMutableArray* ret = [NSMutableArray array];
    NSRange r1,r2;
    //	short index = 0;
    NSString* leftContent = string;
    while (leftContent) {
        @autoreleasepool {
            r1 = [leftContent rangeOfString:kBeginFlag];
            if (r1.location != NSNotFound) {
                r2 = [leftContent rangeOfString:kEndFlag options:0 range:NSMakeRange(NSMaxRange(r1), leftContent.length - NSMaxRange(r1))];
                if (r2.location != NSNotFound) {
                    //能够匹配上
                    if (r1.location > 0) {
                        NSString* c = [leftContent substringToIndex:r1.location];
                        PBWaveBodyItemBuilder* ib = [PBWaveBodyItem builder];
                        [ib setType:PBWaveBodyItemTypeTypeText];
                        [ib setText:c];
                        [ret addObject:[ib build]];
                    }
                    NSString* imgStr = [leftContent substringWithRange:NSMakeRange(NSMaxRange(r1), r2.location - NSMaxRange(r1))];
                    if (imgStr.length > 0 && [imgStr hasPrefix:@"face"]) {
                        PBWaveBodyItemBuilder* ib = [PBWaveBodyItem builder];
                        [ib setType:PBWaveBodyItemTypeTypeExpression];
                        [ib setExpressionId:[imgStr substringFromIndex:4].intValue];
                        [ret addObject:[ib build]];
                    } else {
                        PBWaveBodyItemBuilder* ib = [PBWaveBodyItem builder];
                        [ib setType:PBWaveBodyItemTypeTypeText];
                        [ib setText:[NSString stringWithFormat:@"[/%@]", imgStr]];
                        [ret addObject:[ib build]];
                    }
                    if (NSMaxRange(r2) <= leftContent.length) {
                        leftContent = [leftContent substringFromIndex:NSMaxRange(r2)];
                    }
                } else {
                    PBWaveBodyItemBuilder* ib = [PBWaveBodyItem builder];
                    [ib setType:PBWaveBodyItemTypeTypeText];
                    [ib setText:leftContent];
                    [ret addObject:[ib build]];
                    leftContent = nil;
                }
            } else {
                if (leftContent.length > 0) {
                    PBWaveBodyItemBuilder* ib = [PBWaveBodyItem builder];
                    [ib setType:PBWaveBodyItemTypeTypeText];
                    [ib setText:leftContent];
                    [ret addObject:[ib build]];
                }
                break;
            }
        }
    }
    return ret;
}

@end
