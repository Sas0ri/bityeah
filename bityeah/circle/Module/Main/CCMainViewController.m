//
//  CCMainViewController.m
//  circle
//
//  Created by Sasori on 14/11/26.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCMainViewController.h"
#import "CCPersonalFeedCell.h"
#import "CCLikeCommentView.h"
#import "CCFeedModel.h"
#import "CCNewFeedCountModel.h"
#import "CCNewFeedCountCell.h"
#import "CCFeedCommentCell.h"
#import "CTAssetsPickerController.h"
#import "CCNewWaveViewController.h"
#import "UIView+MBProgressView.h"
#import "CCMainDataSource.h"
#import "CCNewFeedCountModel.h"
#import "CCFaceToolBar.h"
#import "LXActionSheet.h"
#import "CCFeedComment.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CCURLDefine.h"
#import "CCFeedPicture.h"
#import "CCFeedImageCell.h"
#import "CCDetailViewController.h"
#import "CCMainHeaderView.h"
#import "HHPullProgressView.h"
#import "UIColor+FlatUI.h"
#import "CCUserFeedsViewController.h"
#import "CCMyCommentViewController.h"
#import "CCMainDataSource.h"
#import "CCNotification.h"
#import "CCLoadMoreCell.h"
#import "CCLinkTableViewCell.h"
#import "CCShareLinkViewController.h"
#import "BYDefinitions.h"
#import "CCNoTypeCell.h"
#import "CCUserLinkTableCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTAssetsPickerController.h"
#import "HHLinkWaveTableViewController.h"

#define kActionSheetDeleteCommentTag 125421521
#define kTopCommentsCount 3

NS_ENUM(int, LoadingStatus) {
    LoadingStatusNone,
    LoadingStatusUpdating,
    LoadingStatusLoadingMore,
};

@interface CCMainViewController () <UITableViewDataSource, UITableViewDelegate, CCFeedCellDelegate, CCLikeCommentViewDelegate, UIGestureRecognizerDelegate, CCNewWaveViewControllerDelegate, CCFaceToolBarDelegate, LXActionSheetDelegate, CCMainHeaderViewDelegate,CCLinkCellDelegate,UIActionSheetDelegate,CTAssetsPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MJPhotoBrowserDelegate>

@property (nonatomic, strong) CCLikeCommentView* likeCommentView;
@property (nonatomic, strong) CCFaceToolBar* inputToolbar;
@property (nonatomic, assign) BOOL keyboardIsVisible;
@property (nonatomic, assign) NSInteger currentWaveIndex;
@property (nonatomic, assign) int64_t currentCommentToId;
@property (nonatomic, strong) NSIndexPath* currentDeleteCommentIndex;
@property (nonatomic, weak) CCMainHeaderView* headerView;
@property (nonatomic, strong) HHPullProgressView* progressView;
@property (nonatomic, assign) enum LoadingStatus loadingStatus;
@property (nonatomic, strong) CCMainDataSource* dataSource;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) NSMutableArray* feeds;
//@property (nonatomic, strong) NSMutableArray *redPackets;
//@property (retain, nonatomic) NSMutableArray *dataArray;
//@property (retain, nonatomic) NSMutableArray *feedRedPackets;

@property (retain, nonatomic) NSArray *dateDatas;
@property (nonatomic, strong) NSMutableArray* assets;
@property (nonatomic, strong) NSArray* textCopyItems;
@property (nonatomic, strong) NSArray *imageCopyItems;
@property (nonatomic, strong) NSIndexPath *selectPath;
@end

static const CGFloat kLikeCommentViewWidth = 180;

#define kSubTitleHeight 34.0f
#define kSepatorHeight 45.0f
static NSInteger kMaxImageCount = 9;

