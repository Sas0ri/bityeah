//
//  HHViewController.h
//  CheckInApp
//
//  Created by Albert on 14-6-17.
//  Copyright (c) 2014年 wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIHelper.h"

@interface HHViewController : UIViewController

@property (retain, nonatomic) UIView *contentView;
@property (nonatomic, retain) FUIButton* backButton;

- (NSString*)_backTitle;
- (void)backAction:(id)sender;
- (void)setNavigationBar;

@end
