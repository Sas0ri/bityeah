//
//  CCUserFeedsCellTableViewCell.m
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCUserFeedsCell.h"
#import "CCFeedImageCell.h"
#import "UIImageView+WebCache.h"
#import "CCURLDefine.h"
#import "CCFeedPicture.h"
#import "UIColor+FlatUI.h"

@interface CCUserFeedsCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView0;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@end

@implementation CCUserFeedsCell

static NSInteger kMaxDisplayImageCount = 4;

- (void)awakeFromNib {
    self.textView.maxHeight = 58;
    self.textView.textColor = [UIColor colorFromHexCode:@"333333"];
    self.textView.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(CCFeedModel *)model {
    _model = model;
    
    self.textView.text = model.content;
    self.imageCountLabel.text = [NSString stringWithFormat:@"共%@张", @(model.pictures.count)];
    self.imageCountLabel.hidden = model.pictures.count <= kMaxDisplayImageCount;
    NSInteger count = model.pictures.count > kMaxDisplayImageCount ? kMaxDisplayImageCount:model.pictures.count;
    for (int i = 0; i < count; i++) {
        UIImageView* imageView = (UIImageView*)[self viewWithTag:100+i];
        CCFeedPicture* fp = model.pictures[i];
        [imageView setImageWithURL:[NSURL URLWithString:[CCURLDefine thumbnailPath:fp.relativeURLString]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.textView.frame;
    if (self.model.pictures.count == 0) {
        r.origin.x = 90;
        r.size.width = self.bounds.size.width - 98;
    } else {
        r.size.width = self.bounds.size.width - 186;
        r.origin.x = 178;
    }
    self.textView.frame = r;
    
    [self layOutImageViews];
}

- (void)layOutImageViews {
    switch (self.model.pictures.count) {
        case 0:
            self.imageView0.frame = self.imageView1.frame = self.imageView2.frame = self.imageView3.frame = CGRectZero;
            break;
        case 1:
            self.imageView0.frame = CGRectMake(0, 0, 80, 80);
            self.imageView1.frame = self.imageView2.frame = self.imageView3.frame = CGRectZero;
            break;
        case 2:
            self.imageView0.frame = CGRectMake(0, 0, 39, 80);
            self.imageView1.frame = CGRectMake(41, 0, 39, 80);
            self.imageView2.frame = self.imageView3.frame = CGRectZero;
            break;
        case 3:
            self.imageView0.frame = CGRectMake(0, 0, 39, 80);
            self.imageView1.frame = CGRectMake(41, 0, 39, 39);
            self.imageView2.frame = CGRectMake(41, 41, 39, 39);
            self.imageView3.frame = CGRectZero;
            break;
        default:
            self.imageView0.frame = CGRectMake(0, 0, 39, 39);
            self.imageView1.frame = CGRectMake(41, 0, 39, 39);
            self.imageView2.frame = CGRectMake(0, 41, 39, 39);
            self.imageView3.frame = CGRectMake(41, 41, 39, 39);
            break;
    }
}

- (void)showRelativeDay:(NSString *)day {
    self.relativeDayLabel.hidden = NO;
    self.relativeDayLabel.text = day;
}

- (void)showYear:(NSString *)year month:(NSString *)month day:(NSString *)day {
    self.yearLabel.hidden = year == nil;
    self.monthLabel.hidden = NO;
    self.dayLabel.hidden = NO;
    self.yearLabel.text = year;
    self.monthLabel.text = month;
    self.dayLabel.text = day;
}

- (void)hideDateViews {
    self.yearLabel.hidden = YES;
    self.monthLabel.hidden = YES;
    self.dayLabel.hidden = YES;
    self.relativeDayLabel.hidden = YES;
}

+ (CGFloat)heightForModel:(CCFeedModel *)model {
    if (model.pictures.count == 0) {
        return 72;
    }
    return 105;
}

@end
