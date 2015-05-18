//
//  HHPreViewController.m
//  HChat
//
//  Created by Wong on 14-10-22.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHPreViewController.h"

@interface HHPreViewController () <UIScrollViewDelegate>

@property (retain, nonatomic) UIView *navBarView;
@property (retain, nonatomic) UIView *toolBarView;
@property (retain, nonatomic) UIButton *backBtn;
@property (retain, nonatomic) UIButton *selectBtn;
@property (retain, nonatomic) UIButton *sendBtn;
@property (retain, nonatomic) UIScrollView *preScrollView;
@property (retain, nonatomic) UILabel *numberLabel;
@property (retain, nonatomic) NSArray *allAlAssets;
@property (retain, nonatomic) NSMutableArray *allBtns;
@property (retain, nonatomic) NSMutableArray *sendAssets;
@property NSInteger index;
@end

@implementation HHPreViewController

- (id)initWithAlAsset:(NSMutableArray *)selectAssets
{
    self = [super init];
    if (self) {
        if (!_allAlAssets) {
            _allAlAssets = [[NSArray alloc]init];
        }
        if (!_sendAssets) {
            _sendAssets = [[NSMutableArray alloc]init];
        }
        _allAlAssets = [selectAssets copy];
        _sendAssets = [NSMutableArray arrayWithArray:selectAssets];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (BaseIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    _allBtns = [[NSMutableArray alloc]init];
    [self initUI];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)initUI
{
    [self.view addSubview:self.preScrollView];
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.toolBarView];
    [self.navBarView addSubview:self.backBtn];
    [self.toolBarView addSubview:self.sendBtn];
    [self.toolBarView addSubview:self.numberLabel];
    [self getAllImages];
    [self setAllBtn];
    [self updateSendBtnTitle];
}

- (UILabel *)numberLabel
{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
        _numberLabel.backgroundColor = [UIColor redColor];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.layer.cornerRadius = CGRectGetHeight(_numberLabel.frame)/2;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_sendAssets.count];
        CGPoint center = CGPointMake(CGRectGetMinX(_sendBtn.frame), CGRectGetMinY(_sendBtn.frame)+6);
        _numberLabel.center = center;
    }
    return _numberLabel;
}

- (UIScrollView *)preScrollView
{
    if (!_preScrollView) {
        if (BaseIOS7) {
            _preScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        }else{
            _preScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -20, kScreen_Width, kScreen_Height)];
        }
        _preScrollView.pagingEnabled = YES;
        _preScrollView.delegate = self;
        _preScrollView.backgroundColor = [UIColor blackColor];
        _preScrollView .showsVerticalScrollIndicator = NO;
        _preScrollView.showsHorizontalScrollIndicator = NO;
        _preScrollView.bounces = NO;
    }
    return _preScrollView;
}

- (void)getAllImages
{
    _preScrollView.contentSize = CGSizeMake(kScreen_Width*_allAlAssets.count, kScreen_Height);
    for (int i = 0; i < _allAlAssets.count; i++) {
        ALAsset *asset = _allAlAssets[i];
        UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImageView *imageView = [[UIImageView alloc]init];
            imageView.frame = CGRectMake(kScreen_Width*i, 44, _preScrollView.frame.size.width, _preScrollView.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGPoint center = CGPointMake(_preScrollView.frame.size.width*i+_preScrollView.frame.size.width/2, _preScrollView.center.y);
        imageView.center = center;
        imageView.image = image;
        [self.preScrollView addSubview:imageView];
    }
}

- (void)setAllBtn
{
    if (_allBtns) {
        [_allBtns removeAllObjects];
    }
    for (int i = 0; i<_allAlAssets.count; i++) {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(kFrame_Width-55, 20, 31, 31);
        selectButton.tag = i;
        selectButton.selected = YES;
        if (i == 0) {
            selectButton.hidden = NO;
        }else{
            selectButton.hidden = YES;
        }
        [selectButton setBackgroundImage:[UIImage imageNamed:@"prePhoto_select"] forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
        [_allBtns addObject:selectButton];
        [self.navBarView addSubview:selectButton];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _index = scrollView.contentOffset.x/kFrame_Width;
    UIButton *button = (UIButton *)[self.navBarView viewWithTag:_index];
    for (UIButton *btn in _allBtns) {
        if (btn.tag == button.tag) {
            btn.hidden = NO;
        }else{
            btn.hidden = YES;
        }
    }
}

- (UIView *)navBarView
{
    if (!_navBarView) {
        if (BaseIOS7) {
            _navBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        }else{
            _navBarView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, CGRectGetWidth(self.view.frame), 64)];
        }
        _navBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    }
    return _navBarView;
}

- (UIView *)toolBarView
{
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-46, CGRectGetWidth(self.view.frame), 46)];
        _toolBarView.backgroundColor = [UIColor colorFromHexCode:@"ebecee"];
    }
    return _toolBarView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 23, 40, 20);
        _backBtn.tag = 100;
        [_backBtn setImage:[UIImage imageNamed:@"prePhoto_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (void)selectClick:(UIButton *)sender
{
    ALAsset *asset = self.allAlAssets[sender.tag];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"prePhoto_select.png"] forState:UIControlStateNormal];
        if (_delegate && [_delegate respondsToSelector:@selector(selectAlAsset: withSelectAllAlAssets:)]) {
            [_delegate selectAlAsset:asset withSelectAllAlAssets:_sendAssets];
        }
        if (![_sendAssets containsObject:asset]) {
            [_sendAssets insertObject:asset atIndex:sender.tag];
        }
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"prePhoto_desSelect.png"] forState:UIControlStateNormal];
        if (_delegate && [_delegate respondsToSelector:@selector(disSelectAlAsset: withDisSelectAllAlAssets:)]) {
            [_delegate disSelectAlAsset:asset withDisSelectAllAlAssets:_sendAssets];
        }
        [_sendAssets removeObject:asset];
    }
    
    [self updateSendBtnTitle];
}

- (void)updateSendBtnTitle
{
    _numberLabel.hidden = YES;
    if (_sendAssets.count != 0) {
        _numberLabel.hidden = NO;
        _numberLabel.text = [NSString stringWithFormat:@"%d",_sendAssets.count];
    }
}

- (void)backClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-51, 8, 45, 30);
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.layer.cornerRadius = 5.0f;
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor colorFromHexCode:@"06bb04"]];
        [_sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (void)sendClick:(id)sender
{
    if (self.sendAssets.count == 0) {
        ALAsset *asset = self.allAlAssets[_index];
        [self.sendAssets addObject:asset];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendSelectAlAssets:)]) {
        [self.delegate sendSelectAlAssets:self.sendAssets];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)_backTitle
{
    return @"返回";
}


@end
