//
//  CCLinkTableViewCell.h
//  HChat
//
//  Created by Wong on 15/1/29.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHRoundImageView.h"
#import "CCUserInfoProvider.h"
#import "CCFeedModel.h"
#import "CCFeedCellDelegate.h"


@class CCLinkTableViewCell;

@protocol CCLinkCellDelegate <NSObject>

@optional

- (void)linkTap:(CCLinkTableViewCell *)cell;
- (void)linkBaseViewTap:(CCLinkTableViewCell *)cell;
@end

@interface CCLinkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HHRoundImageView *userImgeView;

@property (strong, nonatomic) CCFeedModel *model;
@property (strong, nonatomic) UIImageView *likeIcon;
@property (nonatomic, weak) id <CCUserInfoProviderDelegate> userInfoProvider;
@property (weak, nonatomic) id <CCFeedCellDelegate>delegate;
@property (assign, nonatomic) id <CCLinkCellDelegate>linkDelegate;
@property (assign, nonatomic) BOOL isFromFeed;
@property (assign, nonatomic) BOOL isFromDetail;
@property (weak, nonatomic) IBOutlet UIView *linkBaseView;
@property (strong, nonatomic)  UIButton *commentButton;
@property (strong, nonatomic)  UIButton *likeButton;
@property (strong, nonatomic) NSString *sendName;
- (void)hideDateViews ;
- (void)showRelativeDay:(NSString*)day;
- (void)showYear:(NSString*)year month:(NSString*)month day:(NSString*)day;
+ (CGFloat)heightForModel:(CCFeedModel*)model;

@end
