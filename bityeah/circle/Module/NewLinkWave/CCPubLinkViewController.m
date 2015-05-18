//
//  CCPubLinkViewController.m
//  HChat
//
//  Created by Sasori on 15/4/8.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCPubLinkViewController.h"
#import "UIView+MBProgressView.h"
#import "HHLinkWaveDataSource.h"
#import "NSString+URLEncode.h"
#import "UIImageView+WebCache.h"
#import "CPTextViewPlaceholder.h"

@interface CCPubLinkViewController ()
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *contentField;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UILabel *linkTitleView;
@property (strong, nonatomic) HHLinkWaveDataSource *dataSource;

@end

@implementation CCPubLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.linkImageView setImageWithURL:[NSURL URLWithString:[self.linkImage encodedString]] placeholderImage:[UIImage imageNamed:@"bj_link_default"]];
    self.linkTitleView.text = self.linkTitle;
    self.contentField.placeholder = @"这一刻的想法...";
}

- (NSString *)_backTitle {
    return @"返回";
}

- (HHLinkWaveDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[HHLinkWaveDataSource alloc]init];
    }
    return _dataSource;
}

- (void)setLinkImage:(NSString *)linkImage {
    _linkImage = linkImage;
    [self.linkImageView setImageWithURL:[NSURL URLWithString:[linkImage encodedString]] placeholderImage:[UIImage imageNamed:@"bj_link_default"]];
}

- (void)setLinkTitle:(NSString *)linkTitle {
    _linkTitle = linkTitle;
    self.linkTitleView.text = linkTitle;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender {
    
    [self.view showHudWithText:@"正在发布···" indicator:YES];
    
    [self.dataSource sendWaveWithTitle:self.linkTitle link:self.linkUrl content:self.contentField.text imageSrc:self.linkImage success:^(CCFeedModel *model) {
        [self.view showHudWithText:@"发布成功" indicator:NO];
        [self performSelector:@selector(submitSuccess:) withObject:model afterDelay:0.8f];
    } failure:^{
        [self.view showHudWithText:@"发布失败" indicator:NO];
        [self.view hideHudAfterDelay:0.8f];
    }];
}

- (void)submitSuccess:(CCFeedModel*)model
{
    [self.view hideHud];
    self.block(model);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
