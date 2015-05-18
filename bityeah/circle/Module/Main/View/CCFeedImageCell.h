//
//  CCFeedImageCell.h
//  testCircle
//
//  Created by Sasori on 14/11/27.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCFeedImageCellDelegate <NSObject>

- (void)longPressImage:(NSInteger)index imageRect:(CGRect)imageRect image:(UIImage *)image;

@end

@interface CCFeedImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) id <CCFeedImageCellDelegate> delegate;
@property (assign, nonatomic) BOOL isLongPress;
@end
