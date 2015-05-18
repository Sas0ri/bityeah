//
//  CCWebParser.m
//  HChat
//
//  Created by Sasori on 15/4/8.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "CCWebParser.h"
#import "AFHTTPClient.h"


@interface CCWebParser() 
@property (nonatomic, copy) LoadTitleImageBlock completionBlock;
@property (nonatomic, strong) AFHTTPClient* client;
@end

@implementation CCWebParser

- (AFHTTPClient *)client {
    if (_client == nil) {
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://utils.wx.huhoo.com"]];
    }
    return _client;
}

- (void)loadURL:(NSString *)url completion:(LoadTitleImageBlock)block {
    [self.client getPath:@"parselink" parameters:@{@"link":url} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        block(dic[@"title"], dic[@"img_url"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,nil);
    }];
}

@end
