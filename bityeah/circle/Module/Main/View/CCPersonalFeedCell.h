//
//  CCFeedCell.h
//  testCircle
//
//  Created by Sasori on 14/11/27.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFeedCell.h"
#import "TQRichTextView.h"
#import "CCFeedCellDelegate.h"
#import "CCUserInfoProvider.h"
#import "HHRoundImageView.h"

@interface CCPersonalFeedCell: CCFeedCell
@property (weak, nonatomic) IBOutlet HHRoundImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TQRichTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;
@property (weak, nonatomic) id<CCFeedCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet TQRichTextView *nameView;
@property (weak, nonatomic) IBOutlet UIImageView *likeIcon;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) id<CCUserInfoProviderDelegate> userInfoProvider;
@property (assign, nonatomic) CGRect tipFrame;
@property (strong, nonatomic) UIImage *pressImage;
//- (IBAction)likeAction:(id)sender;

+ (CGFloat)heightForModel:(CCFeedModel*)model forWidth:(CGFloat)width;

@end
