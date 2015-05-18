//
//  CCNewWaveImageCell.h
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCNewWaveImageCell;
@protocol CCNewWaveImageCellDelegate <NSObject>
- (void)deleteCell:(CCNewWaveImageCell*)cell;
@end

@interface CCNewWaveImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) id<CCNewWaveImageCellDelegate> delegate;

@end
