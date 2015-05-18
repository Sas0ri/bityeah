//
//  HHPullProgressView.h
//  HChat
//
//  Created by Sasori on 14/11/26.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHPullProgressView : UIView
@property (nonatomic, assign) CGFloat progress;
-(void) startAnimating;
-(void)stopAnimating;
@end