@implementation CCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.tableView.frame;
    rect.size.width = CGRectGetWidth(self.view.frame);
    rect.size.height = CGRectGetHeight(self.view.frame);
    self.tableView.frame = rect;
    
    [self installNotifications];
    self.dataSource = [CCMainDataSource new];

    self.assets = [[NSMutableArray alloc]init];
    self.inputToolbar = [[CCFaceToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.bounds.size.height - toolBarHeight,self.view.frame.size.width,toolBarHeight) superView:self.view];
    self.inputToolbar.faceBarDelegate = self;
    
    UINib* nib = [UINib nibWithNibName:@"CCLikeCommentView" bundle:nil];
    self.likeCommentView = [[nib instantiateWithOwner:nil options:nil] firstObject];
    self.likeCommentView.clipsToBounds = YES;
    self.likeCommentView.delegate = self;
    
    nib = [UINib nibWithNibName:@"CCMainHeaderView" bundle:nil];
    self.headerView = [[nib instantiateWithOwner:nil options:nil] lastObject];
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 280);
    self.headerView.isDetialFeeds = NO;
    self.headerView.delegate = self;
    
    [self.headerView.avatarView setImageWithURL:[NSURL URLWithString:[[CCUserInfoProvider sharedProvider] avatarForUid:[[CCUserInfoProvider sharedProvider] uid]]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.headerView.nameLabel.text = [[CCUserInfoProvider sharedProvider] findNameForUid:[[CCUserInfoProvider sharedProvider] uid]];
    [self.headerView expandWithScrollView:self.tableView];
    
    self.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64);
    [self.view bringSubviewToFront:self.navigationBar];
    
    UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] init];
    tg.delegate = self;
    [self.view addGestureRecognizer:tg];
    
    self.tableView.backgroundColor = [UIColor colorFromHexCode:@"f4f4f4"];
    nib = [UINib nibWithNibName:@"CCLoadMoreCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LoadMore"];
    self.tableView.tableFooterView = [UIView new];
    
    nib = [UINib nibWithNibName:@"CCLinkTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"linkCell"];
    
    nib = [UINib nibWithNibName:@"CCUserLinkTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"userLinkCell"];
    
    [self loadData];
//    [self.view addSubview:self.editView];
}

//- (NSArray *)textCopyItems
//{
//    if (_textCopyItems == nil) {
//        UIMenuItem* item = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyToPaste:)];
//        UIMenuItem *transmitItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(transmitToPaste:)];
//        _textCopyItems = @[item, transmitItem];
//    }
//    return _textCopyItems;
//}

//- (void)copyToPaste:(id)sender
//{
//    UIPasteboard* p  = [UIPasteboard generalPasteboard];
//    p.string = [CCTransModel share].content;
//}

//- (void)transmitToPaste:(id)sender
//{
//    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    HHTransmitTableViewController* vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"SendImageIdentifiyID"];
//    vc1.fromType = HHTransFromType_Circle;
//    [self.navigationController pushViewController:vc1 animated:YES];
//}

//- (NSArray *)imageCopyItems
//{
//    if (!_imageCopyItems) {
//        UIMenuItem *saveItem = [[UIMenuItem alloc]initWithTitle:@"保存" action:@selector(saveImageToPhotoAlbum:)];
//        UIMenuItem *transmitItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(imageTransmitToPaste:)];
//        _imageCopyItems = @[saveItem,transmitItem];
//    }
//    return _imageCopyItems;
//}

- (void)saveImageToPhotoAlbum:(id)sender
{
    CCPersonalFeedCell *cell = (CCPersonalFeedCell *)[self.tableView cellForRowAtIndexPath:self.selectPath];
    UIImageWriteToSavedPhotosAlbum(cell.pressImage, self,                                  @selector(image:didFinishSavingWithError:contextInfo:), nil);

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [self.view showHudWithText:@"保存失败" indicator:NO];
    } else {
        [self.view showHudWithText:@"保存成功" indicator:NO];
    }
    [self.view hideHudAfterDelay:0.8f];
}


//- (void)imageTransmitToPaste:(id)sender
//{
//    CCPersonalFeedCell *cell = (CCPersonalFeedCell *)[self.tableView cellForRowAtIndexPath:self.selectPath];
//    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    HHTransmitTableViewController* vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"SendImageIdentifiyID"];
//    [CCTransModel share].circleSendImage = cell.pressImage;
//    vc1.fromType = HHTransFromType_Circle;
//    [self.navigationController pushViewController:vc1 animated:YES];
//}


//- (HHEditView *)editView
//{
//    if (!_editView) {
//        _editView = [[[NSBundle mainBundle]loadNibNamed:@"HHEditView" owner:self options:nil]lastObject];
//        _editView.frame = CGRectMake(0, 0, kFrame_Width, kFrame_Height);
//        _editView.delegate = self;
//        _editView.blurTintColor = nil;
//        _editView.hidden = YES;
//    }
//    return _editView;
//    
//}

- (NSString *)_backTitle {
    return @"返回";
}

- (void)installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddComment:) name:CCNewCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendWave:) name:CCSendNewWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUnlike:) name:CCUnlikeWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteComment:) name:CCDeleteCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteWave:) name:CCDeleteWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReadMyComment:) name:CCDidReadMyCommentsNotification object:nil];
}

- (void)uninstallNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNewCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCSendNewWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCUnlikeWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCDeleteCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCDeleteWaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCDidReadMyCommentsNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.inputToolbar.shouldChangeFrame = YES;
    [self showPullProgressView];
    if (self.tableView.contentOffset.y <= -40) {
        [UIHelper setNavigationBar:self.navigationBar translucent:YES];
    }else{
        [UIHelper setNavigationBar:self.navigationBar translucent:NO];
    }
//    [self loadDateData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:HHToolbarFrameWillChange object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputToolbar resignFirstResponder];
    [self hidePullProgressView];
    [UIHelper setNavigationBar:self.navigationBar translucent:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.inputToolbar.shouldChangeFrame = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HHToolbarFrameWillChange object:nil];
}

-(void)keyboardFrameWillChange:(id)sender
{
    NSNotification* notification = (NSNotification*)sender;
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//更改后的键盘
    
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardIsVisible = keyboardRect.origin.y > 0;
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (!animationDurationValue) {
        animationDuration = 0.3f;
    }
    CGRect r1 = self.tableView.frame;
    if (keyboardRect.origin.y == self.view.bounds.size.height - toolBarHeight) {
        keyboardRect.origin.y = self.view.bounds.size.height;
    }
    if (self.tableView.contentSize.height + self.tableView.contentInset.top < self.view.bounds.size.height) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.tableView.frame = CGRectMake(0, 0, r1.size.width, keyboardRect.origin.y);
        }];
        if (self.keyboardIsVisible && self.tableView.contentSize.height - keyboardRect.origin.y > 0) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - keyboardRect.origin.y-self.tableView.contentInset.top) animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
        }
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            self.tableView.frame = CGRectMake(0,  0, r1.size.width, keyboardRect.origin.y);
        } completion:^(BOOL finished) {
            if (keyboardRect.origin.y < self.view.bounds.size.height - toolBarHeight) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.currentWaveIndex] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }];
    }
}

