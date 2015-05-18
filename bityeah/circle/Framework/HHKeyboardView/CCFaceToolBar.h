//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FacialView.h"
#import "UIExpandingTextView.h"
#import "KeybaordDefine.h"
//#import "FaceToolBar.h"

NS_ENUM(int, FaceToolBarStatus) {
    FaceToolBarStatusNone,
    FaceToolBarStatusText,
    FaceToolBarStatusVoice,
    FaceToolBarStatusFace,
    FaceToolBarStatusUtility,
};

@protocol CCFaceToolBarDelegate <NSObject>
- (void)sendTextAction:(NSString *)inputText;

@end

@interface CCFaceToolBar : UIView
@property (nonatomic, assign) BOOL shouldChangeFrame;
@property (nonatomic, assign) enum FaceToolBarStatus status;

@property (nonatomic, weak) UIView *theSuperView;
@property (nonatomic, weak) id<CCFaceToolBarDelegate> faceBarDelegate;
@property (nonatomic, strong) NSString* placeHolder;
-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView;
-(void)dismissKeyBoard;
- (CGRect)realFrame;
@end


