//
//  CCLoadMoreCellTableViewCell.h
//  testCircle
//
//  Created by Sasori on 14/12/17.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHPullProgressView.h"

@interface CCLoadMoreCell : UITableViewCell
@property (nonatomic, assign) BOOL hasMore;
@property (weak, nonatomic) IBOutlet HHPullProgressView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
