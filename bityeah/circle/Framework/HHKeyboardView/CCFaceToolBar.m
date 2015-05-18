//
//  FaceToolBar.m
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//

#import "CCFaceToolBar.h"
#import "MsgDefine.h"
#import "HHEmotionManager.h"
#import "UIView+MBProgressView.h"
#import "CCFaceView.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"


@interface CCFaceToolBar() <FacialViewDelegate,UIExpandingTextViewDelegate>
@property (nonatomic, strong) NSMutableArray* emotions;
@property (nonatomic, strong) UIView* backView;
@property (nonatomic, strong) UIButton* voiceSendBtn;
@property (nonatomic, strong) UIButton* voiceBtn;
@property (nonatomic, strong) CCFaceView* faceView;
@property (nonatomic, strong) UIView* toolBar;
@property (nonatomic, strong) UIButton* picButton;
@property (nonatomic, strong) UIButton* faceButton;
@property (nonatomic, strong) UIExpandingTextView* textView;
@property (nonatomic, strong) UILabel* placeHolderLabel;

- (void)voiceBtnAction:(id)sender;
- (void)sendAction:(id)sender;
@end

@implementation CCFaceToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_emotions = [NSMutableArray arrayWithCapacity:EmotionCount];
		for (int i = 0; i < EmotionCount; i++) {
			[_emotions addObject:[NSString stringWithFormat:@"face%d",i]];
		}
        
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [self initWithFrame:frame];
    if (self) {

        self.theSuperView = superView;
        
        
        //默认toolBar在视图最下方
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f,superView.bounds.size.height,superView.bounds.size.width,toolBarHeight)];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _toolBar.backgroundColor = [UIColor colorFromHexCode:@"ebecee"];

        //分割线
        UIView* sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBar.frame.size.width, 0.5)];
        sepLine.backgroundColor = [UIColor colorFromHexCode:@"b8b8b8"];
        [_toolBar addSubview:sepLine];
        
		//可以自适应高度的文本输入框
        _textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_voiceBtn.frame) + 4, _toolBar.frame.size.height/2-15, superView.bounds.size.width - 50, 30)];
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
        [_textView.internalTextView setReturnKeyType:UIReturnKeySend];
        _textView.delegate = self;
        _textView.maximumNumberOfLines = 5;
        [_toolBar addSubview:_textView];
		
        _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 200, 30)];
        _placeHolderLabel.font = [UIFont systemFontOfSize:14];
        _placeHolderLabel.textColor = [UIColor lightGrayColor];
        [_textView addSubview:_placeHolderLabel];
        
        //表情按钮
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_faceButton setImage:[UIImage imageNamed:@"chatface"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"chatface_down"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        _faceButton.frame = CGRectMake(CGRectGetMaxX(_textView.frame) + 4, _toolBar.bounds.size.height/2-buttonWh/2,buttonWh+4,buttonWh);
        [_toolBar addSubview:_faceButton];
        
//        //图片按钮
//        _picButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _picButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
//        [_picButton setImage:[UIImage imageNamed:@"chatpic"] forState:UIControlStateNormal];
//        [_picButton setImage:[UIImage imageNamed:@"chatpic_down"] forState:UIControlStateHighlighted];
//        [_picButton addTarget:self action:@selector(utilityBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//        _picButton.frame = CGRectMake(CGRectGetMaxX(_faceButton.frame)+ 5,_toolBar.bounds.size.height/2 - buttonWh/2,buttonWh,buttonWh);
//        [_toolBar addSubview:_picButton];
        
		_backView = [[UIView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
		[superView addSubview:_backView];
		
        _faceView = [[CCFaceView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, keyboardHeight)];
        _faceView.delegate = self;
        _faceView.backgroundColor = [UIColor colorFromHexCode:@"ebecee"];
        [_backView addSubview:_faceView];
        
        [superView addSubview:_toolBar];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.placeHolderLabel.text = placeHolder;
}

- (CGRect)realFrame {
    return self.toolBar.frame;
}

- (void)keyboardWillChangeFrame:(NSNotification*)sender {
    //判断是否是self.textView引起的键盘变化
    if (self.shouldChangeFrame) {
        NSValue* toValue = sender.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect tempToRect = [toValue CGRectValue];
        CGRect toRect = [self.theSuperView convertRect:tempToRect fromView:nil];
        CGRect originToRect = toRect;
        toRect.origin.y -= self.toolBar.bounds.size.height;
        
        NSMutableDictionary* dic = [sender.userInfo mutableCopy];
        //fix bug for iOS6
        if (toRect.origin.x < 0) {
            toRect.origin.y = self.theSuperView.bounds.size.height - self.toolBar.bounds.size.height;
        }
        dic[UIKeyboardFrameEndUserInfoKey] = [NSValue valueWithCGRect:toRect];
        
        NSValue* fromValue = sender.userInfo[UIKeyboardFrameBeginUserInfoKey];
        CGRect tempFromRect = [fromValue CGRectValue];
        CGRect fromRect = [self.theSuperView convertRect:tempFromRect fromView:nil];
        if (!CGRectIntersectsRect(self.theSuperView.bounds, fromRect)) {
            self.status = FaceToolBarStatusText;
        }
        
        //隐藏键盘
        if (!CGRectIntersectsRect(originToRect, self.theSuperView.bounds) && self.status == FaceToolBarStatusNone) {
            NSTimeInterval duration = [sender.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGRect toolBarRect = self.toolBar.frame;
            toolBarRect.origin.y = self.theSuperView.bounds.size.height;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:self userInfo:dic];
            [UIView animateWithDuration:duration animations:^{
                self.toolBar.frame = toolBarRect;
            }];
        }
        
        //显示键盘
        if (self.status == FaceToolBarStatusText) {
            /*
             当语音图片等键盘与文字键盘切换时，会多次调用本方法从而调用多次动画效果，造成toolbar上下乱窜，因此加入下面
             的判断，只有当键盘最终弹出高度大于200时，才触发动画和通知
             */
            if (self.theSuperView.bounds.size.height - toRect.origin.y < 200) {
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:self userInfo:dic];
            CGRect toolBarRect = self.toolBar.frame;
            toolBarRect.origin.y = toRect.origin.y;
            
            NSTimeInterval duration = [sender.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            [UIView animateWithDuration:duration animations:^{
                self.toolBar.frame = toolBarRect;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self updateButtonImage];
                }
            }];
            
            CGRect backViewRect = self.backView.frame;
            if (CGRectIntersectsRect(self.theSuperView.bounds, backViewRect)) {
                backViewRect.origin.y = self.theSuperView.bounds.size.height;
                [UIView animateWithDuration:duration animations:^{
                    self.backView.frame = backViewRect;
                }];
            }
        }
    }
}

- (void)didTouchInView:(id)sender {
    [self dismissKeyBoard];
}

#pragma mark -
#pragma mark UIExpandingTextView delegate


//改变键盘高度
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.toolBar.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.toolBar.frame = r;
    if (expandingTextView.text.length>2&&[_emotions containsObject:[expandingTextView.text substringFromIndex:expandingTextView.text.length-2]]) {
        self.textView.internalTextView.contentOffset=CGPointMake(0,self.textView.internalTextView.contentSize.height-self.textView.internalTextView.frame.size.height );
    }
    NSValue* value = [NSValue valueWithCGRect:r];
    [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:nil userInfo:@{UIKeyboardFrameEndUserInfoKey:value}];

}

