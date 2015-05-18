//
//  HHSMShareModel.h
//  HChat
//
//  Created by Wong on 14/12/17.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HHSMShareModel : NSObject

+ (HHSMShareModel *)share;

@property (retain, nonatomic) UIViewController *viewController;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *link;
@property (retain, nonatomic) NSString *logo;
@property (nonatomic, strong) UIImage* logoImage;
@property (retain, nonatomic) NSString *content;

//微信分享
- (void)wxShareSceneSession;
//朋友圈分享
- (void)wxShareSceneTimeline;
//新浪分享
- (void)sinaShare;

//邮箱
- (void)showMail;
//短息
- (void)showSMS;

@end