- (void)loadData {
    if (self.feeds.count == 0) {
        [self loadLocalModel];
    }
    if ([[NSDate date] timeIntervalSince1970] - [self.dataSource lastUpdateStamp] > 60*60){
        [self updateModel];
    }
}

- (void)loadLocalModel {
    [self.progressView startAnimating];
    
    [self.dataSource loadLocalSuccess:^(NSArray* feeds){
        [self performSelector:@selector(endLoadLocalWithFeeds:) withObject:feeds afterDelay:.3];
    } failure:^{
        [self performSelector:@selector(endLoadLocalWithFeeds:) withObject:nil afterDelay:.3];
    }];
}

- (void)updateModel {
    if (self.loadingStatus == LoadingStatusUpdating) {
        return;
    }
//    [self loadDateData];
    [self.progressView startAnimating];
    self.loadingStatus = LoadingStatusUpdating;
    [self.dataSource updateSuccess:^(NSArray* feeds){
        [self performSelector:@selector(endUpdatingWithFeeds:) withObject:feeds afterDelay:.3];
    } failure:^{
        [self performSelector:@selector(endUpdating) withObject:nil afterDelay:.3];
    }];
}

- (void)loadMoreModel {
    if (self.loadingStatus == LoadingStatusUpdating || self.loadingStatus == LoadingStatusLoadingMore || !self.dataSource.hasMore) {
        return;
    }
    self.loadingStatus = LoadingStatusLoadingMore;
    CCFeedModel* feed = [self.feeds lastObject];

    [self.dataSource loadMoreWithWaveId:feed.feedId success:^(NSArray *feeds) {
        [self.feeds addObjectsFromArray:feeds];
        [self performSelector:@selector(endLoadMore) withObject:nil afterDelay:.1];
    } failure:^{
        [self performSelector:@selector(endLoadMore) withObject:nil afterDelay:.1];
    }];
}

- (void)endUpdatingWithFeeds:(NSArray*)feeds {
    self.feeds = [feeds mutableCopy];
    
    [self endUpdating];
}

- (void)endLoadLocalWithFeeds:(NSArray*)feeds {
    self.feeds = [feeds mutableCopy];

    [self.headerView setUnreadCount:self.dataSource.myCommentModel.commentIds.count];
    [self.progressView stopAnimating];
    [self.tableView reloadData];
}

- (void)endUpdating {
    [self.headerView setUnreadCount:self.dataSource.myCommentModel.commentIds.count];
    self.loadingStatus = LoadingStatusNone;
    [self.progressView stopAnimating];
    [self.tableView reloadData];
}

- (void)endLoadMore {
    self.loadingStatus = LoadingStatusNone;
    [self.tableView reloadData];
}

#pragma mark TableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feeds.count+(self.dataSource.hasMore ? 1:0) ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* result = nil;
    if (indexPath.section == self.feeds.count) {
        CCLoadMoreCell* c = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
        result = c;
    } else {
        CCFeedModel* model = self.feeds[indexPath.section];
        if (model.type == PBWaveTypeTypeCommon) {
            if (indexPath.row == 0) {
            CCPersonalFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Personal"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                cell.model = model;
                cell.delegate = self;
                result = cell;
                
            } else if (indexPath.row != [self numberOfRowsInSection:indexPath.section]-1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section]-1) {
                    CCFeedCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                    cell.delegate = self;
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    cell.comment = comment;
                    result = cell;
                } else {
                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ToDetail"];
                    result = cell;
                }
            } else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Separate"];
                result = cell;
            }
        }
        else if (model.type == PBWaveTypeTypeNews || model.type == PBWaveTypeTypeNotice){
            if (indexPath.row == 0) {
                CCLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkCell"];
                cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                cell.model = model;
                cell.delegate = self;
                cell.linkDelegate = self;
                result = cell;
            }else if (indexPath.row != [self numberOfRowsInSection:indexPath.section]-1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section]-1) {
                    CCFeedCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                    cell.delegate = self;
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    cell.comment = comment;
                    result = cell;
                } else {
                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ToDetail"];
                    result = cell;
                }
            } else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Separate"];
                result = cell;
            }
        }else if (model.type == PBWaveTypeTypeLink){
            if (indexPath.row == 0) {
                CCUserLinkTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userLinkCell"];
                cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                cell.model = model;
                cell.delegate = self;
                cell.linkDelegate = self;
                result = cell;
            }else if (indexPath.row != [self numberOfRowsInSection:indexPath.section]-1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section]-1) {
                    CCFeedCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                    cell.delegate = self;
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    cell.comment = comment;
                    result = cell;
                } else {
                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ToDetail"];
                    result = cell;
                }
            } else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Separate"];
                result = cell;
            }
        }else {
            if (indexPath.row == 0) {
                CCNoTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NoType"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                cell.model = model;
                cell.delegate = self;
                result = cell;
            } else if (indexPath.row != [self numberOfRowsInSection:indexPath.section]-1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section]-1) {
                    CCFeedCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInfoProvider = [CCUserInfoProvider sharedProvider];
                    cell.delegate = self;
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    cell.comment = comment;
                    result = cell;
                } else {
                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ToDetail"];
                    result = cell;
                }
            } else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Separate"];
                result = cell;
            }
        }
    }
    return result;
}

