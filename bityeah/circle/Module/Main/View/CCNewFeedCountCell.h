//
//  CCNewFeedCountCell.h
//  testCircle
//
//  Created by Sasori on 14/12/3.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCNewFeedCountModel;
@interface CCNewFeedCountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) CCNewFeedCountModel* model;
@end
