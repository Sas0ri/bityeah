//
//  CCFeedCell.m
//  testCircle
//
//  Created by Sasori on 14/11/27.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCNoTypeCell.h"
#import "CCFeedModel.h"
#import "CCUtils.h"
#import "TQRichTextURLRun.h"
#import "TQRichTextUserNameRun.h"
#import "Circle.pb.h"
#import "Context.h"
#import "NSString+URLEncode.h"

@interface CCNoTypeCell() <HHRoundImageViewDelegate>
@property (nonatomic, assign) CGFloat rightMargin;
@property (weak, nonatomic) IBOutlet UIImageView *commentIcon;
@property (weak, nonatomic) IBOutlet UIView *commentContainer;
@property (weak, nonatomic) IBOutlet UIView *likeContainer;
@end

@implementation CCNoTypeCell
@synthesize model=_model;

- (void)awakeFromNib {
    self.avatarImageView.delegate = self;
    self.nameView.font = [UIFont boldSystemFontOfSize:16];
   
    [self.likeButton setBackgroundImage:[[UIImage imageNamed:@"circle_like_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)] forState:UIControlStateNormal];
    [self.commentButton setBackgroundImage:[[UIImage imageNamed:@"circle_like_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:HHUserInfoUpdatedNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(CCFeedModel *)model {
    _model = model;
    
    NSString* senderName = nil;
    NSString* avatar = nil;

    if (model.senderId > 0) {
        NSString* name = [self.userInfoProvider findNameForUid:model.senderId];
        senderName = [NSString stringWithFormat:@"[-%lld-%@]", model.senderId, name];
        avatar = [self.userInfoProvider avatarForUid:model.senderId];

    } else if (model.senderName.length > 0) {
        senderName = model.senderName;
        avatar = model.systemSender.avatarUrl;
    }
  
    self.nameView.text = senderName;

    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[avatar encodedString]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    self.likeIcon.image = model.commentCountModel.likedId > 0 ? [UIImage imageNamed:@"circle_liked"] : [UIImage imageNamed:@"circle_like"];
    if (model.commentCountModel.likeCount == 0) {
        self.likeLabel.text = @"赞";
    } else {
        self.likeLabel.text = [NSString stringWithFormat:@"%@", @(model.commentCountModel.likeCount)];
    }
    if (model.commentCountModel.commentCount == 0) {
        self.commentLabel.text = @"评";
    } else {
        self.commentLabel.text = [NSString stringWithFormat:@"%@", @(model.commentCountModel.commentCount)];
    }
    self.timeLabel.text = [CCUtils timeStringFromTimeStamp:model.createAt];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect r = self.timeLabel.frame;
    r.origin.x = self.bounds.size.width - 80;
    self.timeLabel.frame = r;
        
    r = self.nameView.frame;
    r.size.width = self.bounds.size.width - 108;
    self.nameView.frame = r;
    
    r = self.wrapperView.frame;
    r.size.width = self.bounds.size.width - 20 - CGRectGetMinX(r);
    self.wrapperView.frame = r;
    
    r = self.bottomContainerView.frame;
    r.size.width = self.bounds.size.width - self.bottomContainerView.frame.origin.x - self.rightMargin + 9;
    r.origin.y = CGRectGetMaxY(self.wrapperView.frame)+1;
    self.bottomContainerView.frame = r;
    
    [self.likeLabel sizeToFit];
    [self.commentLabel sizeToFit];
    
    r = self.commentButton.frame;
    r.size.width = CGRectGetMaxX(self.commentLabel.frame) + 10;
    if (r.size.width < 56) {
        r.size.width = 56;
    }
    self.commentButton.frame = r;
    
    r = self.commentContainer.frame;
    r.size.width = CGRectGetMaxX(self.commentLabel.frame);
    self.commentContainer.frame = r;
    self.commentContainer.center = self.commentButton.center;
    
    r = self.likeButton.frame;
    r.origin.x = CGRectGetMaxX(self.commentButton.frame) + 20;
    r.size.width = CGRectGetMaxX(self.likeLabel.frame) + 10;
    if (r.size.width < 56) {
        r.size.width = 56;
    }
    self.likeButton.frame = r;
    
    r = self.likeContainer.frame;
    r.size.width = CGRectGetMaxX(self.likeLabel.frame);
    self.likeContainer.frame = r;
    self.likeContainer.center = self.likeButton.center;
    
}

+ (CGFloat)heightForModel:(CCFeedModel *)model forWidth:(CGFloat)width {
    return 130;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

//- (IBAction)likeAction:(id)sender {
//    [self.delegate likeCommentAction:sender onModel:self.model];
//}

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run {
    if ([run isKindOfClass:[TQRichTextUserNameRun class]]) {
        NSString* uidString = [[run.originalText componentsSeparatedByString:@"-"] objectAtIndex:1];
        [self.delegate cell:self didSelectUid:uidString.longLongValue];
    }
    if ([run isKindOfClass:[TQRichTextURLRun class]]) {
        [self.delegate cell:self didSelectURL:run.originalText];
    }
    if (run == nil) {
        [self.delegate cellDidSelect:self];
    }
}

- (void)didTapOnView:(HHRoundImageView *)view {
    [self.delegate cell:self didSelectUid:self.model.senderId];
}

- (IBAction)likeAction:(id)sender {
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

- (IBAction)commentAction:(id)sender {
    [self.delegate cellDidComment:self];
}

- (void)userInfoUpdated:(NSNotification*)sender {
    NSDictionary* dic = sender.userInfo;
    int64_t uid = [dic[@"uid"] longLongValue];
    if (uid == self.model.senderId) {
        NSString* senderName = nil;
        NSString* avatar = nil;
        
        NSString* name = [self.userInfoProvider findNameForUid:self.model.senderId];
        senderName = [NSString stringWithFormat:@"[-%lld-%@]", self.model.senderId, name];
        avatar = [self.userInfoProvider avatarForUid:self.model.senderId];
        self.nameView.text = senderName;
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
