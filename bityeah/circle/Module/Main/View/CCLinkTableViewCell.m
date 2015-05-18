//
//  CCLinkTableViewCell.m
//  HChat
//
//  Created by Wong on 15/1/29.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCLinkTableViewCell.h"
#import "UIColor+FlatUI.h"
#import "UIImageView+WebCache.h"
#import "CCUtils.h"
#import "Circle.pb.h"
#import "CCUserDetailTimeView.h"
#import "NSString+URLEncode.h"

@interface CCLinkTableViewCell () <HHRoundImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UILabel *linkTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) CCUserDetailTimeView *detailTimeView;
@property (strong, nonatomic) CCFeedModel *feedModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutNameButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBaseTopHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBaseX;
@end


@implementation CCLinkTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userImgeView.frame = CGRectMake(10,10,40, 40);
    self.userImgeView.layer.masksToBounds = YES;
    self.userImgeView.layer.cornerRadius = CGRectGetHeight(self.userImgeView.frame)/2;
    self.userImgeView.delegate = self;
    
    UITapGestureRecognizer *gesTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkBaseViewTap:)];
    [self.linkBaseView addGestureRecognizer:gesTap];
    
    [self initUI];
}

- (void)initUI
{
    [self addSubview:self.likeButton];
    [self addSubview:self.commentButton];
    [self.likeButton addSubview:self.likeIcon];
    [self addSubview:self.detailTimeView];
}

- (UIView *)detailTimeView
{
    if (!_detailTimeView) {
        _detailTimeView = [[[NSBundle mainBundle]loadNibNamed:@"CCUserDetailTimeView" owner:self options:nil]lastObject];
        _detailTimeView.frame = CGRectMake(0, CGRectGetMinY(self.linkBaseView.frame)-10, 100, 100);
        _detailTimeView.backgroundColor = [UIColor clearColor];
        _detailTimeView.hidden = YES;
    }
    return _detailTimeView;
}

- (void)didTapOnView:(HHRoundImageView *)view
{
    if (_linkDelegate && [_linkDelegate respondsToSelector:@selector(linkTap:)]) {
        [_linkDelegate linkTap:self];
    }
}
- (IBAction)tapAction:(id)sender
{
    if (_linkDelegate && [_linkDelegate respondsToSelector:@selector(linkTap:)]) {
        [_linkDelegate linkTap:self];
    }
}

- (void)linkBaseViewTap:(UITapGestureRecognizer *)tap
{
    if (_linkDelegate && [_linkDelegate respondsToSelector:@selector(linkBaseViewTap:)]) {
        [_linkDelegate linkBaseViewTap:self];
    }
}

- (UIButton *)likeButton
{
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"circle_like_border"];
        _likeButton.frame = CGRectMake(CGRectGetMaxX(self.commentButton.frame) + 20, CGRectGetMinY(self.commentButton.frame), image.size.width, image.size.height);
        [_likeButton setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"ci"] forState:UIControlStateNormal];
        [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
        [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        [_likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton *)commentButton
{
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"circle_like_border"];
        _commentButton.frame = CGRectMake(CGRectGetMinX(self.userNameButton.frame), CGRectGetMaxY(self.userNameButton.frame) + 75 , image.size.width, image.size.height);
        [self.commentButton setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)] forState:UIControlStateNormal];
        [self.commentButton setImage:[UIImage imageNamed:@"circle_comment"] forState:UIControlStateNormal];
        [_commentButton setTitle:@"评" forState:UIControlStateNormal];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}

- (UIImageView *)likeIcon
{
    if (!_likeIcon) {
        UIImage *image = [UIImage imageNamed:@"circle_like"];
        _likeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, image.size.width, image.size.height)];
        _likeIcon.image = image;
    }
    return _likeIcon;
}

