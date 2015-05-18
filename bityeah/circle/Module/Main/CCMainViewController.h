//
//  CCMainViewController.h
//  circle
//
//  Created by Sasori on 14/11/26.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHBaseViewController.h"

@interface CCMainViewController : UIViewController
@property (nonatomic, strong) UINavigationController* navigationController;
@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end
