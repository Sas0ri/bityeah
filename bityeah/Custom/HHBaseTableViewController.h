//
//  HHBaseTableViewController.h
//  Huhoo
//
//  Created by Sasori on 13-6-13.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIHelper.h"

@interface HHBaseTableViewController : UITableViewController

@property (nonatomic, strong) FUIButton* backButton;
- (NSString*)_backTitle;
- (void)backAction:(id)sender;
- (BOOL)shouldInteractivePop;

@end
