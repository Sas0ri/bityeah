//
//  CCDetailViewController.m
//  testCircle
//
//  Created by Sasori on 14/12/10.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCDetailViewController.h"
#import "CCShareLinkViewController.h"
#import "CCDetailLikeCell.h"
#import "CCDetailCommentCell.h"
#import "CCPersonalFeedCell.h"
#import "CCFeedModel.h"
#import "CCDetailDataSource.h"
#import "UIView+MBProgressView.h"
#import "TQRichTextUserNameRun.h"
#import "CCLoadMoreCell.h"
#import "LXActionSheet.h"
#import "CCFaceToolBar.h"
#import "CCLikeCommentView.h"
#import "CCFeedPicture.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CCURLDefine.h"
#import "CCFeedImageCell.h"
#import "CCNotification.h"
#import "CCUserFeedsViewController.h"
#import "UIHelper.h"
#import "HHRefreshTableHeaderView.h"
#import "CCLinkTableViewCell.h"
#import "CCNoTypeCell.h"
#import "CCUserLinkTableCell.h"
#import "CCTransModel.h"

#define kActionDeleteCommentTag 1241241
#define kActionDeleteWaveTag    1241242

NS_ENUM(int, LoadingStatus) {
    LoadingStatusNone,
    LoadingStatusUpdating,
    LoadingStatusLoadingMore,
};

@interface CCDetailViewController () <UITableViewDataSource, UITableViewDelegate, CCFeedCellDelegate, LXActionSheetDelegate, UIGestureRecognizerDelegate, CCLikeCommentViewDelegate, CCFaceToolBarDelegate, EGORefreshTableDelegate, CCLinkCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CCDetailDataSource* dataSource;
@property (nonatomic, assign) enum LoadingStatus loadingStatus;

@property (nonatomic, assign) NSInteger currentCommentIndex;
@property (nonatomic, assign) int64_t currentCommentToId;
@property (nonatomic, strong) NSIndexPath* currentDeleteCommentIndex;
@property (nonatomic, strong) CCLikeCommentView* likeCommentView;
@property (nonatomic, strong) CCFaceToolBar* inputToolbar;
@property (nonatomic, strong) HHRefreshTableHeaderView* headerView;
@property (nonatomic, strong) NSArray* textCopyItems;
@property (nonatomic, strong) NSArray *imageCopyItems;
@property (nonatomic, strong) NSIndexPath *selectPath;

//@property (nonatomic, assign) BOOL expanded;

@end

@implementation CCDetailViewController

static const CGFloat kLikeCommentViewWidth = 180;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.tableView.frame;
    rect.size.width = kFrame_Width;
    rect.size.height = kFrame_Height;
    self.tableView.frame = rect;
    
    self.dataSource = [[CCDetailDataSource alloc] init];
    self.dataSource.waveId = self.feedId;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.inputToolbar = [[CCFaceToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.bounds.size.height - toolBarHeight,self.view.frame.size.width,toolBarHeight) superView:self.view];
    self.inputToolbar.faceBarDelegate = self;
    
    UINib* nib = [UINib nibWithNibName:@"CCLoadMoreCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LoadMore"];
    self.tableView.tableFooterView = [UIView new];
    
    nib = [UINib nibWithNibName:@"CCLinkTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"linkCell"];
    
    nib = [UINib nibWithNibName:@"CCUserLinkTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"userLinkCell"];
    
    nib = [UINib nibWithNibName:@"CCLikeCommentView" bundle:nil];
    self.likeCommentView = [[nib instantiateWithOwner:nil options:nil] lastObject];
    self.likeCommentView.clipsToBounds = YES;
    self.likeCommentView.delegate = self;
    
    UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] init];
    tg.delegate = self;
    [self.view addGestureRecognizer:tg];
}

- (NSArray *)textCopyItems
{
    if (_textCopyItems == nil) {
        UIMenuItem* item = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyToPaste:)];
        UIMenuItem *transmitItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(transmitToPaste:)];
        _textCopyItems = @[item, transmitItem];
    }
    return _textCopyItems;
}

