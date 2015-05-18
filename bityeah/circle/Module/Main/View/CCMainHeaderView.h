//
//  CCMainHeaderView.h
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHAvatarImageView.h"

@class CCMainHeaderView;

@protocol CCMainHeaderViewDelegate <NSObject>
@optional
- (void)headerView:(CCMainHeaderView*)headerView didTapOnAvatar:(HHAvatarImageView*)avataView;
- (void)headerView:(CCMainHeaderView*)headerView didTapOnUnread:(UIButton*)sender;

- (void)headerView:(CCMainHeaderView*)headerView didDate:(UIButton *)sender;
- (void)headerView:(CCMainHeaderView*)headerView didRedPacket:(UIButton *)sender;

@end

@interface CCMainHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *unreadButton;
@property (weak, nonatomic) IBOutlet HHAvatarImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) id<CCMainHeaderViewDelegate> delegate;
@property (nonatomic, assign) NSInteger unreadCount;

@property (assign, nonatomic) BOOL isDetialFeeds;

@property (assign, nonatomic) BOOL isHasNewDate;

- (void)expandWithScrollView:(UIScrollView*)scrollView;
- (void)detatchWithScrollView:(UIScrollView*)scrollView;
@end