- (void)linkBaseViewTap:(CCLinkTableViewCell *)cell
{
    if (cell.model.type == PBWaveTypeTypeNews || cell.model.type == PBWaveTypeTypeNotice){
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL = cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    } else if (cell.model.type == PBWaveTypeTypeLink){
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL = cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    }
}

- (void)linkTap:(CCLinkTableViewCell *)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"circle" bundle:nil];
    CCUserFeedsViewController *userFeedCtrl = [storyboard instantiateViewControllerWithIdentifier:@"UserFeedsID"];
    CCFeedModel* model = cell.model;
    userFeedCtrl.userId = model.senderId;
    userFeedCtrl.systemSender = model.systemSender;
    [self.navigationController pushViewController:userFeedCtrl animated:YES];
}

#pragma mark - HHGardenRedPacketTitleDelegate

//- (void)cellSelect:(HHGardenRedPacketTitleTableViewCell *)cell redPacket:(PBRedPacket *)redpacket
//{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    NSString *desc = redpacket.desc;
//    if (desc.length  > 100) {
//        desc = [desc substringToIndex:100];
//    }
//    CGSize cellSize = [desc sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kScreen_Width - 80, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    float height =ceilf(cellSize.height);
//    if (![[self.dataArray[indexPath.section] objectForKey:@"isAttached"] boolValue]) {
//        NSDictionary *dic = @{@"isAttached":@(YES),@"isRobbed":@(redpacket.youHaveRobbed)};
//        self.dataArray[indexPath.section] = dic;
//        height += 10.0f;
//    }else{
//        NSDictionary *dic = @{@"isAttached":@(YES),@"isRobbed":@(redpacket.youHaveRobbed)};
//        self.dataArray[indexPath.section] = dic;
//        if (height > kSepatorHeight) {
//            height = kSepatorHeight;
//        }
//    }
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//}

#pragma mark - HHGardenRobRedPacketDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if (indexPath.section != self.feeds.count) {
        CCFeedModel* model = self.feeds[indexPath.section];
        if (model.type == PBWaveTypeTypeCommon) {
            if (indexPath.row == 0) {
                return [CCPersonalFeedCell heightForModel:model forWidth:tableView.bounds.size.width];
            } else if (indexPath.row != [self numberOfRowsInSection:indexPath.section] - 1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section] - 1) {
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    CGFloat height = [CCFeedCommentCell heightForModel:comment forWidth:tableView.bounds.size.width];
                    height += indexPath.row == 1 ? 8 : 0;
                    return height;
                } else {
                    return 24;
                }
            } else {
                return 10;
            }
        }
        else if (model.type == PBWaveTypeTypeNews || model.type == PBWaveTypeTypeNotice || model.type == PBWaveTypeTypeActivity){
            if (indexPath.row == 0) {
                return 145.0f;
            }else if (indexPath.row != [self numberOfRowsInSection:indexPath.section] - 1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section] - 1) {
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    CGFloat height = [CCFeedCommentCell heightForModel:comment forWidth:tableView.bounds.size.width];
                    height += indexPath.row == 1 ? 8 : 0;
                    return height;
                } else {
                    return 24;
                }
            } else {
                return 10;
            }
        }
        else if (model.type == PBWaveTypeTypeLink){
            if (indexPath.row == 0) {
                return [CCUserLinkTableCell heightForModel:model];
            }else if (indexPath.row != [self numberOfRowsInSection:indexPath.section] - 1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section] - 1) {
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    CGFloat height = [CCFeedCommentCell heightForModel:comment forWidth:tableView.bounds.size.width];
                    height += indexPath.row == 1 ? 8 : 0;
                    return height;
                } else {
                    return 24;
                }
            } else {
                return 10;
            }
        }
        else if (model.type == PBWaveTypeTypeNil) {
            if (indexPath.row == 0) {
                return [CCNoTypeCell heightForModel:model forWidth:tableView.bounds.size.width];
            } else if (indexPath.row != [self numberOfRowsInSection:indexPath.section] - 1) {
                if (indexPath.row != [self numberOfCommentsInSection:indexPath.section] - 1) {
                    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
                    CGFloat height = [CCFeedCommentCell heightForModel:comment forWidth:tableView.bounds.size.width];
                    height += indexPath.row == 1 ? 8 : 0;
                    return height;
                } else {
                    return 24;
                }
            } else {
                return 10;
            }
        }
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CCFeedModel* model = self.feeds[indexPath.section];
        if (model.type != PBWaveTypeTypeRedPacket) {
            [self performSegueWithIdentifier:@"Main2Detail" sender:model];
        }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == self.feeds.count) {
        CCLoadMoreCell* c = (CCLoadMoreCell*)cell;
        c.hasMore = self.dataSource.hasMore;
        [self loadMoreModel];
    }
    if ([cell isKindOfClass:[CCFeedCommentCell class]]) {
        CCFeedCommentCell* c = (CCFeedCommentCell*)cell;
        [c showSepLine:indexPath.row < [self numberOfRowsInSection:indexPath.section]-2];
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
        CCFeedModel* model = self.feeds[section];
        
        if (model.type == PBWaveTypeTypeActivity) {
            NSInteger result = 2;
            result += model.commentCountModel.commentCount > model.firstPageComments.count ? model.firstPageComments.count + 1 : model.firstPageComments.count;
            return result;
        }
        
        if (model.type == PBWaveTypeTypeCommon) {
            NSInteger result = 2;
            result += model.commentCountModel.commentCount > model.firstPageComments.count ? model.firstPageComments.count + 1 : model.firstPageComments.count;
            return result;
        }else if (model.type == PBWaveTypeTypeNews || model.type == PBWaveTypeTypeNotice){
             NSInteger result = 2;
            result += model.commentCountModel.commentCount > model.firstPageComments.count ? model.firstPageComments.count + 1 : model.firstPageComments.count;
            return result;;
        }else if (model.type == PBWaveTypeTypeRedPacket){
            return 3;
        }else if (model.type == PBWaveTypeTypeLink){
            NSInteger result = 2;
            result += model.commentCountModel.commentCount > model.firstPageComments.count ? model.firstPageComments.count + 1 : model.firstPageComments.count;
            return result;
        }
        else if (model.type == PBWaveTypeTypeNil) {
            NSInteger result = 2;
            result += model.commentCountModel.commentCount > model.firstPageComments.count ? model.firstPageComments.count + 1 : model.firstPageComments.count;
            return result;
        }
    
    return 1;
}