- (void)copyToPaste:(id)sender
{
    UIPasteboard* p  = [UIPasteboard generalPasteboard];
    p.string = [CCTransModel share].content;
}

//- (void)transmitToPaste:(id)sender
//{
//    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    HHTransmitTableViewController* vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"SendImageIdentifiyID"];
//    vc1.fromType = HHTransFromType_Circle;
//    [self.navigationController pushViewController:vc1 animated:YES];
//}

- (NSArray *)imageCopyItems
{
    if (!_imageCopyItems) {
        UIMenuItem *saveItem = [[UIMenuItem alloc]initWithTitle:@"保存" action:@selector(saveImageToPhotoAlbum:)];
        UIMenuItem *transmitItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(imageTransmitToPaste:)];
        _imageCopyItems = @[saveItem,transmitItem];
    }
    return _imageCopyItems;
}

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
//    [CCTransModel share].circleSendImage = cell.pressImage;
//    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    HHTransmitTableViewController* vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"SendImageIdentifiyID"];
//    vc1.fromType = HHTransFromType_Circle;
//    [self.navigationController pushViewController:vc1 animated:YES];
//}


- (void)setupHeader {
    if (self.headerView) {
        return;
    }
    HHRefreshTableHeaderView* headerView = [[HHRefreshTableHeaderView alloc] initWithFrame:
                                            CGRectMake(0.0f, - self.tableView.frame.size.height,
                                                       self.tableView.frame.size.width, self.tableView.frame.size.height)];
    headerView.delegate = self;
    [self.tableView addSubview:headerView];
    self.headerView = headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    
    self.inputToolbar.shouldChangeFrame = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:HHToolbarFrameWillChange object:nil];
    
    if (self.dataSource.feedModel) {
        return;
    }
    [self.view showHudWithText:@"正在加载..." indicator:YES];
    [self.dataSource getWaveSuccess:^(CCFeedModel *m) {
        [self setupDeleteButton];
        [self.view hideHud];
        [self.tableView reloadData];
        [self.view showHudWithText:@"正在加载..." indicator:YES];
        self.loadingStatus = LoadingStatusUpdating;
        [self.dataSource updateCommentsSuccess:^{
            [self.view hideHud];
            self.loadingStatus = LoadingStatusNone;
            [self.tableView reloadData];
        } failure:^{
            self.loadingStatus = LoadingStatusNone;
            [self.view showHudWithText:@"加载失败" indicator:NO];
            [self.view hideHudAfterDelay:.8];
        }];
    } failure:^{
        [self setupDeleteButton];
        [self.view showHudWithText:@"加载失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupHeader];
}

- (void)setupDeleteButton {
    if (self.dataSource.feedModel.senderId == [[CCUserInfoProvider sharedProvider] uid]) {
        UIButton* button = [UIHelper navRightButtonWithIconNormal:[UIImage imageNamed:@"circle_detail_delete"] iconHighlighted:[UIImage imageNamed:@"circle_detail_delete"]];
        [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputToolbar resignFirstResponder];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.inputToolbar.shouldChangeFrame = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HHToolbarFrameWillChange object:self];
}

-(void)keyboardFrameWillChange:(id)sender
{
    NSNotification* notification = (NSNotification*)sender;
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//更改后的键盘
    
    CGRect keyboardRect = [aValue CGRectValue];
    BOOL keyboardIsVisible = keyboardRect.origin.y > 0;
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
    if (self.tableView.contentSize.height < self.view.bounds.size.height) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.tableView.frame = CGRectMake(0, 0, r1.size.width, keyboardRect.origin.y);
        }];
        if (keyboardIsVisible && self.tableView.contentSize.height - keyboardRect.origin.y > 0) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - keyboardRect.origin.y  - self.tableView.contentInset.top) animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
        }
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            self.tableView.frame = CGRectMake(0,  0, r1.size.width, keyboardRect.origin.y);
        } completion:^(BOOL finished) {
            if (keyboardRect.origin.y < self.view.bounds.size.height - toolBarHeight) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentCommentIndex inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }];
    }
}

