/*
 CTAssetsViewController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsPickerCommon.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsViewController.h"
#import "CTAssetsViewCell.h"
#import "CTAssetsSupplementaryView.h"
#import "CTAssetsPageViewController.h"
#import "CTAssetsViewControllerTransition.h"

#import "HHPreViewController.h"



NSString * const CTAssetsViewCellIdentifier = @"CTAssetsViewCellIdentifier";
NSString * const CTAssetsSupplementaryViewIdentifier = @"CTAssetsSupplementaryViewIdentifier";



@interface CTAssetsPickerController ()

- (void)finishPickingAssets:(id)sender;

- (NSString *)toolbarTitle;
- (UIView *)noAssetsView;

@end



@interface CTAssetsViewController () <HHPreViewDelegate>

@property (nonatomic, weak) CTAssetsPickerController *picker;
@property (nonatomic, strong) NSMutableArray *assets;
@property (retain, nonatomic) UIButton *preBtn;
@property (retain, nonatomic) UIButton *sendBtn;
@property (retain, nonatomic) NSMutableArray *selectAlAssets;
@property (retain, nonatomic) UILabel *numberLabel;

@end





@implementation CTAssetsViewController


- (id)init
{
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:self.interfaceOrientation];
    self.sendButtonTitle = @"发送";
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.collectionView.allowsMultipleSelection = YES;
        
        [self.collectionView registerClass:CTAssetsViewCell.class
                forCellWithReuseIdentifier:CTAssetsViewCellIdentifier];
        
        [self.collectionView registerClass:CTAssetsSupplementaryView.class
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:CTAssetsSupplementaryViewIdentifier];

        if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
            self.preferredContentSize = CTAssetPickerPopoverContentSize;
        }
    }
    
    [self addNotificationObserver];
    [self addGestureRecognizer];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupViews];
    [self setToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupButtons];
    [self setupAssets];
}

- (void)setSendButtonTitle:(NSString *)sendButtonTitle {
    _sendButtonTitle = sendButtonTitle;
    if (sendButtonTitle) {
        [self.sendBtn setTitle:sendButtonTitle forState:UIControlStateNormal];
    }
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Accessors

- (CTAssetsPickerController *)picker
{
    return (CTAssetsPickerController *)self.navigationController.parentViewController;
}


#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:toInterfaceOrientation];
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupButtons
{
    
    UILabel *titleLabel = [UIHelper naviTitleLabelWithTitle:@"相机交卷"];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    [rightButton setTitle:@"取消" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorFromHexCode:@"06bb04"] forState:UIControlStateNormal];
    [rightButton addTarget:self.picker action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self.picker action:@selector(dismiss:)];
//    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"06bb04"]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *button = [UIHelper navLeftButtonWithTitle:@"返回"];
    [button addTarget:self.picker action:@selector(popGroupViewController:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:button];
//    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"06bb04"]} forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = leftItem;
    
//    self.navigationItem.rightBarButtonItem.enabled = (self.picker.selectedAssets.count > 0);
}


- (void)setToolBar
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (!BaseIOS7) {
        screenHeight -= 64;
    }
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight-49, CGRectGetWidth(self.view.frame), 49)];
    baseView.backgroundColor = [UIColor colorFromHexCode:@"ebecee"];
    baseView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    baseView.layer.borderWidth = 0.5f;
    [self.view addSubview:baseView];
    
    _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _preBtn.frame = CGRectMake(6, 10, 45, 30);
    _preBtn.layer.masksToBounds = YES;
    _preBtn.layer.cornerRadius = 5.0f;
    [_preBtn setTitle:@"预览" forState:UIControlStateNormal];
    _preBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_preBtn setBackgroundColor:[UIColor colorFromHexCode:@"f6f6f6"]];
    [_preBtn setTitleColor:[UIColor colorFromHexCode:@"cecece"] forState:UIControlStateNormal];
    [_preBtn addTarget:self action:@selector(preViewClick:) forControlEvents:UIControlEventTouchUpInside];
    _preBtn.enabled = NO;
    [baseView addSubview:_preBtn];
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-51, 10, 45, 30);
    [_sendBtn setTitle:self.sendButtonTitle forState:UIControlStateNormal];
    _sendBtn.layer.masksToBounds = YES;
    _sendBtn.layer.cornerRadius = 5.0f;
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _sendBtn.backgroundColor = [UIColor colorFromHexCode:@"83de82"];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled = NO;
    [baseView addSubview:_sendBtn];
    
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
    _numberLabel.backgroundColor = [UIColor redColor];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.layer.masksToBounds = YES;
    _numberLabel.layer.cornerRadius = CGRectGetHeight(_numberLabel.frame)/2;
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.hidden = YES;
    CGPoint center = CGPointMake(CGRectGetMinX(_sendBtn.frame), CGRectGetMinY(_sendBtn.frame)+6);
    _numberLabel.center = center;
    [baseView addSubview:_numberLabel];
}


#pragma mark - 发送

- (void)sendClick:(UIButton *)sender
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.picker.delegate assetsPickerController:self.picker didFinishPickingAssets:self.selectAlAssets];
        for (int i=0; i< self.selectAlAssets.count ; i++) {
            ALAsset *asset = self.selectAlAssets[i];
            [self disSelectAlAsset:asset withDisSelectAllAlAssets:nil];
        }
    }
}

#pragma mark - 预览

- (void)preViewClick:(id)sender
{
    HHPreViewController *preCtrl = [[HHPreViewController alloc]initWithAlAsset:self.selectAlAssets];
    preCtrl.delegate = self;
    UINavigationController *nav = self.picker.childViewControllers[0];
    [nav pushViewController:preCtrl animated:YES];
}

#pragma mark - HHPreViewDelegate

- (void)selectAlAsset:(ALAsset *)alAsset withSelectAllAlAssets:(NSMutableArray *)alAssets
{
    NSInteger integer = [self.assets indexOfObject:alAsset];
    NSIndexPath *path = [NSIndexPath indexPathForRow:integer inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:path];
    [self.collectionView reloadData];
}

- (void)disSelectAlAsset:(ALAsset *)alAsset withDisSelectAllAlAssets:(NSMutableArray *)alAssets
{
    NSInteger integer = [self.assets indexOfObject:alAsset];
    NSIndexPath *path = [NSIndexPath indexPathForRow:integer inSection:0];
    [self collectionView:self.collectionView didDeselectItemAtIndexPath:path];
    [self.collectionView reloadData];
}

- (void)sendSelectAlAssets:(NSMutableArray *)alAssets
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        for (ALAsset *set in alAssets) {
            [self disSelectAlAsset:set withDisSelectAllAlAssets:alAssets];
        }
        [self.picker.delegate assetsPickerController:self.picker didFinishPickingAssets:alAssets];
    }
}

- (void)setupToolbar
{
//    self.toolbarItems = self.picker.toolbarItems;
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        return;
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop)
    {
        if (asset)
        {
            BOOL shouldShowAsset;
            
            if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldShowAsset:)])
                shouldShowAsset = [self.picker.delegate assetsPickerController:self.picker shouldShowAsset:asset];
            else
                shouldShowAsset = YES;
            
            if (shouldShowAsset)
                [self.assets addObject:asset];
        }
        else
        {
            [self reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}


#pragma mark - Collection View Layout

- (UICollectionViewFlowLayout *)collectionViewFlowLayoutOfOrientation:(UIInterfaceOrientation)orientation
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize             = CTAssetThumbnailSize;
    layout.footerReferenceSize  = CGSizeMake(0, 47.0);
    
    if (UIInterfaceOrientationIsLandscape(orientation) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);
        layout.minimumInteritemSpacing = (CTIPhone6Plus) ? 1.0 : ( (CTIPhone6) ? 2.0 : 3.0 );
        layout.minimumLineSpacing      = (CTIPhone6Plus) ? 1.0 : ( (CTIPhone6) ? 2.0 : 3.0 );
    }
    else
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 0, 0, 0);
        layout.minimumInteritemSpacing = (CTIPhone6Plus) ? 0.5 : ( (CTIPhone6) ? 1.0 : 2.0 );
        layout.minimumLineSpacing      = (CTIPhone6Plus) ? 0.5 : ( (CTIPhone6) ? 1.0 : 2.0 );
    }
    
    return layout;
}


#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(assetsLibraryChanged:)
                   name:ALAssetsLibraryChangedNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:CTAssetsPickerSelectedAssetsChangedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTAssetsPickerSelectedAssetsChangedNotification object:nil];
}


#pragma mark - Assets Library Changed

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    // Reload all assets
    if (notification.userInfo == nil)
        [self performSelectorOnMainThread:@selector(reloadAssets) withObject:nil waitUntilDone:NO];
    
    // Reload effected assets groups
    if (notification.userInfo.count > 0)
        [self reloadAssetsGroupForUserInfo:notification.userInfo];
}


#pragma mark - Reload Assets Group

- (void)reloadAssetsGroupForUserInfo:(NSDictionary *)userInfo
{
    NSSet *URLs = [userInfo objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
    NSURL *URL  = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", URL];
    NSArray *matchedGroups = [URLs.allObjects filteredArrayUsingPredicate:predicate];
    
    // Reload assets if current assets group is updated
    if (matchedGroups.count > 0)
        [self performSelectorOnMainThread:@selector(reloadAssets) withObject:nil waitUntilDone:NO];
}



#pragma mark - Selected Assets Changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
    if (_selectAlAssets) {
        [_selectAlAssets removeAllObjects];
    }
    NSArray *selectedAssets = (NSArray *)notification.object;
    _selectAlAssets = [NSMutableArray arrayWithArray:selectedAssets];
    [self upDataBtnTitle:selectedAssets];
}

- (void)upDataBtnTitle:(NSArray *)arr
{
    [_preBtn setTitleColor:[UIColor colorFromHexCode:@"666666"] forState:UIControlStateNormal];
    _preBtn.backgroundColor = [UIColor colorFromHexCode:@"f6f6f6"];
    [_sendBtn setBackgroundColor:[UIColor colorFromHexCode:@"06bb04"]];
    _sendBtn.enabled = YES;
    _preBtn.enabled = YES;
    _numberLabel.hidden = NO;
    _numberLabel.text = [NSString stringWithFormat:@"%d",arr.count];
    if (arr.count == 0) {
        [_sendBtn setBackgroundColor:[UIColor colorFromHexCode:@"83de82"]];
        [_preBtn setTitleColor:[UIColor colorFromHexCode:@"cecece"] forState:UIControlStateNormal];
        _sendBtn.enabled = NO;
        _preBtn.enabled = NO;
        _numberLabel.hidden = YES;
    }
}


#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pushPageViewController:)];
    
    [self.collectionView addGestureRecognizer:longPress];
}


#pragma mark - Push Assets Page View Controller

- (void)pushPageViewController:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point           = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath  = [self.collectionView indexPathForItemAtPoint:point];

        CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.assets];
        vc.pageIndex = indexPath.item;

        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - Reload Assets

- (void)reloadAssets
{
    self.assets = nil;
    [self setupAssets];
}



#pragma mark - Reload Data

- (void)reloadData
{
    if (self.assets.count > 0)
    {
        [self.collectionView reloadData];
        if ([self respondsToSelector:@selector(collectionViewLayout)]) {
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionViewLayout.collectionViewContentSize.height)];
        }
    }
    else
    {
        [self showNoAssets];
    }
}


#pragma mark - No assets

- (void)showNoAssets
{
    self.collectionView.backgroundView = [self.picker noAssetsView];
    [self setAccessibilityFocus];
}

- (void)setAccessibilityFocus
{
    self.collectionView.isAccessibilityElement  = YES;
    self.collectionView.accessibilityLabel      = self.collectionView.backgroundView.accessibilityLabel;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.collectionView);
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CTAssetsViewCellIdentifier
                                              forIndexPath:indexPath];
    
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        cell.enabled = [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        cell.enabled = YES;
    
    // XXX
    // Setting `selected` property blocks further deselection.
    // Have to call selectItemAtIndexPath too. ( ref: http://stackoverflow.com/a/17812116/1648333 )
    if ([self.picker.selectedAssets containsObject:asset])
    {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [cell bind:asset];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    CTAssetsSupplementaryView *view =
//    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//                                       withReuseIdentifier:CTAssetsSupplementaryViewIdentifier
//                                              forIndexPath:indexPath];
//    
//    [view bind:self.assets];
//    
//    if (self.assets.count == 0)
//        view.hidden = YES;
//    
//    return view;
//}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    CTAssetsViewCell *cell = (CTAssetsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.isEnabled)
        return NO;
    else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if (self.picker) {
        [self.picker selectAsset:asset];
    }
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)]){
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    if (self.picker) {
        [self.picker deselectAsset:asset];
    }
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)]){
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}


@end