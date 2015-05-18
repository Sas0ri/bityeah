//
//  CCNewWaveViewController.m
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCNewWaveViewController.h"
#import "CPTextViewPlaceholder.h"
#import "CCNewWaveImageCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTAssetsPickerController.h"
#import "UIView+MBProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LXActionSheet.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define kMaxLength 140

@interface CCNewWaveViewController() <UICollectionViewDataSource, UICollectionViewDelegate, CTAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LXActionSheetDelegate, CCNewWaveImageCellDelegate, UIAlertViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *leftCountLabel;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)dismissAction:(id)sender;
- (IBAction)sendAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *leftImageCountLabel;
@end

@implementation CCNewWaveViewController

static NSInteger kMaxImageCount = 9;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect r = self.navigationBar.frame;
    r.size.height = 64;
    self.navigationBar.frame = r;
    
    self.textView.placeholder = @"说点什么吧";
    self.textView.delegate = self;
    
    UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tg.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tg];
    
    r = self.sepLine.frame;
    r.size.height = 0.5;
    r.size.width = self.view.bounds.size.width - 14;
    self.sepLine.frame = r;
    
    self.sendButton.enabled = NO;
}

- (NSMutableArray *)assets
{
    if (!_assets) {
        _assets = [[NSMutableArray alloc]init];
    }
    return _assets;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)tapAction:(UITapGestureRecognizer*)sender {
    CGPoint p = [sender locationInView:self.view];
    if (p.y > CGRectGetMaxY(self.collectionView.frame) && self.isEditing) {
        [self setEditing:NO];
        [self.collectionView reloadData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.assets.count == 0) {
        return 1;
    }
    if (self.assets.count > 0 && self.assets.count < kMaxImageCount) {
        return self.assets.count + 2;
    }
    return self.assets.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCNewWaveImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Image" forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.row < self.assets.count) {
        CCImage* ci = self.assets[indexPath.row];
        cell.imageView.image = ci.thumbnail;
        cell.deleteButton.hidden = self.isEditing ? NO : YES;
    } else if (self.assets.count < kMaxImageCount && indexPath.row == self.assets.count){
        cell.imageView.image = [UIImage imageNamed:@"addimage"];
        cell.deleteButton.hidden = YES;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"deleteimage"];
        cell.deleteButton.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.assets.count <= kMaxImageCount) {
        if (indexPath.row == self.assets.count + 1) {
            [self setEditing:!self.isEditing];
            [self.collectionView reloadData];
        } else if (indexPath.row < self.assets.count){
            [self showPhotoBrowserWithIndex:indexPath.row];
        }
    }

    if (indexPath.row == self.assets.count) {
        if (self.assets.count == kMaxImageCount) {
            [self setEditing:!self.isEditing];
            [self.collectionView reloadData];
        } else {
            [self pickImage];
        }
    }
}

- (void)showPhotoBrowserWithIndex:(NSInteger)index {
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i<self.assets.count; i++) {
        CCImage* ci = self.assets[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        CCNewWaveImageCell* cell = (CCNewWaveImageCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        photo.srcImageView = cell.imageView; // 来源于哪个UIImageView
        photo.image = ci.image;
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser showInController:self];
}

- (void)deleteCell:(CCNewWaveImageCell *)cell {
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
    [self.assets removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
    [self updateView];
    if (self.assets.count == 0) {
        [self setEditing:NO];
    }
}

- (void)pickImage {
    [self.textView resignFirstResponder];
    LXActionSheet* as = [[LXActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从手机相册选择"]];
    [as showInView:self.view];
}

- (void)actionSheet:(LXActionSheet *)actionSheet didClickOnButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self pickImageFromCamera];
    }
    if (buttonIndex == 1) {
        [self pickImageFromLibrary];
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
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset* asset = (ALAsset*)obj;
        CCImage* ci = [CCImage new];
        ci.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        ci.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [self.assets addObject:ci];
    }];
    [self.collectionView reloadData];
    [self updateView];
    [picker dismissViewControllerAnimated:YES completion:^{
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        CCImage* ci = [CCImage new];
        ci.thumbnail = image;
        ci.image = image;
        [self.assets addObject:ci];
    }
    [self updateView];
}

- (IBAction)dismissAction:(id)sender {
    [self.textView resignFirstResponder];
    if (self.textView.text.length > 0 || self.assets.count > 0) {
        [self presentDismissAlert];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(dismissAction)]) {
            [_delegate dismissAction];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentDismissAlert {
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"退出此次编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"退出此次编辑？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (_delegate && [_delegate respondsToSelector:@selector(dismissAction)]) {
                [_delegate dismissAction];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(dismissAction)]) {
            [_delegate dismissAction];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)sendAction:(id)sender {
    if (self.textView.text.length > kMaxLength) {
        [self.view showHudWithText:[NSString stringWithFormat:@"不能超过%d个字",kMaxLength] indicator:NO];
        [self.view hideHudAfterDelay:0.8];
        return;
    }
    
    NSMutableArray* images = [NSMutableArray array];
    for (CCImage* asset in self.assets) {
        [images addObject:asset.image];
    }
    [self.view showHudWithText:@"正在发送..." indicator:YES];
    [self.delegate sendWave:self.textView.text pictures:images success:^{
        [self.view hideHud];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } failure:^{
        [self.view showHudWithText:@"发送失败" indicator:NO];
        [self.view hideHudAfterDelay:.8];
    }];
}

#pragma mark UITextViewDelegate

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if (textView.text.length+text.length > 100) {
//        return NO;
//    }
//    return YES;
//}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger leftCount = kMaxLength - (NSInteger)textView.text.length;
    self.leftCountLabel.text = [NSString stringWithFormat:@"%@", @(leftCount)];
    [self updateView];
}

- (void)updateView {
    self.sendButton.enabled = self.assets.count > 0 || self.textView.text.length > 0;
    if (self.leftCountLabel.text.integerValue > 0) {
        self.leftCountLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.leftCountLabel.textColor = [UIColor redColor];
    }
    self.leftImageCountLabel.text = [NSString stringWithFormat:@"%@", @(kMaxImageCount-self.assets.count)];
//    CGRect r = self.leftImageCountLabel.frame;
//    r.origin.y = self.assets.count > 1 ? 313 : 240;
//    self.leftImageCountLabel.frame = r;
}

@end


@implementation CCImage


@end