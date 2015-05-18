//
//  HHPreViewController.h
//  HChat
//
//  Created by Wong on 14-10-22.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol HHPreViewDelegate <NSObject>

@optional
- (void)selectAlAsset:(ALAsset *)alAsset withSelectAllAlAssets:(NSMutableArray *)alAssets;
- (void)disSelectAlAsset:(ALAsset *)alAsset withDisSelectAllAlAssets:(NSMutableArray *)alAssets;
- (void)sendSelectAlAssets:(NSMutableArray *)alAssets;

@end

@interface HHPreViewController : UIViewController

@property (assign, nonatomic) id <HHPreViewDelegate> delegate;

- (id)initWithAlAsset:(NSMutableArray *)selectAssets;

@end
