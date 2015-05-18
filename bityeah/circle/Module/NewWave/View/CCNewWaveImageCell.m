//
//  CCNewWaveImageCell.m
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCNewWaveImageCell.h"

@implementation CCNewWaveImageCell
- (IBAction)deleteAction:(id)sender {
    [self.delegate deleteCell:self];
}

@end