- (NSInteger)numberOfCommentsInSection:(NSInteger)section {
        CCFeedModel* model = self.feeds[section];
        NSInteger result = 2;
        result += model.firstPageComments.count;
        return result;
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self hideLikeCommentView];
    }
    if (self.loadingStatus != LoadingStatusUpdating) {
        CGFloat progress = (-scrollView.contentOffset.y - 280)/64;
        self.progressView.progress = progress;
        if (!scrollView.isDragging) {
            if (progress > 1.0) {
                [self updateModel];
            }
        }
    }
    
    CGFloat contentOffSetY = scrollView.contentOffset.y;
    [UIHelper setNavigationBar:self.navigationBar translucent:contentOffSetY <= - 40];
}

- (void)commentToIndexPath:(NSIndexPath*)indexPath {
    CCFeedModel* model = self.feeds[indexPath.section];
    CCFeedComment* comment = model.firstPageComments[indexPath.row-1];
    //不是自己发的就回复
    if (comment.authorId != [[CCUserInfoProvider sharedProvider] uid]) {
        self.currentCommentToId = comment.authorId;
        self.currentWaveIndex = indexPath.section;
        NSString* name = [[CCUserInfoProvider sharedProvider] findNameForUid:comment.authorId];
        self.inputToolbar.placeHolder = [NSString stringWithFormat:@"回复：%@",name];
        [self.inputToolbar becomeFirstResponder];
    } else {
        //是自己发的就删除
        LXActionSheet* as = [[LXActionSheet alloc] initWithTitle:@"删除此条评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        [as showInView:self.view];
        as.tag = kActionSheetDeleteCommentTag;
        self.currentDeleteCommentIndex = indexPath;
    }
}

#pragma mark LXActionSheetDelegate
- (void)actionSheetDidClickOnCancelButton:(LXActionSheet *)actionSheet {
    if (actionSheet.tag == kActionSheetDeleteCommentTag) {
        self.currentDeleteCommentIndex = nil;
    }
}

- (void)actionSheet:(LXActionSheet *)actionSheet didClickOnButtonIndex:(NSInteger)buttonIndex {
    
}

- (void)actionSheetDidClickOnDestructiveButton:(LXActionSheet *)actionSheet {
    CCFeedModel* model = self.feeds[self.currentDeleteCommentIndex.section];
    CCFeedComment* comment = model.firstPageComments[self.currentDeleteCommentIndex.row-1];
    [self.view showHudWithText:@"正在删除..." indicator:YES];
    [self.dataSource deleteCommentWithId:comment.commentId waveId:model.feedId type:PBWaveCommentTypeTypeComment success:^{
        model.commentCountModel.commentCount-=1;
        
        [self.view showHudWithText:@"删除成功" indicator:NO];
        [self.view hideHudAfterDelay:.8];
        NSMutableArray* arr = [NSMutableArray arrayWithArray:model.firstPageComments];
        [arr removeObject:comment];
        model.firstPageComments = [arr copy];
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:self.currentDeleteCommentIndex.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    } failure:^{
        [self.view showHudWithText:@"删除失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

#pragma mark CellDelegate

- (void)likeCommentAction:(id)sender onModel:(CCFeedModel *)model {
    if (self.likeCommentView.superview != nil) {
        [self hideLikeCommentView];
    } else {
        self.currentCommentToId = 0;
        [self showLikeCommentViewWithSender:sender withModel:model];
    }
}

- (void)showLikeCommentViewWithSender:(id)sender withModel:(CCFeedModel*)model {
    NSInteger index = [self.feeds indexOfObject:model];
    CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
    UIView* view = (UIView*)sender;
    CGRect frame = [self.view convertRect:view.frame fromView:cell.bottomContainerView];
    CGRect originFrame = self.likeCommentView.frame;
    originFrame.origin.x = frame.origin.x;
    originFrame.origin.y = frame.origin.y - (self.likeCommentView.frame.size.height -  frame.size.height)/2;
    originFrame.size.width = 0;
    
    CGRect targetFrame = originFrame;
    targetFrame.origin.x -= kLikeCommentViewWidth;
    targetFrame.origin.y = originFrame.origin.y;
    targetFrame.size.width = kLikeCommentViewWidth;
    
    self.likeCommentView.frame = originFrame;
    [self.view addSubview:self.likeCommentView];
    
    self.likeCommentView.hasLiked = model.commentCountModel.likedId > 0;
    self.likeCommentView.index = index;
    [UIView animateWithDuration:.3 animations:^{
        self.likeCommentView.frame = targetFrame;
    }];
}

- (void)hideLikeCommentView {
    //    if (self.likeCommentView.superview == nil) {
    //        return;
    //    }
    //    [UIView animateWithDuration:.3 animations:^{
    //        CGRect r = self.likeCommentView.frame;
    //        r.size.width = 0;
    //        r.origin.x += kLikeCommentViewWidth;
    //        self.likeCommentView.frame = r;
    //    } completion:^(BOOL finished) {
    //        [self.likeCommentView removeFromSuperview];
    //    }];
}

- (void)cellDidSelect:(UITableViewCell *)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        CCFeedModel* model = self.feeds[indexPath.section];
        [self performSegueWithIdentifier:@"Main2Detail" sender:model];
    }
    if (indexPath.section-1 != self.feeds.count) {
        if (indexPath.row > 0) {
            //            [self commentToIndexPath:indexPath];
        }
    }
}

- (void)cell:(CCPersonalFeedCell *)cell didSelectImageAtIndex:(NSInteger)index {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    CCFeedModel* model = self.feeds[indexPath.section];
    
    NSInteger count = model.pictures.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        CCFeedPicture* fp = model.pictures[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[CCURLDefine HDPath:fp.relativeURLString]]; // 图片路径
        photo.srcImageView = ((CCFeedImageCell*)[cell.imagesView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]).imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.delegate = self;
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser showInController:self];
}

//- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser photo:(MJPhoto *)photo atIndex:(NSUInteger)index
//{
//    switch (index) {
//        case 0:{
//            [CCTransModel share].circleSendImage = photo.image;
//            [self transmitToPaste:nil];
//        }
//            break;
//        case 1:{
//            UIImageWriteToSavedPhotosAlbum(photo.image, self,                                  @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        }
//            break;
//        default:
//            break;
//    }
//}

- (void)cell:(UITableViewCell *)cell longPressImageAtIndex:(NSInteger)index
{
    if ([UIMenuController sharedMenuController].isMenuVisible) {
        return;
    }
    [self becomeFirstResponder];
    CCPersonalFeedCell *feedCell = (CCPersonalFeedCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:feedCell];
    self.selectPath = indexPath;
    CGRect r = [feedCell convertRect:feedCell.tipFrame toView:self.view];
    [self showMenuControllerTarget:r inView:self.view withMenuItems:self.imageCopyItems];
}

- (void)cell:(UITableViewCell *)cell longPressTextView:(UIView *)textView
{
    CGRect r = [cell convertRect:textView.frame toView:self.view];
    [self showMenuControllerTarget:r inView:self.view withMenuItems:self.textCopyItems];
}

- (void)showMenuControllerTarget:(CGRect)r inView:(UIView*)view withMenuItems:(NSArray*)items {
    [[UIMenuController sharedMenuController] setMenuItems:items];
    [[UIMenuController sharedMenuController] setTargetRect:r inView:view];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)cell:(UITableViewCell *)cell didSelectUid:(int64_t)uid {
    if ([cell isKindOfClass:[CCPersonalFeedCell class]]) {
        CCPersonalFeedCell* c = (CCPersonalFeedCell*)cell;
        [self performSegueWithIdentifier:@"Main2UserFeeds" sender:c.model];
    } else {
        CCFeedModel* model = [CCFeedModel new];
        model.senderId = uid;
        [self performSegueWithIdentifier:@"Main2UserFeeds" sender:model];
    }
}

- (void)cell:(CCPersonalFeedCell *)cell didSelectURL:(NSString *)URL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
}

- (void)cellDidComment:(CCPersonalFeedCell *)cell {
    NSIndexPath* index = [self.tableView indexPathForCell:cell];
    [self commentActionAtIndex:index.section];
}

- (void)cellDidLike:(CCPersonalFeedCell *)cell {
    CCFeedModel* model = cell.model;
    NSIndexPath* index = [self.tableView indexPathForCell:cell];
    if (model.commentCountModel.likedId > 0) {
        [self unlikeAtIndex:index.section];
    } else {
        [self likeAtIndex:index.section];
    }
}

- (void)likeAtIndex:(NSInteger)index {
    [self hideLikeCommentView];
    CCFeedModel* model = self.feeds[index];
    [self.view showHudWithText:@"正在点赞..." indicator:YES];
    [self.dataSource likeWithWaveId:model.feedId success:^(CCFeedComment* comment){
        model.commentCountModel.likedId = comment.commentId;
        model.commentCountModel.likeCount += 1;
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
        self.likeCommentView.hasLiked = !self.likeCommentView.hasLiked;
        [self.view hideHud];
    } failure:^{
        [self.view showHudWithText:@"点赞失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)unlikeAtIndex:(NSInteger)index {
    [self hideLikeCommentView];
    CCFeedModel* model = self.feeds[index];
    [self.view showHudWithText:@"正在取消赞..." indicator:YES];
    [self.dataSource deleteCommentWithId:model.commentCountModel.likedId waveId:model.feedId type:PBWaveCommentTypeTypeLike success:^{
        model.commentCountModel.likedId = 0;
        model.commentCountModel.likeCount -= 1;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.view hideHud];
    } failure:^{
        [self.view showHudWithText:@"取消失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)commentActionAtIndex:(NSInteger)index {
    [self hideLikeCommentView];
    self.inputToolbar.placeHolder = @"评论";
    [self.inputToolbar becomeFirstResponder];
    self.currentWaveIndex = index;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![touch.view isKindOfClass:[UIButton class]]) {
        [self hideLikeCommentView];
        [self hideInputToolbar:touch];
    }
    return NO;
}

- (void)hideInputToolbar:(UITouch*)sender {
    CGPoint p = [sender locationInView:self.view];
    if (self.inputToolbar.frame.origin.y > 0 && p.y <= self.inputToolbar.realFrame.origin.y) {
        [self.inputToolbar resignFirstResponder];
    }
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CCNewWaveViewController class]]) {
        CCNewWaveViewController* nvc = (CCNewWaveViewController*)segue.destinationViewController;
        nvc.assets = self.assets;
        nvc.delegate = self;
    }
    if ([segue.destinationViewController isKindOfClass:[CCDetailViewController class]]) {
        CCDetailViewController* vc = (CCDetailViewController*)segue.destinationViewController;
        CCFeedModel* model = (CCFeedModel*)sender;
        vc.feedId = model.feedId;
    }
    if ([segue.destinationViewController isKindOfClass:[CCUserFeedsViewController class]]) {
        CCUserFeedsViewController* vc = (CCUserFeedsViewController*)segue.destinationViewController;
        CCFeedModel* model = (CCFeedModel*)sender;
        vc.userId = model.senderId;
        vc.systemSender = model.systemSender;
    }
    if ([segue.destinationViewController isKindOfClass:[CCMyCommentViewController class]]) {
        CCMyCommentViewController* vc = (CCMyCommentViewController*)segue.destinationViewController;
        vc.commentIds = self.dataSource.myCommentModel.commentIds;
    }
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = segue.destinationViewController;
        HHLinkWaveTableViewController *linkWave = [nav.viewControllers firstObject];
        linkWave.block = ^(CCFeedModel* model){
            [self.feeds insertObject:model atIndex:0];
            [self.tableView reloadData];
        };
    }
}

- (void)sendWave:(NSString *)text pictures:(NSArray *)pics success:(void (^)())success failure:(void (^)())failure{
    
    if (self.assets && self.assets.count != 0) {
        [self.assets removeAllObjects];
    }
    [self.dataSource sendWaveWithText:text pictures:pics success:^(CCFeedModel* model){
        [self.feeds insertObject:model atIndex:0];
        [self.tableView reloadData];
        success();
    } failure:^{
        failure();
    }];
}

- (void)dismissAction
{
    if (self.assets) {
        [self.assets removeAllObjects];
    }
}

#pragma mark PullProgressView
- (void)showPullProgressView {
    [self.navigationBar addSubview:self.progressView];
}

- (void)hidePullProgressView {
    [self.progressView removeFromSuperview];
}

- (HHPullProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[HHPullProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2 + 20, 32, 20, 20)];
    }
    return _progressView;
}

