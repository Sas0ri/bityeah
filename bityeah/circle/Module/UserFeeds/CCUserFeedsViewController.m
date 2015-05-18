//
//  CCUserFeedsViewController.m
//  testCircle
//
//  Created by Sasori on 14/12/11.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCUserFeedsViewController.h"
#import "CCShareLinkViewController.h"
#import "CCUserFeedsDataSource.h"
#import "CCUserFeedsCell.h"
#import "NSDate+convenience.h"
#import "CCMainHeaderView.h"
#import "CCUserInfoProvider.h"
#import "UIImageView+WebCache.h"
#import "CCDetailViewController.h"
#import "CCLoadMoreCell.h"
#import "CCNotification.h"
#import "Circle.pb.h"
#import "CCLinkTableViewCell.h"
#import "Context.h"
#import "UIHelper.h"

NS_ENUM(int, LoadingStatus) {
    LoadingStatusNone,
    LoadingStatusUpdating,
    LoadingStatusLoadingMore,
};


@interface CCUserFeedsViewController () <UITableViewDataSource, UITableViewDelegate, CCMainHeaderViewDelegate,CCLinkCellDelegate>
@property (nonatomic, strong) CCUserFeedsDataSource* dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) CCMainHeaderView* headerView;
@property (nonatomic, assign) enum LoadingStatus loadingStatus;
@property (weak, nonatomic) IBOutlet UIButton *myCommentButton;

@end

@implementation CCUserFeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.tableView.frame;
    rect.size.width = kFrame_Width;
    rect.size.height = kFrame_Height;
    self.tableView.frame = rect;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteWave:) name:CCDeleteWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:HHUserInfoUpdatedNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINib* nib = [UINib nibWithNibName:@"CCLoadMoreCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LoadMore"];
    self.tableView.tableFooterView = [UIView new];
    
    nib = [UINib nibWithNibName:@"CCLinkTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"linkCellIdentifier"];
    
    nib = [UINib nibWithNibName:@"CCMainHeaderView" bundle:nil];
    self.headerView = [[nib instantiateWithOwner:nil options:nil] lastObject];
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 280);
    self.headerView.isDetialFeeds = YES;
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.headerView.unreadCount = 0;
    self.headerView.delegate = self;
 
    
    if (self.systemSender.name.length > 0) {
        self.navigationItem.title = self.systemSender.name;
        [self.headerView.avatarView setImageWithURL:[NSURL URLWithString:self.systemSender.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        self.headerView.nameLabel.text = self.systemSender.name;
    } else {
        [self.headerView.avatarView setImageWithURL:[NSURL URLWithString:[[CCUserInfoProvider sharedProvider] avatarForUid:self.userId]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        self.headerView.nameLabel.text = [[CCUserInfoProvider sharedProvider] findNameForUid:self.userId];
        self.navigationItem.title = [[CCUserInfoProvider sharedProvider] findNameForUid:self.userId];
    }
    [self.headerView expandWithScrollView:self.tableView];

    self.myCommentButton.hidden = [[CCUserInfoProvider sharedProvider] uid] != self.userId;
    
    self.dataSource = [[CCUserFeedsDataSource alloc] init];
    self.dataSource.userId = self.userId;
    self.dataSource.systemSender = self.systemSender;
    [self updateModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIHelper setNavigationBar:self.navigationController.navigationBar translucent:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateModel {
    [self.dataSource updateSuccess:^{
        [self performSelector:@selector(endUpdating) withObject:nil afterDelay:.1];
    } failure:^{
        [self performSelector:@selector(endUpdating) withObject:nil afterDelay:.1];
    }];
}



- (void)endUpdating {
    [self.tableView reloadData];
}

#pragma mark TableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.feeds.count+(self.dataSource.hasMore ? 1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.feeds.count) {
        CCFeedModel* model = self.dataSource.feeds[indexPath.row];
        if (model.type != PBWaveTypeTypeCommon) {
            CCLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkCellIdentifier"];
            cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
            cell.model = model;
            cell.linkDelegate = self;
            cell.isFromFeed = YES;
            [self cell:cell atIndexPath:indexPath];
            return cell;
        } else if (model.type == PBWaveTypeTypeCommon){
            CCUserFeedsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UserFeeds"];
            cell.model = model;
            [self configCell:cell atIndexPath:indexPath];
            return cell;
        }
//        }else if (model.type == PBWaveTypeTypeLink || model.type == PBWaveTypeTypeActivity){
//            CCLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkCellIdentifier"];
//            cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
//            cell.model = model;
//            cell.linkDelegate = self;
//            cell.isFromFeed = YES;
//            [self cell:cell atIndexPath:indexPath];
//            return cell;
//        }
    }
    CCLoadMoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
    return cell;
}

- (void)linkBaseViewTap:(CCLinkTableViewCell *)cell
{
   if (cell.model.type == PBWaveTypeTypeNews ||cell.model.type == PBWaveTypeTypeNotice){
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL =cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    } else if (cell.model.type == PBWaveTypeTypeLink){
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL =cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.dataSource.feeds.count) {
        CCFeedModel *model = self.dataSource.feeds[indexPath.row];
        if (model.type == PBWaveTypeTypeCommon) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"UserFeeds2Detail" sender:cell];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.feeds.count) {
        CCFeedModel* model = self.dataSource.feeds[indexPath.row];
        if (model.type != PBWaveTypeTypeCommon){
            return 60.0f;
        }
        return [CCUserFeedsCell heightForModel:model];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.feeds.count) {
        CCLoadMoreCell* c = (CCLoadMoreCell*)cell;
        c.hasMore = self.dataSource.hasMore;
        if (c.hasMore && self.loadingStatus != LoadingStatusLoadingMore) {
            [self.dataSource loadMoreSuccess:^{
                [self performSelector:@selector(endUpdating) withObject:nil afterDelay:.1];
            } failure:^{
                
            }];
        }
    }
}

- (void)configCell:(CCUserFeedsCell*)c atIndexPath:(NSIndexPath*)indexPath {
    [c hideDateViews];
    CCFeedModel* model = self.dataSource.feeds[indexPath.row];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:model.createAt/1000];
    if (indexPath.row != 0) {
        CCFeedModel* preModel = self.dataSource.feeds[indexPath.row - 1];
        NSDate* preDate = [NSDate dateWithTimeIntervalSince1970:preModel.createAt/1000];
        if (date.year == preDate.year && date.month == preDate.month && date.day == preDate.day) {
            return;
        }
    }
    NSDate* today = [NSDate date];
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
        [c showRelativeDay:@"今天"];
    } else if (today.day - date.day == 1 && today.month == date.month && today.year == date.year) {
        [c showRelativeDay:@"昨天"];
    } else if (today.year == date.year) {
        [c showYear:nil month:[self getChineseMonth:date.month] day:[NSString stringWithFormat:@"%2d", date.day]];
    } else {
        [c showYear:[NSString stringWithFormat:@"%d", date.year] month:[self getChineseMonth:date.month] day:[NSString stringWithFormat:@"%2d", date.day]];
    }
}

