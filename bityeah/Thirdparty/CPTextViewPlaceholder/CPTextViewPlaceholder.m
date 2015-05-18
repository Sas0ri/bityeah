//
//  CPTextViewPlaceholder.m
//  Cassius Pacheco
//
//  Created by Cassius Pacheco on 30/01/13.
//  Copyright (c) 2013 Cassius Pacheco. All rights reserved.
//

#import "CPTextViewPlaceholder.h"

@interface CPTextViewPlaceholder()

@property (nonatomic, strong) UILabel* placeHolderLabel;

@end

@implementation CPTextViewPlaceholder

#pragma mark -
#pragma mark Life Cycle method

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    if (_placeholder.length > 0) {
        CGSize textSize = [placeholder sizeWithFont:self.font];
        if (_placeHolderLabel == nil) {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 8.0, textSize.width, textSize.height)];
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.0980392 alpha:0.22];
            [self addSubview:_placeHolderLabel];
        }
        self.placeHolderLabel.text = placeholder;
    }
    else
    {
        if (self.placeHolderLabel) {
            [self.placeHolderLabel removeFromSuperview];
            _placeHolderLabel = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeHolderLabel.frame = CGRectMake(4, 8.0, self.placeHolderLabel.frame.size.width, self.placeHolderLabel.frame.size.height);
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    if (self.placeHolderLabel) {
        self.placeHolderLabel.font = font;
        CGSize textSize = [self.placeholder sizeWithFont:self.font];
        CGRect frame = self.placeHolderLabel.frame;
        frame.size = textSize;
        self.placeHolderLabel.frame = frame;
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (void)textDidChange:(NSNotification *)notification
{
    //self.text received the placeholder text by CPTex tViewPlaceholder
    if (self.text.length == 0) {
        if (self.placeholder.length > 0) {
            self.placeHolderLabel.hidden = NO;
        }
        
    }
    else
    {
        self.placeHolderLabel.hidden = YES;
    }
    
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    if (text.length == 0) {
        if (self.placeholder.length > 0) {
            self.placeHolderLabel.hidden = NO;
        }
        
    }
    else
    {
        self.placeHolderLabel.hidden = YES;
    }
}


@end
