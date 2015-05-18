//
//  HHFaceView.m
//  HChat
//
//  Created by Sasori on 14/10/23.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHFaceView.h"
#import "DefineView.h"
#import "HHCustomFaceView.h"
#import "HHDefaultFaceView.h"
#import "KeybaordDefine.h"
#import "CustomSegmentedControl.h"
#import "UIColor+FlatUI.h"

@interface HHFaceView() <FacialViewDelegate, CustomSegmentedControlDelegate>
@property (nonatomic, strong) HHDefaultFaceView* dftView;
@property (nonatomic, strong) HHCustomFaceView* defView;
@property (nonatomic, strong) UIButton* sendButton;
@end

@implementation HHFaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _dftView = [[HHDefaultFaceView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, keyboardHeight - bottomHeight)];
        _dftView.delegate = self;
        [self addSubview:_dftView];
        
        _defView = [[HHCustomFaceView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, keyboardHeight - bottomHeight)];
        _defView.delegate = self;
        _defView.hidden = YES;
        [self addSubview:_defView];

        
//        UIImageView* bottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, keyboardHeight - bottomHeight, frame.size.width, bottomHeight)];
//        bottomBar.image = [UIImage imageNamed:@"emotion_bg"];
//        bottomBar.userInteractionEnabled = YES;
//        [self addSubview:bottomBar];
        
        UIView* bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, keyboardHeight - bottomHeight, frame.size.width, bottomHeight)];
        bottomBar.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomBar];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        line.backgroundColor = [UIColor colorFromHexCode:@"d8d8d8"];
        [bottomBar addSubview:line];
        
        CustomSegmentedControl* csc = [[CustomSegmentedControl alloc] initWithSegmentCount:2 segmentsize:CGSizeMake(48, bottomRealHeight) dividerImage:nil tag:-1 delegate:self];
        csc.frame = CGRectMake(0, 0.5, 118, bottomRealHeight);
        csc.selectedSegmentIndex = 0;
        csc.clipsToBounds = YES;
        [bottomBar addSubview:csc];
        
        UIView* sepLine = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 59, 0, 0.5, bottomBar.frame.size.height)];
        sepLine.backgroundColor = [UIColor colorFromHexCode:@"d8d8d8"];
        [bottomBar addSubview:sepLine];
        
        UIButton* sendButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 52, 4, 45, 29)];
        [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setBackgroundImage:[[UIImage imageNamed:@"sendbutton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[[UIImage imageNamed:@"sendbutton_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateSelected];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [bottomBar addSubview:sendButton];
        _sendButton = sendButton;
    }
    return self;
}

- (void)touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    self.dftView.hidden = segmentIndex == 1;
    self.defView.hidden = !self.dftView.hidden;
    self.sendButton.hidden = self.dftView.hidden;
}

- (void)selectedFacialView:(NSString *)str {
    [self.delegate selectedFacialView:str];
}

- (UIButton *)buttonFor:(CustomSegmentedControl *)segmentedControl atIndex:(NSUInteger)segmentIndex
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 48, bottomRealHeight);
    switch (segmentIndex) {
        case 0:
            [btn setImage:[UIImage imageNamed:@"default_emotion"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"default_emotion_down"] forState:UIControlStateSelected];
            btn.selected = YES;
            break;
        case 1:
            [btn setImage:[UIImage imageNamed:@"define_emotion"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"define_emotion_down"] forState:UIControlStateSelected];
            break;
        default:
            break;
    }
    return btn;
}

- (void)sendAction:(id)sender {
    [self.delegate sendAction:sender];
}

@end