- (void)endLoading {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;
    switch (section) {
        case 0:
            result = 1;
            break;
        case 1:
            result = self.dataSource.likeComments.count > 0 ? 1 : 0;
            break;
        case 2:
            result = self.dataSource.comments.count;
            break;
        case 3:
            result = self.dataSource.hasMore ? 1:0;
        default:
            break;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (self.dataSource.feedModel.type == PBWaveTypeTypeActivity) {
                return 145.0f;
            }
            if (self.dataSource.feedModel.type == PBWaveTypeTypeNil) {
                return [CCNoTypeCell heightForModel:self.dataSource.feedModel forWidth:tableView.bounds.size.width];
            }
            if (self.dataSource.feedModel.type == PBWaveTypeTypeLink) {
                return [CCUserLinkTableCell heightForModel:self.dataSource.feedModel];
            }
            return [CCPersonalFeedCell heightForModel:self.dataSource.feedModel forWidth:tableView.bounds.size.width];
            break;
        case 1:
            //            return [CCDetailLikeCell heightForString:[self parseLikeNames:self.dataSource.likeComments] forWidth:tableView.bounds.size.width expanded:self.expanded] + 8;
            return [CCDetailLikeCell heightForString:[self parseLikeNames:self.dataSource.likeComments] forWidth:tableView.bounds.size.width expanded:YES] + 8;
            break;
        case 2:
        {
            CCFeedComment* comment = self.dataSource.comments[indexPath.row];
            CGFloat height = [CCDetailCommentCell heightForComment:comment.comment forWidth:tableView.bounds.size.width];
            if (self.dataSource.likeComments.count == 0 && indexPath.row == 0) {
                height += 8;
            }
            return height;
        }
            break;
        case 3:
            return 44;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            if (self.dataSource.feedModel.type == PBWaveTypeTypeActivity) {
                CCLinkTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"linkCell"];
                c.userInfoProvider = [CCUserInfoProvider sharedProvider];
                c.model = self.dataSource.feedModel;
                c.delegate = self;
                c.linkDelegate = self;
                c.isFromDetail = YES;
                cell = c;
            } else if (self.dataSource.feedModel.type == PBWaveTypeTypeNil) {
                CCNoTypeCell* c = [tableView dequeueReusableCellWithIdentifier:@"NoType"];
                c.selectionStyle = UITableViewCellSelectionStyleNone;
                c.userInfoProvider = [CCUserInfoProvider sharedProvider];
                c.model = self.dataSource.feedModel;
                c.delegate = self;
                cell = c;
            }else if (self.dataSource.feedModel.type == PBWaveTypeTypeLink){
                CCLinkTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"userLinkCell"];
                c.userInfoProvider = [CCUserInfoProvider sharedProvider];
                c.model = self.dataSource.feedModel;
                c.delegate = self;
                c.linkDelegate = self;
                c.isFromDetail = YES;
                cell = c;
            }else {
                CCPersonalFeedCell* c = [tableView dequeueReusableCellWithIdentifier:@"Personal"];
                c.selectionStyle = UITableViewCellSelectionStyleNone;
                c.userInfoProvider = [CCUserInfoProvider sharedProvider];
                c.model = self.dataSource.feedModel;
                c.delegate = self;
                cell = c;
            }
        }
            break;
        case 1:
        {
            CCDetailLikeCell* c = [tableView dequeueReusableCellWithIdentifier:@"Like"];
            //            c.expanded = self.expanded;
            c.expanded = YES;
            c.content = [self parseLikeNames:self.dataSource.likeComments];
            c.delegate = self;
            cell = c;
        }
            break;
        case 2:
        {
            CCDetailCommentCell* c = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
            c.userInfoProvider = [CCUserInfoProvider sharedProvider];
            c.comment = self.dataSource.comments[indexPath.row];
            c.delegate = self;
            cell = c;
            
        }
            break;
        case 3:
        {
            CCLoadMoreCell* c = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
            cell = c;
        }
            break;
        default:
            break;
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row != self.dataSource.comments.count) {
        [self commentToIndexPath:indexPath];
    }
    //    if (indexPath.section == 1) {
    //        self.expanded = !self.expanded;
    //        [self.tableView reloadData];
    //    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //显示喜欢第一行的喜欢icon
    if (indexPath.section == 1) {
        CCDetailLikeCell* c = (CCDetailLikeCell*)cell;
        [c showSepLine:self.dataSource.comments.count > 0];
    }
    //显示评论第一行的评论icon
    if (indexPath.section == 2) {
        if (self.dataSource.likeComments.count > 0 || indexPath.row > 0) {
            CCDetailCommentCell* c = (CCDetailCommentCell*)cell;
            [c hideArrow:YES];
        } else {
            CCDetailCommentCell* c = (CCDetailCommentCell*)cell;
            [c hideArrow:NO];
        }
        CCDetailCommentCell* c = (CCDetailCommentCell*)cell;
        [c setCommentIconHidden:indexPath.row != 0];
        [c showSepLine:indexPath.row < self.dataSource.comments.count-1];
        
    }
    if (indexPath.section == 3) {
        CCLoadMoreCell* c = (CCLoadMoreCell*)cell;
        c.hasMore = self.dataSource.hasMore;
        if (c.hasMore && self.loadingStatus != LoadingStatusLoadingMore) {
            [self.dataSource loadMoreCommentsSuccess:^{
                [self performSelector:@selector(endLoading) withObject:nil afterDelay:.1];
            } failure:^{
                
            }];
        }
    }
}

