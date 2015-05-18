//
//  CCDetailLikeCell.h
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "CCFeedCellDelegate.h"

@interface CCDetailLikeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *likeIcon;
@property (weak, nonatomic) IBOutlet TQRichTextView *likePeopleView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) id<CCFeedCellDelegate> delegate;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, strong) CCFeedModel* model;
+ (CGFloat)heightForString:(NSString*)text forWidth:(CGFloat)width expanded:(BOOL)expanded;
- (void)showSepLine:(BOOL)show;
@end
