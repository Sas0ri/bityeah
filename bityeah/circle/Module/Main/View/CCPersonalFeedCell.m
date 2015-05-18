//
//  CCFeedCell.m
//  testCircle
//
//  Created by Sasori on 14/11/27.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCPersonalFeedCell.h"
#import "CCFeedImageCell.h"
#import "CCFeedImagesLayout.h"
#import "CCFeedModel.h"
#import "CCURLDefine.h"
#import "UIImageView+WebCache.h"
#import "CCFeedPicture.h"
#import "CCUtils.h"
#import "TQRichTextURLRun.h"
#import "TQRichTextUserNameRun.h"
#import "Circle.pb.h"
#import "Context.h"
#import "NSString+URLEncode.h"
#import "CCTransModel.h"

@interface CCPersonalFeedCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TQRichTextViewDelegate, HHRoundImageViewDelegate,CCFeedImageCellDelegate>
@property (nonatomic, assign) CGFloat rightMargin;
@property (weak, nonatomic) IBOutlet UIImageView *commentIcon;
@property (weak, nonatomic) IBOutlet UIView *commentContainer;
@property (weak, nonatomic) IBOutlet UIView *likeContainer;
@end

@implementation CCPersonalFeedCell
@synthesize model=_model;

static const CGFloat kMaxPictureLandscapeWidth = 160.0f;
static const CGFloat kMaxPictureLandscapeHeight = 100.0f;
static const CGFloat kMaxPicturePortraitWidth = 100.0f;
static const CGFloat kMaxPicturePortraitHeight = 160.0f;
static const CGFloat kSinglePicutreWidth = 72.0f;
static const CGFloat kItemSpacing = 4.0f;

- (void)awakeFromNib {
    self.avatarImageView.delegate = self;
    self.nameView.font = [UIFont boldSystemFontOfSize:16];
    self.contentTextView.font = [UIFont systemFontOfSize:15];
    self.contentTextView.delegate = self;
    self.nameView.delegate = self;
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
    self.contentTextView.text = model.content;

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
    
    r = self.contentTextView.frame;
    r.size.width = self.bounds.size.width - 73;
    self.contentTextView.frame = r;
    
    r = self.nameView.frame;
    r.size.width = self.bounds.size.width - 108;
    self.nameView.frame = r;
    
    [self.contentTextView sizeToFit];

    [self.imagesView reloadData];

    r = self.imagesView.frame;
    r.origin.y = CGRectGetMaxY(self.contentTextView.frame) + 9;
    r.size = [CCPersonalFeedCell collectionView:self.imagesView sizeForModel:self.model];
    self.imagesView.frame = r;

    
    r = self.bottomContainerView.frame;
    r.size.width = self.bounds.size.width - self.bottomContainerView.frame.origin.x - self.rightMargin + 9;
    r.origin.y = CGRectGetMaxY(self.imagesView.frame)+1;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _model.pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCFeedImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Image" forIndexPath:indexPath];
    CCFeedPicture* fp = _model.pictures[indexPath.row];
    NSURL* url = [NSURL URLWithString:[CCURLDefine thumbnailPath:fp.relativeURLString]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _tipFrame = [self.imagesView convertRect:cell.frame toView:self];
    cell.imageView.tag = indexPath.row;
    cell.isLongPress = YES;
    cell.delegate = self;
    return cell;
}

- (void)longPressImage:(NSInteger)index imageRect:(CGRect)imageRect image:(UIImage *)image
{
    self.pressImage = image;
    CGRect rect = self.imagesView.frame;
    rect.origin.x = imageRect.size.width * (index%3);
    rect.origin.y = imageRect.size.height * (index/3);
    rect.size.width = imageRect.size.width;
    rect.size.height = imageRect.size.height;
    _tipFrame = [self.imagesView convertRect:rect toView:self];
    [self.delegate cell:self longPressImageAtIndex:index];

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self.delegate cell:self didSelectImageAtIndex:indexPath.row];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result;
    switch (_model.pictures.count) {
        case 0:
            result = CGSizeZero;
            break;
        case 1:
        {
            CCFeedPicture* fp = _model.pictures[0];
            result = [CCPersonalFeedCell sizeForPictureSize:fp.size];
        }
            break;
        default:
            result = CGSizeMake(kSinglePicutreWidth, kSinglePicutreWidth);
            break;
    }
    return result;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (CGSize)sizeForPictureSize:(CGSize)pictureSize {
    CGSize result;
    if (pictureSize.width > pictureSize.height) {
        if (pictureSize.width <= kMaxPictureLandscapeWidth) {
            result = CGSizeMake(pictureSize.width, pictureSize.height);
        } else {
            result = CGSizeMake(kMaxPictureLandscapeWidth, kMaxPictureLandscapeHeight);
        }
    } else {
        if (pictureSize.height <= kMaxPicturePortraitHeight) {
            result = CGSizeMake(pictureSize.width, pictureSize.height);
        } else {
            result = CGSizeMake(kMaxPicturePortraitWidth, kMaxPicturePortraitHeight);
        }
    }
    if (CGSizeEqualToSize(result, CGSizeZero)) {
        result = CGSizeMake(100, 100);
    }
    return result;
}

+ (CGSize)collectionView:(UICollectionView*)collectionView sizeForModel:(CCFeedModel *)model {
    CGFloat width = 0;
    CGFloat height = 0;
    if (model.pictures.count > 2 && model.pictures.count != 4) {
        width = kSinglePicutreWidth*3 + 2*kItemSpacing;
    } else if (model.pictures.count == 4 || model.pictures.count == 2) {
        width = kSinglePicutreWidth*2 + kItemSpacing;
    } else {
        width = model.pictures.count*kSinglePicutreWidth;
    }
    if (model.pictures.count == 1) {
        CCFeedPicture* fp = model.pictures[0];
        CGSize size = [self sizeForPictureSize:fp.size];
        height += size.height;
        width = size.width;
    } else {
        int spare = model.pictures.count%3;
        int lines = spare%3 > 0 ? 1 : 0;
        lines += model.pictures.count/3;
        if (lines > 1) {
            height += (lines - 1)*kItemSpacing;
        }
        height += lines * kSinglePicutreWidth;
    }
    return CGSizeMake(width, height);
}

+ (CGFloat)heightForModel:(CCFeedModel *)model forWidth:(CGFloat)width {
    CGFloat height = 0;
    height += 46;
    
    TQRichTextView* view = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 0, width - 73, 0)];
    view.font = [UIFont systemFontOfSize:15];
    view.text = model.content;
    [view sizeToFit];
    
    height += view.bounds.size.height;
    
    height += [self collectionView:nil sizeForModel:model].height;
    
    height += 36;
    
    return height;
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

- (void)richTextView:(TQRichTextView *)view longPress:(id)sender
{
    [CCTransModel share].content = view.text;
    [self.delegate cell:self longPressTextView:view];
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
