//
//  CCUserFeedsCellTableViewCell.h
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "CCFeedModel.h"

@interface CCUserFeedsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *relativeDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet TQRichTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (nonatomic, strong) CCFeedModel* model;
- (void)hideDateViews ;
- (void)showRelativeDay:(NSString*)day;
- (void)showYear:(NSString*)year month:(NSString*)month day:(NSString*)day;
+ (CGFloat)heightForModel:(CCFeedModel*)model;
@end
