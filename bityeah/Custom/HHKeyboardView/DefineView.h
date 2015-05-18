//
//  DefineView.h
//  HChat
//
//  Created by Sasori on 13-10-11.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacialView.h"

@interface DefineView : UIView
@property(nonatomic,weak) id<FacialViewDelegate>delegate;

- (void)loadFacialView:(int)page size:(CGSize)size;

- (void)loadFacialView:(int)page size:(CGSize)size middleSpace:(CGFloat)space;

@end
