//
//  CCShareLinkViewController.m
//  HChat
//
//  Created by Wong on 15/1/30.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCShareLinkViewController.h"
#import "UIView+MBProgressView.h"
#import "CCPubLinkViewController.h"
#import "HHSMShareModel.h"
#import "HHRecentMenu.h"
#import "UIHelper.h"
#import "CCNotification.h"
#import "CCWebParser.h"
#import "NSString+URLEncode.h"

@interface CCShareLinkViewController () <UIWebViewDelegate, HHMenuViewDelegate>

@property (retain, nonatomic) UIWebView *linkWebView;
@property (retain, nonatomic) NSURLRequest *requset;
@property (nonatomic, strong) HHRecentMenu* menu;
@property (nonatomic, strong) UIButton* shareButton;
@property (nonatomic, strong) CCWebParser* webParser;
@property (nonatomic, strong) NSString* linkTitle;
@property (nonatomic, strong) NSString* linkImage;
@end

@implementation CCShareLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.linkWebView];
    
    UIButton* button = [UIHelper navRightButtonWithIconNormal:[UIImage imageNamed:@"circle_detail_delete"] iconHighlighted:[UIImage imageNamed:@"circle_detail_delete"]];
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tintColor = [UIColor colorFromHexCode:@"06bf04"];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    self.shareButton = button;
    
    [self startRequest];
    
    CCWebParser* parser = [CCWebParser new];
    self.webParser = parser;
    [parser loadURL:self.linkURL completion:^(NSString *title, NSString *imageSrc) {
        if (title || imageSrc) {
            self.linkTitle = title;
            self.linkImage = imageSrc;
        } else {

        }
    }];

}

- (void)shareAction:(id)sender {
    if (self.menu.superview != self.view) {
        HHRecentMenu* menuView = nil;
        if (!self.linkTitle && !self.linkImage) {
            menuView = [[HHRecentMenu alloc] initWithTitles:@[@"复制链接"] images:@[] parentView:self.view menuType:0];
            menuView.showSelectIndex = NO;
            menuView.maxHeight = 44;
        } else {
            menuView = [[HHRecentMenu alloc] initWithTitles:@[@"复制链接",@"分享到动态",@"分享到微信朋友圈"/*,@"分享到邮箱",@"分享到短信"*/] images:@[] parentView:self.view menuType:0];
            menuView.maxHeight = 44*3;
            menuView.showSelectIndex = NO;
        }
        CGRect r = menuView.topView.frame;
        r.origin.x = self.view.bounds.size.width - 155;
        r.size.width = 140.0f;
        menuView.topView.frame = r;
        menuView.showHeight = 64;
        menuView.delegate = self;
        self.menu = menuView;
        self.shareButton.enabled = NO;
        [self.menu showComplete:^{
            self.shareButton.enabled = YES;
        }];
    } else {
        self.shareButton.enabled = NO;
        [self.menu hideComplete:^{
            self.shareButton.enabled = YES;
        }];
    }
}

- (void)HHMenuView:(HHMenuView *)view didTapIndex:(NSUInteger)index {
    [view hide];
    switch (index) {
        case 0:
            [self copyUrl];
            break;
        case 1:
            [self circleShare];
            break;
        case 2:
            [self wxShare];
            break;
        case 3:
            [self mailShare];
            break;
        case 4:
            [self smsShare];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIWebView *)linkWebView
{
    if (!_linkWebView) {
        _linkWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kFrame_Width, kFrame_Height)];
        _linkWebView.delegate = self;
    }
    return _linkWebView;
}

- (void)startRequest
{
    [self.linkWebView loadRequest:self.requset];
}

- (NSURLRequest *)requset
{
    if (!_requset) {
        NSString *stringCharacter = nil;
        NSString* url = [self.linkURL encodedString];
        NSRange range = [url rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            stringCharacter = @"&";
        }else{
            stringCharacter = @"?";
        }
        _requset = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@type=2",url,stringCharacter]]];
    }
    return _requset;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view showHudWithText:@"数据加载中" indicator:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.linkWebView.loading) {
        [self.view hideHud];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view showHudWithText:@"数据加载失败" indicator:NO];
    [self.view hideHudAfterDelay:0.8f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)_backTitle
{
    return @"返回";
}

- (void)copyUrl {
    [UIPasteboard generalPasteboard].string = self.linkURL;
    [self.view showHudWithText:@"复制成功" indicator:NO];
    [self.view hideHudAfterDelay:.8];
}

- (void)sinaShare {
    [HHSMShareModel share].title = [self getWebTitle];
    [HHSMShareModel share].content = @"";
    [HHSMShareModel share].logo = [self getPictureUrl];
    [HHSMShareModel share].link = self.linkURL;
    [HHSMShareModel share].viewController = self;
    [[HHSMShareModel share] sinaShare];
}

- (void)wxShare {
    [HHSMShareModel share].title = [self getWebTitle];
    [HHSMShareModel share].content = @"";
    [HHSMShareModel share].logo = [self getPictureUrl];
    [HHSMShareModel share].link = self.linkURL;
    [HHSMShareModel share].viewController = self;
    [[HHSMShareModel share] wxShareSceneTimeline];
}

- (void)circleShare {
    CCPubLinkViewController* pubVC = [[UIStoryboard storyboardWithName:@"circle" bundle:nil] instantiateViewControllerWithIdentifier:@"sharelink"];
    pubVC.linkImage = [self getPictureUrl];
    pubVC.linkTitle = [self getWebTitle];
    pubVC.linkUrl = self.linkURL;
    pubVC.block = ^(CCFeedModel* model) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CCSendNewWaveNotification object:self userInfo:@{@"object":model}];
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:pubVC animated:YES];
}

- (void)mailShare {
    [HHSMShareModel share].title = [self getWebTitle];
    [HHSMShareModel share].content = @"";
    [HHSMShareModel share].logo = [self getPictureUrl];
    [HHSMShareModel share].link = self.linkURL;
    [HHSMShareModel share].viewController = self;
    [[HHSMShareModel share] showMail];
}

- (void)smsShare {
    [HHSMShareModel share].title = [self getWebTitle];
    [HHSMShareModel share].content = @"";
    [HHSMShareModel share].logo = [self getPictureUrl];
    [HHSMShareModel share].link = self.linkURL;
    [HHSMShareModel share].viewController = self;
    [[HHSMShareModel share] showSMS];
}

- (NSString*)getPictureUrl {
    return self.linkImage;
//    NSString* jsString = @"function a() {var arr= document.images;    for (var i=0;i<arr.length;i++){        var ic = arr[i].src;if (ic.indexOf(\"http\") >= 0 && GetExt(ic).toLowerCase() != \"gif\") {  return ic;  }  }  }  function GetExt(sUrl) {        var arrList = sUrl.split(\".\");        return arrList[arrList.length-1];} a();";
//    return [self.linkWebView stringByEvaluatingJavaScriptFromString:jsString];
}

- (NSString*)getWebTitle {
    return self.linkTitle;
//    return [self.linkWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
