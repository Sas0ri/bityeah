//
//  HHUtilityKeyboardView.h
//  HChat
//
//  Created by Sasori on 14/10/24.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHUtilityKeyboardView;

@protocol HHUtilityKeyboardDelegate <NSObject>
- (void)utilityViewPickImageFromCamara:(HHUtilityKeyboardView*)view;
- (void)utilityViewPickImageFromLibrary:(HHUtilityKeyboardView*)view;
@end

@interface HHUtilityKeyboardView : UIView
@property (nonatomic, weak) id<HHUtilityKeyboardDelegate> delegate;
@end


@interface HHUtilityKeyboardItem : NSObject
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) UIImage* image;
@end

@interface HHUtilityKeyboardCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* label;
@end

