//
//  CCSeparateCell.m
//  testCircle
//
//  Created by Sasori on 14/12/18.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCSeparateCell.h"
#import "UIColor+FlatUI.h"

@implementation CCSeparateCell

- (void)awakeFromNib {
    CGRect r = self.sepLine.frame;
    r.size.height = 0.5;
    self.sepLine.frame = r;
    self.sepLine.backgroundColor = [UIColor colorFromHexCode:@"e2e3e5"];
}

@end
