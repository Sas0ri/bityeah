//
//  CCNewWaveViewController.h
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHBaseViewController.h"

@protocol CCNewWaveViewControllerDelegate <NSObject>
- (void)sendWave:(NSString*)text pictures:(NSArray*)pics success:(void (^)())success failure:(void (^)())failure;
@optional
- (void)dismissAction;
@end

@interface CCNewWaveViewController : HHBaseViewController
@property (nonatomic, strong) NSMutableArray* assets;
@property (nonatomic, weak) id<CCNewWaveViewControllerDelegate> delegate;
@end

@interface CCImage : NSObject
@property (nonatomic, strong) UIImage* thumbnail;
@property (nonatomic, strong) UIImage* image;
@end