- (void)likeAction:(UIButton *)sender
{
    UIImage* targetImage = self.model.commentCountModel.likedId > 0 ? [UIImage imageNamed:@"circle_like"] : [UIImage imageNamed:@"circle_liked"];
    [UIView animateWithDuration:0.3 animations:^{
        self.likeIcon.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        self.likeIcon.image = targetImage;
        [UIView animateWithDuration:0.3 animations:^{
            self.likeIcon.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
    [self.delegate cellDidLike:self];
}

- (void)commentAction:(UIButton *)sender
{
    [self.delegate cellDidComment:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static float buttonWidth = 200.0f;
    self.shareLabel.frame = CGRectMake(CGRectGetMinX(self.userNameButton.frame),CGRectGetMaxY(self.userNameButton.frame) - 5 , buttonWidth, 20);
}

- (void)setModel:(CCFeedModel *)model
{
    _model = model;
    self.feedModel = model;
    [self.userNameButton setTitle:model.systemSender.name forState:UIControlStateNormal];
    if (model.type == PBWaveTypeTypeLink) {
        self.shareLabel.text = @"分享了一个链接";
        if (model.senderId > 0) {
            [self.userNameButton setTitle:[[CCUserInfoProvider sharedProvider] findNameForUid:model.senderId]  forState:UIControlStateNormal];
        }
    }else if (model.type == PBWaveTypeTypeNews) {
        self.shareLabel.text = @"发布了一个新闻";
    }else if (model.type == PBWaveTypeTypeNotice){
        self.shareLabel.text = @"发布了一个公告";
    } else if (model.type == PBWaveTypeTypeActivity){
        self.shareLabel.text = @"发布了一个约吗";
        if (model.senderId > 0) {
            [self.userNameButton setTitle:[[CCUserInfoProvider sharedProvider] findNameForUid:model.senderId]  forState:UIControlStateNormal];
        }
    }
    if (model.type != PBWaveTypeTypeRedPacket) {
        NSString* senderAvatarUrl = nil;
        if (model.senderId > 0) {
            senderAvatarUrl = [[CCUserInfoProvider sharedProvider] avatarForUid:model.senderId];
        } else if (model.systemSender.name.length > 0){
           senderAvatarUrl = model.systemSender.avatarUrl;
        }
        [self.userImgeView setImageWithURL:[NSURL URLWithString:[senderAvatarUrl encodedString]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        [self.linkImageView setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"bj_link_default"]];
        self.linkTitleLabel.text = model.title;
    }else{
        PBRedPacket *packet = model.redPacket;
        self.linkImageView.image = [UIImage imageNamed:@"redPacketLogo"];
        self.linkTitleLabel.text = packet.title;
    }
    NSString *titleName = self.userNameButton.titleLabel.text;
    self.sendName = titleName;
    CGSize size = [titleName sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(200, MAXFLOAT)];
    self.layoutNameButtonWidth.constant = ceil(size.width);

    self.timeLabel.text = [CCUtils timeStringFromTimeStamp:model.createAt];
    self.likeIcon.image = model.commentCountModel.likedId > 0 ? [UIImage imageNamed:@"circle_liked"] : [UIImage imageNamed:@"circle_like"];
    NSString *like = nil;
    if (model.commentCountModel.likeCount == 0) {
        like = @"赞";
    } else {
        like = [NSString stringWithFormat:@"%@", @(model.commentCountModel.likeCount)];
    }
    NSString *comment = nil;
    if (model.commentCountModel.commentCount == 0) {
        comment = @"评";
    } else {
        comment = [NSString stringWithFormat:@"%@", @(model.commentCountModel.commentCount)];
    }
    
    [self.likeButton setTitle:like forState:UIControlStateNormal];
    [self.commentButton setTitle:comment forState:UIControlStateNormal];
}

- (void)setIsFromFeed:(BOOL)isFromFeed
{
    _isFromFeed = isFromFeed;
    if (isFromFeed) {
        self.userNameButton.hidden = isFromFeed;
        self.shareLabel.hidden = isFromFeed;
        self.commentButton.hidden = isFromFeed;
        self.likeButton.hidden = isFromFeed;
        self.timeLabel.hidden = isFromFeed;
        self.likeIcon.hidden = isFromFeed;
        self.userImgeView.hidden = isFromFeed;
        
        self.linkBaseView.hidden = !isFromFeed;;
        self.linkImageView.hidden = !isFromFeed;
        self.linkTitleLabel.hidden = !isFromFeed;
        
        CGRect rect = self.linkBaseView.frame;
        rect.origin.y = 10.0f;
        rect.origin.x = 70.0f;
        rect.size.width = 240.0f;
        self.layoutBaseTopHeight.constant = 10.0f;
        self.layoutBaseX.constant = 90.0f;
        self.linkBaseView.frame = rect;
        self.detailTimeView.frame = CGRectMake(0, 0, 100, 100);
    }
}

- (void)setIsFromDetail:(BOOL)isFromDetail
{
    _isFromDetail = isFromDetail;
    if (isFromDetail) {
        CGRect rect = self.commentButton.frame;
        rect.origin.x = 10.0f;
        self.commentButton.frame = rect;
        rect = self.likeButton.frame;
        rect.origin.x = 86.0f;
        self.likeButton.frame = rect;
    }
}


- (void)showRelativeDay:(NSString *)day {
    self.detailTimeView.relativeDayLabel.hidden = NO;
    self.detailTimeView.relativeDayLabel.text = day;
}

- (void)showYear:(NSString *)year month:(NSString *)month day:(NSString *)day {
    self.detailTimeView.yearLabel.hidden = year == nil;
    self.detailTimeView.monthLabel.hidden = NO;
    self.detailTimeView.dayLabel.hidden = NO;
    self.detailTimeView.yearLabel.text = year;
    self.detailTimeView.monthLabel.text = month;
    self.detailTimeView.dayLabel.text = day;
}

- (void)hideDateViews {
    self.detailTimeView.hidden = NO;
    self.detailTimeView.yearLabel.hidden = YES;
    self.detailTimeView.monthLabel.hidden = YES;
    self.detailTimeView.dayLabel.hidden = YES;
    self.detailTimeView.relativeDayLabel.hidden = YES;
}

+ (CGFloat)heightForModel:(CCFeedModel *)model {
    if (model.pictures.count == 0) {
        return 72;
    }
    return 105;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