- (NSString*)parseLikeNames:(NSArray*)comments {
    NSMutableArray* arr = [NSMutableArray array];
    [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCFeedComment* comment = (CCFeedComment*)obj;
        NSString* string = [TQRichTextUserNameRun runTextWihtUid:comment.authorId];
        [arr addObject:string];
    }];
    NSString* result = [arr componentsJoinedByString:@"，"];
    return result;
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

- (void)linkBaseViewTap:(CCLinkTableViewCell *)cell
{
//    if (cell.model.type == PBWaveTypeTypeActivity) {
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BJDate" bundle:nil];
//        HHBJDateDetailTableViewController *detailCtrl = [sb instantiateViewControllerWithIdentifier:@"DateDetailController"];
//        NSString *link = cell.model.link;
//        NSRange range = [link rangeOfString:@"="];
//        if (range.location != NSNotFound) {
//            link = [link substringFromIndex:range.location+1];
//            detailCtrl.eventId = [link integerValue];
//        }
//        [self.navigationController pushViewController:detailCtrl animated:YES];
//    }else
        if (cell.model.type == PBWaveTypeTypeNews || cell.model.type == PBWaveTypeTypeNotice){
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL = cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    } else if (cell.model.type == PBWaveTypeTypeLink) {
        CCShareLinkViewController *linkCtrl = [[CCShareLinkViewController alloc]init];
        linkCtrl.linkURL = cell.model.link;
        [self.navigationController pushViewController:linkCtrl animated:YES];
    }
}