#pragma mark InputToolbarDelegate
- (void)sendTextAction:(NSString *)inputText {
    CCFeedModel* model = self.feeds[self.currentWaveIndex];
    [self.view showHudWithText:@"正在发送评论..." indicator:YES];
    [self.dataSource sendComment:inputText waveId:model.feedId to:self.currentCommentToId success:^(CCFeedComment* comment){
        model.commentCountModel.commentCount +=1;
        self.currentCommentToId = 0;
        NSMutableArray* arr = [NSMutableArray arrayWithArray:model.firstPageComments];
        [arr insertObject:comment atIndex:0];
        model.firstPageComments = [arr copy];
        
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:(self.currentWaveIndex)];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.inputToolbar resignFirstResponder];
        [self.view showHudWithText:@"评论成功" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    } failure:^{
        [self.view showHudWithText:@"评论失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

#pragma mark HeaderViewDelegate
- (void)headerView:(CCMainHeaderView *)headerView didTapOnUnread:(UIButton *)sender {
    [self didReadMyComment:nil];
    [self performSegueWithIdentifier:@"Main2MyComment" sender:self];
}

- (void)headerView:(CCMainHeaderView *)headerView didTapOnAvatar:(HHAvatarImageView *)avataView {
    CCFeedModel* model = [CCFeedModel new];
    model.senderId = [CCUserInfoProvider sharedProvider].uid;
    [self performSegueWithIdentifier:@"Main2UserFeeds" sender:model];
}

#pragma mark Notifications
- (void)didUnlike:(NSNotification*)sender {
    CCFeedComment* comment = sender.userInfo[@"object"];
    [self.feeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCFeedModel* model = (CCFeedModel*)obj;
        if (model.feedId == comment.feedId) {
            *stop = YES;
            model.commentCountModel.likedId = 0;
            model.commentCountModel.likeCount-=1;
            
            CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]];
            cell.model = model;
        }
    }];
}

