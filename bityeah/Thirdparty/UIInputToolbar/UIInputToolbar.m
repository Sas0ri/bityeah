/*
 *  UIInputToolbar.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "UIInputToolbar.h"

@interface UIInputToolbar()

@property (nonatomic, strong)NSArray* inputButtonItems;

@end

@implementation UIInputToolbar

- (void)setInputButtonIsHidden:(BOOL)inputButtonIsHidden
{
    _inputButtonIsHidden = inputButtonIsHidden;
    if (inputButtonIsHidden) {
        [self setItems:nil];
        CGRect frame = self.textView.frame;
        frame.size.width = 320 - 14;
        self.textView.frame = frame;
        self.textView.internalTextView.returnKeyType = UIReturnKeySend;
    }
    else
    {
        CGRect frame = self.textView.frame;
        frame.size.width = 236;
        self.textView.frame = frame;
        [self setItems:self.inputButtonItems animated:YES];
        self.textView.internalTextView.returnKeyType = UIReturnKeyDefault;
    }
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIEdgeInsets insets = UIEdgeInsetsMake(40, 0, 40, 0);
        [self setBackgroundImage:[[UIImage imageNamed:@"chat_bg.png"] resizableImageWithCapInsets:insets] forToolbarPosition:0 barMetrics:0];
        [self setBarStyle:UIBarStyleBlack];
        
        self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(5, self.frame.size.height/2 - 13.5, CGRectGetWidth(self.frame) - 60, 27)];
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
        [self.textView.internalTextView setReturnKeyType:UIReturnKeySend];
        self.textView.delegate = self;
        self.textView.maximumNumberOfLines = 5;
        [self addSubview:self.textView];
        
        self.inputButton = [[UIButton alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x + self.textView.frame.size.width + 4, self.frame.size.height/2 - 13.5, 47, 27)];
		self.inputButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
		[self.inputButton setImage:[UIImage imageNamed:@"sendbutton.png"] forState:UIControlStateNormal];
		[self.inputButton setImage:[UIImage imageNamed:@"sendbutton_down.png"] forState:UIControlStateHighlighted];
        
        self.inputButtonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 47, 13)];
		self.inputButtonTitleLabel.text = @"取消";
		self.inputButtonTitleLabel.textColor = [UIColor whiteColor];
		self.inputButtonTitleLabel.textAlignment = NSTextAlignmentCenter;
		self.inputButtonTitleLabel.font = [UIFont systemFontOfSize:13];
		self.inputButtonTitleLabel.backgroundColor = [UIColor clearColor];
		[self.inputButton addSubview:self.inputButtonTitleLabel];
        [self.inputButton addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.inputButton];

    }
    return self;
}

#pragma mark -
#pragma mark UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.frame = r;
    if (self.inputToolbarDelegate && [self.inputToolbarDelegate respondsToSelector:@selector(inputToolbar: willChangeHeight:)]) {
        [self.inputToolbarDelegate inputToolbar:self willChangeHeight:r.size.height];
    }
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([expandingTextView.text length] > 0)
        self.inputButtonTitleLabel.text = @"发送";
    else
        self.inputButtonTitleLabel.text = @"取消";
}

- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView
{
    [self inputButtonPressed];
    return YES;
}

- (void)inputButtonPressed
{
    if (self.inputToolbarDelegate && [self.inputToolbarDelegate respondsToSelector:@selector(inputButtonPressed:)])
    {
        [self.inputToolbarDelegate inputButtonPressed:self.textView.text];
    }
    
    [self.textView clearText];
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [self.textView resignFirstResponder];
}

@end
