//
//  CCMyCommentViewController.m
//  testCircle
//
//  Created by Sasori on 14/12/12.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMyCommentViewController.h"
#import "CCMyCommentCell.h"
#import "UIView+MBProgressView.h"
#import "CCMyCommentCell.h"
#import "CCFeedModel.h"
#import "CCFeedPicture.h"
#import "CCMyCommentDataSource.h"
#import "CCDetailViewController.h"
#import "CCUserFeedsViewController.h"
#import "UIHelper.h"
#import "CCLoadMoreCell.h"
#import "CCNotification.h"

NS_ENUM(int, LoadingStatus) {
    LoadingStatusNone,
    LoadingStatusUpdating,
    LoadingStatusLoadingMore,
};

@interface CCMyCommentViewController() <UITableViewDataSource, UITableViewDelegate, CCFeedCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* comments;
@property (nonatomic, strong) CCMyCommentDataSource* dataSource;
@property (nonatomic, strong) UIButton* clearButton;
@property (nonatomic, strong) UIView* noContentView;
@property (nonatomic, strong) NSArray* myCommentIds;
@property (nonatomic, assign) enum LoadingStatus loadingStatus;
@end

@implementation CCMyCommentViewController

- (CCMyCommentDataSource *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [CCMyCommentDataSource new];
    }
    return _dataSource;
}

- (UIView*)noContentView {
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFrame_Width, kFrame_Height-108)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kFrame_Width, 360)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"无记录";
    label.textColor = [UIColor lightGrayColor];
    [bgView addSubview:label];
    return bgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.comments = [NSMutableArray array];
    [UIHelper setNavigationBar:self.navigationController.navigationBar translucent:NO];
    UIButton* button = [UIHelper navRightButtonWithTitle:@"清空"];
    [button addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.clearButton = button;
    self.navigationItem.rightBarButtonItem = item;
    
    UINib* nib = [UINib nibWithNibName:@"CCMyCommentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyComment"];
    
    nib = [UINib nibWithNibName:@"CCLoadMoreCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LoadMore"];
    self.tableView.tableFooterView = [UIView new];
    
    [self update];
    
    [self.dataSource clearServerMyCommentSuccess:nil failure:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CCDidReadMyCommentsNotification object:self];
}

- (void)update {
    self.myCommentIds = [self.dataSource loadMyCommentIds];
    NSArray* commentIds = self.myCommentIds;
    if (commentIds.count > 20) {
        commentIds = [commentIds subarrayWithRange:NSMakeRange(0, 20)];
    }
    [self.view showHudWithText:@"" indicator:YES];
    [self.dataSource getMyCommentsByIds:commentIds success:^(NSArray* comments){
        [self.comments addObjectsFromArray:comments];
        [self.view hideHud];
        [self updateView];
        [self.tableView reloadData];
    } failure:^{
        [self.view showHudWithText:@"加载失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)loadMore {
    NSArray* commentIds = self.myCommentIds;
    if (self.myCommentIds.count - self.comments.count > 20) {
        commentIds = [commentIds subarrayWithRange:NSMakeRange(self.comments.count, 20)];
    } else {
        commentIds = [commentIds subarrayWithRange:NSMakeRange(self.comments.count, self.myCommentIds.count - self.comments.count)];
    }
    [self.view showHudWithText:@"" indicator:YES];
    [self.dataSource getMyCommentsByIds:commentIds success:^(NSArray* comments){
        [self.comments addObjectsFromArray:comments];
        [self.view hideHud];
        [self updateView];
        [self.tableView reloadData];
    } failure:^{
        [self.view showHudWithText:@"加载失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)updateView {
    self.clearButton.enabled = self.comments.count > 0;
    self.tableView.tableHeaderView = self.comments.count == 0 ? self.noContentView : nil;
}

- (void)clearAction:(id)sender {
    [self.view showHudWithText:@"正在清空..." indicator:YES];
    [self.dataSource clearMyCommentSuccess:^{
        [self.view hideHud];
        self.comments = [NSMutableArray array];
        [self updateView];
        [self.tableView reloadData];
    } failure:^{
        [self.view showHudWithText:@"清空失败" indicator:NO];
        [self.view hideHudAfterDelay:0.8];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.comments.count;
    }
    return (self.myCommentIds.count == self.comments.count || self.comments.count == 0) ? 0 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CCMyCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyComment"];
        CCMyCommentModel* model = self.comments[indexPath.row];
        cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
        cell.model = model;
        cell.delegate = self;
        return cell;
    } else {
        CCLoadMoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"MyComment2Detail" sender:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CCMyCommentModel* model = self.comments[indexPath.row];
        return [CCMyCommentCell heightForModel:model forWidth:self.view.bounds.size.width];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        CCLoadMoreCell* c = (CCLoadMoreCell*)cell;
        c.hasMore = YES;
        if (c.hasMore && self.loadingStatus != LoadingStatusLoadingMore) {
            [self loadMore];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CCDetailViewController class]]) {
        CCDetailViewController* vc = (CCDetailViewController*)segue.destinationViewController;
        CCMyCommentCell* cell = (CCMyCommentCell*)sender;
        vc.feedId = cell.model.comment.feedId;
    }
    if ([segue.destinationViewController isKindOfClass:[CCUserFeedsViewController class]]) {
        CCUserFeedsViewController* vc = (CCUserFeedsViewController*)segue.destinationViewController;
        NSNumber* uid = (NSNumber*)sender;
        vc.userId = uid.longLongValue;
    }
}

- (void)cell:(UITableViewCell *)cell didSelectUid:(int64_t)uid {
    [self performSegueWithIdentifier:@"MyComment2UserFeeds" sender:@(uid)];
}

- (void)cell:(UITableViewCell *)cell didSelectURL:(NSString *)URL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
}

- (void)cellDidSelect:(UITableViewCell *)cell {
    
}

@end
