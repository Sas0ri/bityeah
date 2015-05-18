//
//  HHSMShareModel.m
//  HChat
//
//  Created by Wong on 14/12/17.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHSMShareModel.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UIView+MBProgressView.h"

@interface HHSMShareModel ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,WXApiDelegate>


@end

@implementation HHSMShareModel

+ (HHSMShareModel *)share
{
    static HHSMShareModel *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[HHSMShareModel alloc]init];
    });
    return share;
}

#pragma mark - 新浪分享
- (void)sinaShare
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.link;
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@ %@",self.title,self.link];
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = self.logoImage ? UIImagePNGRepresentation(self.logoImage) : [NSData dataWithContentsOfURL:[NSURL URLWithString:self.logo]];
    message.imageObject = imageObject;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    if ([WeiboSDK sendRequest:request]) {
        NSLog(@"分享成功");
    }
}


#pragma mark - 微信分享

- (void)wxShareSceneSession
{
    NSString *appUrl = self.link;
    WXMediaMessage *message = [WXMediaMessage message];
    if (self.logoImage) {
        [message setThumbImage:self.logoImage];
    } else {
        self.logo = [NSString stringWithFormat:@"%@?w=200&h=200",self.logo];
        [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.logo]]]];
    }
    message.title = self.title;
    message.description = self.content;
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = appUrl;
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信");
        [self.viewController.view showHudWithText:@"您设备未安装微信" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }
    if([WXApi sendReq:req]){
        NSLog(@"分享成功");
    }
}

#pragma mark - 朋友圈分享

- (void)wxShareSceneTimeline
{
    NSString *appUrl = self.link;
    WXMediaMessage *message = [WXMediaMessage message];
    if (self.logoImage) {
        [message setThumbImage:self.logoImage];
    } else {
        self.logo = [NSString stringWithFormat:@"%@?w=200&h=200",self.logo];
        [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.logo]]]];
    }
    message.title = self.title;
    message.description = self.content;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = appUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;  //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if ([WXApi sendReq:req]) {
        NSLog(@"分享成功");
    }
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信");
        [self.viewController.view showHudWithText:@"您设备未安装微信" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }

    
//    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = @"一无所有";
//    message.description = @"崔健";
//    [message setThumbImage:[UIImage imageNamed:@"home_service_toTop"]];
//    WXMusicObject *ext = [WXMusicObject object];
//    ext.musicUrl = @"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4B880E697A0E68980E69C89222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696334382E74632E71712E636F6D2F586B30305156342F4141414130414141414E5430577532394D7A59344D7A63774D4C6735586A4C517747335A50676F47443864704151526643473444442F4E653765776B617A733D2F31303130333334372E6D34613F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D30222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31342E71716D757369632E71712E636F6D2F33303130333334372E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E4B880E697A0E68980E69C89222C22736F6E675F4944223A3130333334372C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E5B494E581A5222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D313574414141416A41414141477A4C36445039536A457A525467304E7A38774E446E752B6473483833344843756B5041576B6D48316C4A434E626F4D34394E4E7A754450444A647A7A45304F513D3D2F33303130333334372E6D70333F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D3026616D703B73747265616D5F706F733D35227D";
//    ext.musicDataUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";
//    message.mediaObject = ext;
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneTimeline;
//    [WXApi sendReq:req];
}



#pragma mark - 短信分享

- (void)showSMS
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet:self.viewController];
        }else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"您的设备不支持短信功能" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
            [alert show];
        }
    }else {
    }
}

-(void)displaySMSComposerSheet:(UIViewController *)viewCtrl
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    NSString *smsBody =[NSString stringWithFormat:@"%@\n%@！%@",self.title,self.content,self.link];
    picker.body = smsBody;
    [viewCtrl presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [self.viewController.view showHudWithText:@"分享成功" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }else if (result == MessageComposeResultFailed){
        [self.viewController.view showHudWithText:@"分享失败" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 邮件分享
- (void)showMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass !=nil) {
        if ([mailClass canSendMail]) {
            [self displayMailComposerSheet:self.viewController];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"您没有设置邮箱，请在设置中添加您的有效邮箱" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)displayMailComposerSheet:(UIViewController *)viewCtrl{
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate  = self;
    [picker setSubject:self.content];
    NSString *emailBody =[NSString stringWithFormat:@"%@\n%@",self.title,self.link];
    [picker setMessageBody:emailBody isHTML:NO];
    [viewCtrl presentViewController:picker animated:YES completion:nil];
}
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [self.viewController.view showHudWithText:@"分享成功" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }else if (result == MFMailComposeResultFailed){
        [self.viewController.view showHudWithText:@"分享失败" indicator:NO];
        [self.viewController.view hideHudAfterDelay:1.0f];
    }
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
