//
//  HHLinkWaveTableViewController.m
//  HChat
//
//  Created by Wong on 15/4/1.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "HHLinkWaveTableViewController.h"
#import "UIView+MBProgressView.h"
#import "HHRegularExpression.h"
#import "CCWebParser.h"
#import "CCPubLinkViewController.h"

@interface HHLinkWaveTableViewController ()
//@property (weak, nonatomic) IBOutlet UITextField *titleTextfield;
@property (weak, nonatomic) IBOutlet UITextField *linkTextfield;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) NSString* linkTitle;
@property (nonatomic, strong) NSString* linkImage;
@property (nonatomic, strong) CCWebParser* webParser;
@end

@implementation HHLinkWaveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.submitButton.layer.masksToBounds = YES;
    self.submitButton.layer.cornerRadius = 4.0f;
    
    
    CGRect rect = self.linkTextfield.frame;
    rect.size.width = kFrame_Width - 20.0f;
    self.linkTextfield.frame = rect;
    
}
- (IBAction)submitAction:(id)sender
{
    [self.linkTextfield resignFirstResponder];
    if (![HHRegularExpression regularExpression:self.linkTextfield.text]) {
        [self.view showHudWithText:@"您输入的链接不合法" indicator:NO];
        [self.view hideHudAfterDelay:0.8f];
        return;
    }
    [self.view showHudWithText:@"正在处理" indicator:YES];
    CCWebParser* parser = [CCWebParser new];
    self.webParser = parser;
    NSString* url = self.linkTextfield.text;
    if (![url hasPrefix:@"http://"]) {
        url = [@"http://" stringByAppendingString:url];
    }
    [parser loadURL:url completion:^(NSString *title, NSString *imageSrc) {
        if (title || imageSrc) {
            self.linkTitle = title;
            self.linkImage = imageSrc;
            [self.view hideHud];
            [self performSegueWithIdentifier:@"NewLink2Pub" sender:self];
        } else {
            [self.view showHudWithText:@"无法处理链接，请检查链接是否合法" indicator:NO];
            [self.view hideHudAfterDelay:.8];
        }

    }];
}

- (void)submitSuccess
{

}


- (IBAction)dismissAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CCPubLinkViewController* pubVC = segue.destinationViewController;
    pubVC.linkImage = self.linkImage;
    pubVC.linkTitle = self.linkTitle;
    pubVC.linkUrl = self.linkTextfield.text;
    pubVC.block = ^(CCFeedModel* feedModel){
        self.block(feedModel);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
}

@end
