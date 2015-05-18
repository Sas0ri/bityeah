//
//  CCUserDetailTimeView.h
//  HChat
//
//  Created by Wong on 15/2/9.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCUserDetailTimeView : UIView

@property (weak, nonatomic) IBOutlet UILabel *relativeDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@end
