//
//  CCUserFeedsViewController.h
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHBaseViewController.h"

@class PBSystemSender;
@interface CCUserFeedsViewController : HHBaseViewController
@property (nonatomic, assign) int64_t userId;
@property (nonatomic, strong) PBSystemSender* systemSender;
@end
