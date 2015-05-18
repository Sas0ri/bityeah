//
//  Context.h
//  bityeah
//
//  Created by Sasori on 15/5/18.
//  Copyright (c) 2015年 bityeah. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HHUserInfoUpdatedNotification @"HHUserInfoUpdatedNotification"

@interface Context : NSObject
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, assign) int64_t parkId;
@property (nonatomic, assign) int64_t uid;
- (BOOL)signedIn;
+ (Context*)sharedContext;
@end