//return方法
- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView
{
    [self sendAction:nil];
    return YES;
}


- (void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView {
    self.placeHolderLabel.hidden = expandingTextView.text.length != 0;
    return;
}

#pragma mark -
#pragma mark ActionMethods  发送sendAction   显示表情 disFaceKeyboard
-(void)sendAction:(id)sender
{
    if (self.textView.text.length > 600) {
        [[UIApplication sharedApplication].keyWindow showHudWithText:@"您发送的文字字数不能超过600字" indicator:NO];
        [[UIApplication sharedApplication].keyWindow hideHudAfterDelay:1.0];
        return;
    }
    if (self.textView.text.length>0)
	{
        if ([self.faceBarDelegate respondsToSelector:@selector(sendTextAction:)])
        {
			NSString* text = [[HHEmotionManager sharedManager] replaceFaceValueWithKey:self.textView.text];
            [self.faceBarDelegate sendTextAction:text];
        }
            [self.textView clearText];
    }
}

-(void)faceKeyboard:(id)sender
{
    if (self.status != FaceToolBarStatusFace) {
        self.status = FaceToolBarStatusFace;
        [self.textView resignFirstResponder];
        [self showKeyboardView:self.faceView];
    } else {
        self.status = FaceToolBarStatusText;
        [self.textView becomeFirstResponder];
    }
    [self updateButtonImage];
}

- (void)voiceBtnAction:(id)sender
{
    if (self.status != FaceToolBarStatusVoice) {
        self.status = FaceToolBarStatusVoice;
        [self.textView resignFirstResponder];
//        [self showKeyboardView:self.voiceView];
    } else {
        self.status = FaceToolBarStatusText;
        [self.textView becomeFirstResponder];
    }
    [self updateButtonImage];
}

- (void)utilityBtnAction:(id)sender {
    if (self.status != FaceToolBarStatusUtility) {
        self.status = FaceToolBarStatusUtility;
        [self.textView resignFirstResponder];
    } else {
        self.status = FaceToolBarStatusText;
        [self.textView becomeFirstResponder];
    }
    [self updateButtonImage];
}

- (void)showKeyboardView:(UIView*)view {
    [view.superview bringSubviewToFront:view];
    
    if (!CGRectIntersectsRect(self.theSuperView.bounds, self.backView.frame)) {
        CGRect backViewRect = self.backView.frame;
        backViewRect.origin.y = self.theSuperView.bounds.size.height - keyboardHeight;
        
        CGRect toolbarRect = self.toolBar.frame;
        toolbarRect.origin.y = backViewRect.origin.y - self.toolBar.frame.size.height;
        
        NSValue* value = [NSValue valueWithCGRect:toolbarRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:nil userInfo:@{UIKeyboardFrameEndUserInfoKey:value}];
        [UIView animateWithDuration:0.3 animations:^{
            self.toolBar.frame = toolbarRect;
            self.backView.frame = backViewRect;
        } completion:^(BOOL finished) {
            if (finished) {
            }
        }];
    } else {
        CGRect toolbarRect = self.toolBar.frame;
        toolbarRect.origin.y = self.theSuperView.bounds.size.height - keyboardHeight - self.toolBar.frame.size.height;
        
        NSValue* value = [NSValue valueWithCGRect:toolbarRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:nil userInfo:@{UIKeyboardFrameEndUserInfoKey:value}];
        [UIView animateWithDuration:0.3 animations:^{
            self.toolBar.frame = toolbarRect;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark 隐藏键盘
-(void)dismissKeyBoard
{
    if (self.status == FaceToolBarStatusText) {
        self.status = FaceToolBarStatusNone;
        [self.textView.internalTextView resignFirstResponder];
    } else if (self.status != FaceToolBarStatusNone) {
        self.status = FaceToolBarStatusNone;
        [self updateButtonImage];
        CGRect toolbarRect = self.toolBar.frame;
        toolbarRect.origin.y = self.theSuperView.bounds.size.height;
        
        CGRect backViewRect = self.backView.frame;
        backViewRect.origin.y = CGRectGetMaxY(toolbarRect);
        
        NSValue* value = [NSValue valueWithCGRect:toolbarRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:HHToolbarFrameWillChange object:self userInfo:@{UIKeyboardFrameEndUserInfoKey: value}];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.toolBar.frame = toolbarRect;
            self.backView.frame = backViewRect;
        } completion:^(BOOL finished) {
            if (finished) {
            }
        }];
    }
}

- (void)updateButtonImage {

    //表情按钮
    [self.faceButton setImage:[UIImage imageNamed:@"chatface"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatface_down"] forState:UIControlStateHighlighted];

    //语音按钮
    [self.voiceBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [self.voiceBtn setImage:[UIImage imageNamed:@"voice_down"] forState:UIControlStateHighlighted];
    
    [self.picButton setImage:[UIImage imageNamed:@"chatpic"] forState:UIControlStateNormal];
    [self.picButton setImage:[UIImage imageNamed:@"chatpic_down"] forState:UIControlStateHighlighted];
    
    if (self.status == FaceToolBarStatusFace) {
        [self.faceButton setImage:[UIImage imageNamed:@"chatkey"] forState:UIControlStateNormal];
        [self.faceButton setImage:[UIImage imageNamed:@"chatkey_down"] forState:UIControlStateHighlighted];
    }
    if (self.status == FaceToolBarStatusVoice) {
        [self.voiceBtn setImage:[UIImage imageNamed:@"chatkey"] forState:UIControlStateNormal];
        [self.voiceBtn setImage:[UIImage imageNamed:@"chatkey_down"] forState:UIControlStateHighlighted];
    }
    if (self.status == FaceToolBarStatusUtility) {
        [self.picButton setImage:[UIImage imageNamed:@"chatkey"] forState:UIControlStateNormal];
        [self.picButton setImage:[UIImage imageNamed:@"chatkey_down"] forState:UIControlStateHighlighted];
    }
}

#pragma mark -
#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    NSString *newStr;
    if ([str isEqualToString:kDeleteKey]) {
        if (self.textView.text.length>0) {
			NSRange r = [self.textView.text rangeOfString:BEGIN_FLAG options:NSBackwardsSearch];
			if (r.location != NSNotFound) {
				NSString* emotion = [self.textView.text substringFromIndex:r.location];
				if ([emotion hasSuffix:END_FLAG]) {
					emotion = [emotion substringWithRange:NSMakeRange(2, emotion.length - 3)];
					emotion = [[HHEmotionManager sharedManager] faceKeyForFaceValue:emotion];
					if ([_emotions containsObject:emotion]) {
						newStr = [self.textView.text substringToIndex:r.location];
					}else{
						newStr=[self.textView.text substringToIndex:self.textView.text.length - 1];
					}
					self.textView.text=newStr;
				}
			}
        }
    }else{
		if ([str hasPrefix:@"bface"]) {
//			[self.faceBarDelegate sendDefineFace:str];
		} else {
			str = [HHEmotionManager sharedManager].emotions[str];
			NSString *newStr = [NSString stringWithFormat:@"%@%@%@%@",self.textView.text,BEGIN_FLAG,str,END_FLAG];
			[self.textView setText:newStr];
		}
    }
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [self.textView becomeFirstResponder];
    return YES;
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	[self dismissKeyBoard];
	[self.textView resignFirstResponder];
	return YES;
}

- (void)dealloc {
    self.status = FaceToolBarStatusNone;
    [[UIApplication sharedApplication].keyWindow hideHud];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end




