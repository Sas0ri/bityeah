//
//  CCPubLinkViewController.h
//  HChat
//
//  Created by Sasori on 15/4/8.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "HHBaseViewController.h"
#import "LinkWaveSuccessBlock.h"

@interface CCPubLinkViewController : HHBaseViewController
@property (nonatomic, strong) NSString* linkImage;
@property (nonatomic, strong) NSString* linkTitle;
@property (nonatomic, strong) NSString* linkUrl;
@property (copy, nonatomic) HHLinkWaveSuccessBlock block;

@end