- (void)cell:(CCLinkTableViewCell*)c atIndexPath:(NSIndexPath*)indexPath {
    [c hideDateViews];
    CCFeedModel* model = self.dataSource.feeds[indexPath.row];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:model.createAt/1000];
    if (indexPath.row != 0) {
        CCFeedModel* preModel = self.dataSource.feeds[indexPath.row - 1];
        NSDate* preDate = [NSDate dateWithTimeIntervalSince1970:preModel.createAt/1000];
        if (date.year == preDate.year && date.month == preDate.month && date.day == preDate.day) {
            return;
        }
    }
    NSDate* today = [NSDate date];
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
        [c showRelativeDay:@"今天"];
    } else if (today.day - date.day == 1 && today.month == date.month && today.year == date.year) {
        [c showRelativeDay:@"昨天"];
    } else if (today.year == date.year) {
        [c showYear:nil month:[self getChineseMonth:date.month] day:[NSString stringWithFormat:@"%2d", date.day]];
    } else {
        [c showYear:[NSString stringWithFormat:@"%d", date.year] month:[self getChineseMonth:date.month] day:[NSString stringWithFormat:@"%2d", date.day]];
    }
}


- (NSString*)getChineseMonth:(int)month {
    NSString* result = @"";
    switch (month) {
        case 1:
            result = @"一月";
            break;
        case 2:
            result = @"二月";
            break;
        case 3:
            result = @"三月";
            break;
        case 4:
            result = @"四月";
            break;
        case 5:
            result = @"五月";
            break;
        case 6:
            result = @"六月";
            break;
        case 7:
            result = @"七月";
            break;
        case 8:
            result = @"八月";
            break;
        case 9:
            result = @"九月";
            break;
        case 10:
            result = @"十月";
            break;
        case 11:
            result = @"十一月";
            break;
        case 12:
            result = @"十二月";
            break;
        default:
            break;
    }
    return result;
}

- (void)dealloc {
    [self.headerView detatchWithScrollView:self.tableView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didDeleteWave:(NSNotification*)sender {
    int64_t waveId = [sender.userInfo[@"object"] longLongValue];
    [self.dataSource.feeds filterUsingPredicate:[NSPredicate predicateWithFormat:@"feedId != %lld", waveId]];
    [self.tableView reloadData];
}

- (void)userInfoUpdated:(NSNotification*)sender {
    NSDictionary* dic = sender.userInfo;
    int64_t uid = [dic[@"uid"] longLongValue];
    if (uid == self.userId) {
        NSString* avatar = nil;
        
        NSString* name = [[CCUserInfoProvider sharedProvider] findNameForUid:self.userId];
        avatar = [[CCUserInfoProvider sharedProvider] avatarForUid:self.userId];
        self.navigationItem.title = name;
        self.headerView.nameLabel.text = name;
        [self.headerView.avatarView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }
}

- (void)headerView:(CCMainHeaderView *)headerView didTapOnAvatar:(HHAvatarImageView *)avataView {
//    if (self.userId > 0) {
//        [UIHelper setNavigationBar:self.navigationController.navigationBar translucent:NO];
//        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        HHUserInfoViewController* vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoID"];
//        vc.uid = self.userId;
//        vc.isCircle = YES;
//        [[Context sharedContext].navigationController pushViewController:vc animated:YES];
//    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [UIHelper setNavigationBar:self.navigationController.navigationBar translucent:NO];

    if ([segue.destinationViewController isKindOfClass:[CCDetailViewController class]]) {
        CCDetailViewController* vc = (CCDetailViewController*)segue.destinationViewController;
        CCUserFeedsCell* cell = (CCUserFeedsCell*)sender;
        vc.feedId = cell.model.feedId;
    }
}

@end