- (void)didAddComment:(NSNotification*)sender {
    CCFeedComment* comment = sender.userInfo[@"object"];
    [self.feeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCFeedModel* model = (CCFeedModel*)obj;
        if (model.feedId == comment.feedId) {
            *stop = YES;
            if (comment.type == PBWaveCommentTypeTypeComment) {
                model.commentCountModel.commentCount+=1;
                
                NSMutableArray* arr = [NSMutableArray arrayWithArray:model.firstPageComments];
                [arr insertObject:comment atIndex:0];
                model.firstPageComments = [arr copy];
                
                NSIndexSet* set = [NSIndexSet indexSetWithIndex:idx];
                [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
            } else {
                model.commentCountModel.likedId = comment.commentId;
                model.commentCountModel.likeCount+=1;
                
                CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]];
                cell.model = model;
            }
        }
    }];
}

- (void)didDeleteComment:(NSNotification*)sender {
    CCFeedComment* comment = sender.userInfo[@"object"];
    [self.feeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCFeedModel* model = (CCFeedModel*)obj;
        if (model.feedId == comment.feedId) {
            *stop = YES;
            model.commentCountModel.commentCount-=1;
            
            NSMutableArray* arr = [NSMutableArray arrayWithArray:model.firstPageComments];
            [arr removeObject:comment];
            model.firstPageComments = [arr copy];
            
            NSIndexSet* set = [NSIndexSet indexSetWithIndex:idx];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)didDeleteWave:(NSNotification*)sender {
    int64_t waveId = [sender.userInfo[@"object"] longLongValue];
    [self.feeds filterUsingPredicate:[NSPredicate predicateWithFormat:@"feedId != %lld", waveId]];
    [self.tableView reloadData];
}

- (void)didSendWave:(NSNotification*)sender {
    CCFeedModel* wave = sender.userInfo[@"object"];
    [self.feeds insertObject:wave atIndex:0];
    [self.tableView reloadData];
}

- (void)didReadMyComment:(NSNotification*)sender {
    self.dataSource.myCommentModel.commentIds = [NSArray array];
    self.headerView.unreadCount = 0;
}


#pragma mark Dealloc
- (void)dealloc {
    [self uninstallNotifications];
    [self.headerView detatchWithScrollView:self.tableView];
}

#pragma mark - HHEditViewDelegate

- (IBAction)sendNewWaveAction:(id)sender
{
        if (!BaseIOS8) {
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",@"链接", nil];
            sheet.tintColor = [UIColor colorFromHexCode:@"06bf04"];
            [sheet showInView:self.view];
        } else {
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            ac.view.tintColor = [UIColor colorFromHexCode:@"06bf04"];
//            ac.view.tintColor = [UIColor colorFromHexCode:@"68c500"];
            [ac addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self actionSheet:nil clickedButtonAtIndex:0];
            }]];
            [ac addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self actionSheet:nil clickedButtonAtIndex:1];
            }]];
            [ac addAction:[UIAlertAction actionWithTitle:@"链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self actionSheet:nil clickedButtonAtIndex:2];
            }]];
            [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [ac dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:ac animated:YES completion:nil];
        }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:[UIColor colorFromHexCode:@"06bf04"] forState:UIControlStateNormal];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self pickImageFromCamera];
            break;
        case 1:{
            [self pickImageFromLibrary];
        }
            break;
        case 2:{
            [self performSegueWithIdentifier:@"LinkWaveIdentifier" sender:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)pickImageFromLibrary {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allAssets];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.sendButtonTitle = @"确定";
    [self presentViewController:picker animated:YES completion:nil];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset {
    if (picker.selectedAssets.count + self.assets.count == kMaxImageCount) {
        [picker.view showHudWithText:[NSString stringWithFormat:@"最多只能选择%ld张图片", (long)kMaxImageCount] indicator:NO];
        [picker.view hideHudAfterDelay:.8];
    }
    return picker.selectedAssets.count + self.assets.count != kMaxImageCount;
    return YES;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset* asset = (ALAsset*)obj;
        CCImage* ci = [CCImage new];
        ci.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        ci.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [self.assets addObject:ci];
    }];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"newWaveIdentifier" sender:self.assets];
    }];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)pickImageFromCamera {
    UIImagePickerController* pickerImage = [[UIImagePickerController alloc] init];
    [pickerImage setDelegate:self];
    pickerImage.allowsEditing = NO;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerImage.mediaTypes = @[(NSString*)kUTTypeImage];
    } else {
        NSLog(@"Can not access photo library");
    }
    [self presentViewController:pickerImage animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        CCImage* ci = [CCImage new];
        ci.thumbnail = image;
        ci.image = image;
        [self.assets addObject:ci];
    }
    [picker dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"newWaveIdentifier" sender:self.assets];
    }];
}


//- (void)sendNewWave
//{
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"circle" bundle:nil];
//    CCNewWaveViewController *newWaveCtrl = [sb instantiateViewControllerWithIdentifier:@"NewWaveID"];
//    [self.navigationController presentViewController:newWaveCtrl animated:YES completion:^{
//        [self.navigationController setNavigationBarHidden:NO animated:NO];
//        self.editView.hidden = YES;
//    }];
//}

//- (HHBJDateHomeClient *)dateClient
//{
//    if (!_dateClient) {
//        _dateClient = [[HHBJDateHomeClient alloc]init];
//    }
//    return _dateClient;
//}

//- (void)loadDateData
//{
//    [self.dateClient eventsOfPark:0 keyWord:nil success:^(NSArray *events) {
//        self.dateDatas = events;
//        if (self.dateDatas && self.dateDatas.count != 0) {
//            NSString *evnetId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewEventID"];
//            Event *event = self.dateDatas[0];
//            if (event.id <= [evnetId integerValue]) {
//                self.headerView.isHasNewDate = NO;
//            }else{
//                self.headerView.isHasNewDate = YES;
//            }
//        }
//    } failure:^(NSString *error) {
//        
//    }];
//}

@end
