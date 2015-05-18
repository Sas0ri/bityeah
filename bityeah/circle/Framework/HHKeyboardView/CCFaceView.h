//
//  HHFaceView.h
//  HChat
//
//  Created by Sasori on 14/10/23.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacialView.h"

@interface CCFaceView : UIView
@property (nonatomic, weak) id<FacialViewDelegate> delegate;
@end
