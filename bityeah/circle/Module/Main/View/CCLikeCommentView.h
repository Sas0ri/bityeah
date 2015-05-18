//
//  CCLikeCommentView.h
//  testCircle
//
//  Created by Sasori on 14/12/2.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCLikeCommentViewDelegate <NSObject>

- (void)likeAtIndex:(NSInteger)index;
- (void)unlikeAtIndex:(NSInteger)index;
- (void)commentActionAtIndex:(NSInteger)index;

@end

@interface CCLikeCommentView : UIView
- (IBAction)likeAction:(id)sender;
- (IBAction)commentAction:(id)sender;
@property (nonatomic, assign) BOOL hasLiked;
@property (nonatomic, assign) NSInteger index;
@property (weak, nonatomic) id<CCLikeCommentViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@end
