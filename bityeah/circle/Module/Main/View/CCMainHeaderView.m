//
//  CCMainHeaderView.m
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMainHeaderView.h"
#import "UIColor+FlatUI.h"

@interface CCMainHeaderView() <HHRoundImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *unreadBgView;
@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, assign) CGFloat expandHeight;

@property (strong, nonatomic) UIButton *redPacketButton;
@property (strong, nonatomic) UIButton *dateButton;

@property (strong, nonatomic) CABasicAnimation *pulse;

@end

static CGFloat width = 49.0f;

@implementation CCMainHeaderView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)awakeFromNib {
    self.avatarView.delegate = self;
    self.unreadButton.hidden = YES;
    self.unreadBgView.hidden = YES;
    self.unreadBgView.image = [[UIImage imageNamed:@"circle_unread_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self addSubview:self.redPacketButton];
    [self addSubview:self.dateButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.avatarView.frame;
    r.origin.x = self.bounds.size.width - 14 - self.avatarView.frame.size.width;
    r.origin.y = self.bounds.size.height - 85;
    self.avatarView.frame = r;
    
    r = self.nameLabel.frame;
    r.origin.x = self.bounds.size.width - 275;
    r.origin.y = self.bounds.size.height - 73;
    self.nameLabel.frame = r;
    
    r = self.unreadButton.frame;
    r.origin.y = self.bounds.size.height - 30;
    self.unreadButton.frame = r;
    self.unreadBgView.frame = r;
    
    [self resizeImageView];
    
    r = self.redPacketButton.frame;
    r.origin.x = self.bounds.size.width - 130.0f;
    r.origin.y = self.bounds.size.height - 126;
    self.redPacketButton.frame = r;
    
    r = self.dateButton.frame;
    r.origin.x = self.bounds.size.width - 70.0f;
    r.origin.y = self.bounds.size.height - 150;
    self.dateButton.frame = r;
}

- (void)expandWithScrollView:(UIScrollView*)scrollView {
    
    _expandHeight = CGRectGetHeight(self.frame);
    
    _scrollView = scrollView;
    _scrollView.contentInset = UIEdgeInsetsMake(_expandHeight, 0, 0, 0);
    CGRect r = self.frame;
    r.origin.y = -_expandHeight;
    self.frame = r;
    [_scrollView addSubview:self];
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView setContentOffset:CGPointMake(0, - _expandHeight)];
    
    self.backgroundImageView.clipsToBounds = YES;
    self.clipsToBounds = YES;
    [self resizeImageView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    [self scrollViewDidScroll:_scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY < _expandHeight * -1) {
        CGRect currentFrame = self.frame;
        currentFrame.origin.y = offsetY ;
        currentFrame.size.height = -1*offsetY;
        self.frame = currentFrame;
    }
}

- (void)resizeImageView {
    CGRect r = self.backgroundImageView.frame;
    r.size.width = self.bounds.size.width;
    r.size.height = self.bounds.size.height - 40;
    self.backgroundImageView.frame = r;
}

- (void)detatchWithScrollView:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)didTapOnView:(HHRoundImageView *)view {
    [self.delegate headerView:self didTapOnAvatar:(HHAvatarImageView*)view];
}

- (IBAction)unreadButtonAction:(id)sender {
    [self.delegate headerView:self didTapOnUnread:sender];
}

- (void)setUnreadCount:(NSInteger)unreadCount {
    _unreadCount = unreadCount;
    self.unreadButton.hidden = unreadCount == 0;
    self.unreadBgView.hidden = self.unreadButton.hidden;
    [self.unreadButton setTitle:[NSString stringWithFormat:@"%@条新消息", @(unreadCount)] forState:UIControlStateNormal];
}

- (UIButton *)redPacketButton
{
//    if (!_redPacketButton) {
//        _redPacketButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _redPacketButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 130, CGRectGetHeight(self.frame) - 100, width, width);
//        _redPacketButton.layer.masksToBounds = YES;
//        _redPacketButton.layer.cornerRadius = width/2;
//        [_redPacketButton setImage:[UIImage imageNamed:@"circle_redPacket"] forState:UIControlStateNormal];
//        [_redPacketButton addTarget:self action:@selector(redPacketAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
    return _redPacketButton;
}

- (void)redPacketAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(headerView:didRedPacket:)]) {
        [_delegate headerView:self didRedPacket:sender];
    }
}

- (UIButton *)dateButton
{
    if (!_dateButton) {
//        _dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _dateButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 70, CGRectGetHeight(self.frame) - 130, width, width);
//        _dateButton.layer.masksToBounds = YES;
//        _dateButton.layer.cornerRadius = width/2;
//        [_dateButton setImage:[UIImage imageNamed:@"circle_date"] forState:UIControlStateNormal];
//        [_dateButton addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateButton;
}

- (void)dateAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(headerView:didDate:)]) {
        [_delegate headerView:self didDate:sender];
    }
}

- (void)setIsDetialFeeds:(BOOL)isDetialFeeds
{
    _isDetialFeeds = isDetialFeeds;
    if (isDetialFeeds) {
        self.dateButton.hidden = YES;
        self.redPacketButton.hidden = YES;
    }else{
        self.dateButton.hidden = NO;
        self.redPacketButton.hidden = NO;
    }
}

- (void)setIsHasNewDate:(BOOL)isHasNewDate
{
    _isHasNewDate = isHasNewDate;
    if (isHasNewDate) {
        [self.dateButton.imageView.layer addAnimation:self.pulse forKey:@"transform.scale"];
    }else{
        [self.dateButton.imageView.layer removeAllAnimations];
    }
}

- (CABasicAnimation *)pulse
{
    if (!_pulse) {
        _pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        _pulse.duration = 0.5;
        _pulse.repeatCount = FLT_MAX;
        _pulse.autoreverses = YES;
        _pulse.fromValue = [NSNumber numberWithFloat:0.8];
        _pulse.toValue = [NSNumber numberWithFloat:1.2];
    }
    return _pulse;
}

@end