#pragma mark Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self hideLikeCommentView];
    }
    [self.headerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)commentToIndexPath:(NSIndexPath*)indexPath {
    CCFeedComment* comment = self.dataSource.comments[indexPath.row];
    //不是自己发的就回复
    if (comment.authorId != [[CCUserInfoProvider sharedProvider] uid]) {
        self.currentCommentToId = comment.authorId;
        self.currentCommentIndex = indexPath.row;
        NSString* name = [[CCUserInfoProvider sharedProvider] findNameForUid:comment.authorId];
        self.inputToolbar.placeHolder = [NSString stringWithFormat:@"回复：%@",name];
        [self.inputToolbar becomeFirstResponder];
    } else {
        //是自己发的就删除
        LXActionSheet* as = [[LXActionSheet alloc] initWithTitle:@"删除此条评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        as.tag = kActionDeleteCommentTag;
        [as showInView:self.view];
        self.currentDeleteCommentIndex = indexPath;
    }
}

#pragma mark LXActionSheetDelegate
- (void)actionSheetDidClickOnCancelButton:(LXActionSheet *)actionSheet {
    if (actionSheet.tag == kActionDeleteCommentTag) {
        self.currentDeleteCommentIndex = nil;
    }
}

- (void)actionSheet:(LXActionSheet *)actionSheet didClickOnButtonIndex:(NSInteger )buttonIndex {
    
}

- (void)actionSheetDidClickOnDestructiveButton:(LXActionSheet *)actionSheet {
    if (actionSheet.tag == kActionDeleteCommentTag) {
        CCFeedComment* comment = self.dataSource.comments[self.currentDeleteCommentIndex.row];
        [self.view showHudWithText:@"正在删除..." indicator:YES];
        [self.dataSource deleteCommentWithId:comment.commentId waveId:comment.feedId type:PBWaveCommentTypeTypeComment success:^{
            [self.view showHudWithText:@"删除成功" indicator:NO];
            [self.view hideHudAfterDelay:.8];
            [self.dataSource.comments removeObject:comment];
            
            CCFeedModel* model = self.dataSource.feedModel;
            model.commentCountModel.commentCount -=1;
            
            CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.model = model;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CCDeleteCommentNotification object:self userInfo:@{@"object":comment}];
            
            [self.tableView reloadData];
        } failure:^{
            [self.view showHudWithText:@"删除失败" indicator:NO];
            [self.view hideHudAfterDelay:.8];
        }];
    }
    if (actionSheet.tag == kActionDeleteWaveTag) {
        [self.view showHudWithText:@"正在删除..." indicator:YES];
        [self.dataSource deleteWaveSuccess:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CCDeleteWaveNotification object:self userInfo:@{@"object":@(self.dataSource.waveId)}];
            [self.view showHudWithText:@"删除成功" indicator:NO];
            [self.view hideHudAfterDelay:.8];
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:.8];
        } failure:^{
            [self.view showHudWithText:@"删除失败" indicator:NO];
            [self.view hideHudAfterDelay:.8];
        }];
    }
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
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
    CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    
}

- (void)cell:(CCPersonalFeedCell *)cell didSelectImageAtIndex:(NSInteger)index {
    CCFeedModel* model = self.dataSource.feedModel;
    
    NSInteger count = model.pictures.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        CCFeedPicture* fp = model.pictures[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[CCURLDefine HDPath:fp.relativeURLString]]; // 图片路径
        photo.srcImageView = ((CCFeedImageCell*)[cell.imagesView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]).imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser showInController:self];
}

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
    CCFeedModel* model = self.dataSource.feedModel;
    [self.view showHudWithText:@"正在点赞..." indicator:YES];
    [self.dataSource likeWithWaveId:model.feedId success:^(CCFeedComment* comment){
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNewCommentNotification object:self userInfo:@{@"object":comment}];
        
        model.commentCountModel.likedId = comment.commentId;
        model.commentCountModel.likeCount += 1;
        CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.model = model;
        
        self.likeCommentView.hasLiked = !self.likeCommentView.hasLiked;
        
        [self.dataSource.likeComments insertObject:comment atIndex:0];
        
        [self.tableView reloadData];
        
        [self.view hideHud];
    } failure:^{
        [self.view showHudWithText:@"点赞失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)unlikeAtIndex:(NSInteger)index {
    [self hideLikeCommentView];
    CCFeedModel* model = self.dataSource.feedModel;
    [self.view showHudWithText:@"正在取消赞..." indicator:YES];
    int64_t commentId = self.dataSource.feedModel.commentCountModel.likedId;
    [self.dataSource deleteCommentWithId:commentId waveId:model.feedId type:PBWaveCommentTypeTypeLike success:^{
        CCFeedComment* c = [CCFeedComment new];
        c.feedId = self.feedId;
        c.authorId = [[CCUserInfoProvider sharedProvider] uid];
        c.type = PBWaveCommentTypeTypeLike;
        c.commentId = commentId;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CCUnlikeWaveNotification object:self userInfo:@{@"object":c}];
        
        model.commentCountModel.likedId = 0;
        model.commentCountModel.likeCount -= 1;
        CCPersonalFeedCell* cell = (CCPersonalFeedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
        cell.model = model;
        [cell layoutIfNeeded];
        
        self.likeCommentView.hasLiked = !self.likeCommentView.hasLiked;
        
        [self.dataSource.likeComments removeObject:c];
        [self.tableView reloadData];
        
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
    self.currentCommentIndex = index;
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

#pragma mark InputToolbarDelegate
- (void)sendTextAction:(NSString *)inputText {
    CCFeedModel* model = self.dataSource.feedModel;
    [self.view showHudWithText:@"正在发送评论..." indicator:YES];
    [self.dataSource sendComment:inputText waveId:model.feedId to:self.currentCommentToId success:^(CCFeedComment* comment){
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNewCommentNotification object:self userInfo:@{@"object":comment}];
        self.currentCommentToId = 0;
        model.commentCountModel.commentCount+=1;
        [self.dataSource.comments insertObject:comment atIndex:0];
        [self.tableView reloadData];
        [self.inputToolbar resignFirstResponder];
        [self.view showHudWithText:@"评论成功" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    } failure:^{
        [self.view showHudWithText:@"评论失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

- (void)cell:(UITableViewCell *)cell didSelectUid:(int64_t)uid {
    if ([cell isKindOfClass:[CCPersonalFeedCell class]]) {
        CCPersonalFeedCell* c = (CCPersonalFeedCell*)cell;
        [self performSegueWithIdentifier:@"Detail2UserFeeds" sender:c.model];
    } else {
        CCFeedModel* model = [CCFeedModel new];
        model.senderId = uid;
        [self performSegueWithIdentifier:@"Detail2UserFeeds" sender:model];
    }
}

- (void)cell:(CCPersonalFeedCell *)cell didSelectURL:(NSString *)URL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
}

#pragma mark DeleteWave
- (void)deleteAction:(id)sender {
    LXActionSheet* as = [[LXActionSheet alloc] initWithTitle:@"删除此条动态" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
    as.tag = kActionDeleteWaveTag;
    [as showInView:self.view];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CCUserFeedsViewController class]]) {
        CCUserFeedsViewController* vc = (CCUserFeedsViewController*)segue.destinationViewController;
        CCFeedModel* model = (CCFeedModel*)sender;
        vc.userId = model.senderId;
        vc.systemSender = model.systemSender;
    }
}

#pragma mark - EGOTableDelegate
- (void)egoRefreshTable:(UIView *)tableView DidTriggerRefresh:(EGORefreshPos)aRefreshPos {
    [self.dataSource getWaveSuccess:^(CCFeedModel *m) {
        [self setupDeleteButton];
        [self.view hideHud];
        [self.tableView reloadData];
        self.loadingStatus = LoadingStatusUpdating;
        [self.dataSource updateCommentsSuccess:^{
            [self.view hideHud];
            self.loadingStatus = LoadingStatusNone;
            [self.tableView reloadData];
            [self.headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        } failure:^{
            self.loadingStatus = LoadingStatusNone;
            [self.view showHudWithText:@"加载失败" indicator:NO];
            [self.view hideHudAfterDelay:.8];
            [self.headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        }];
    } failure:^{
        [self setupDeleteButton];
        [self.view showHudWithText:@"加载失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
        [self.headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view {
    return self.loadingStatus == LoadingStatusUpdating;
}

#pragma mark - dealloc

- (void)dealloc {
    self.tableView.delegate = nil;
}

@end
