//
//  HHLinkWaveDataSource.m
//  HChat
//
//  Created by Wong on 15/4/1.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import "HHLinkWaveDataSource.h"
#import "PBWaveBody+Transform.h"
#import "CCUserInfoProvider.h"
#import "AFHTTPRequestOperation.h"
#import "Context.h"

@implementation HHLinkWaveDataSource

- (void)sendWaveWithTitle:(NSString *)title link:(NSString *)link success:(void (^)(CCFeedModel *))success failure:(void (^)())failure
{
    PBWaveBuilder* wb = [[PBWave builder] setType:PBWaveTypeTypeLink];
    [wb setSenderPassportId:[[CCUserInfoProvider sharedProvider] uid]];
    PBWaveBodyBuilder* bb = [PBWaveBody builder];
    NSMutableArray* items = [[NSMutableArray alloc]init];
    PBWaveBodyItemLink* linkItem = [[[[PBWaveBodyItemLink builder] setTitle:title] setUrl:link]build];
    PBWaveBodyItem* item = [[[[PBWaveBodyItem builder] setLink:linkItem] setType:PBWaveBodyItemTypeTypeLink]build];
    [items addObject:item];
    [bb setItemsArray:items];
    [wb setBody:[bb build]];
    
    PBSendWaveReq* req = [[[[PBSendWaveReq builder] setWave:[wb build]] setParkId:[Context sharedContext].parkId] build];
    
    PBFrame* frame = [[[[PBFrame builder] setCmd:PBFrameCmdCmdSendWave] setExtension:[CircleRoot sendWaveReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBSendWaveResp* respWave = [respFrame getExtension:[CircleRoot sendWaveResp]];
        if ([respWave hasWave]) {
            CCFeedModel *model = [self parseWave:respWave.wave];
            success(model);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}

- (void)sendWaveWithTitle:(NSString*)title link:(NSString *)link content:(NSString*)content imageSrc:(NSString*)imageSrc success:(void (^)(CCFeedModel* model))success failure:(void (^)())failure {
    PBWaveBuilder* wb = [[PBWave builder] setType:PBWaveTypeTypeLink];
    [wb setSenderPassportId:[[CCUserInfoProvider sharedProvider] uid]];
    PBWaveBodyBuilder* bb = [PBWaveBody builder];
    NSMutableArray* items = [[NSMutableArray alloc]init];
    PBWaveBodyItemLink* linkItem = [[[[[PBWaveBodyItemLink builder] setTitle:title] setUrl:link] setPictureUrl:imageSrc] build];
    PBWaveBodyItem* item = [[[[[PBWaveBodyItem builder] setLink:linkItem] setType:PBWaveBodyItemTypeTypeLink] setText:content] build];
    [items addObject:item];
    
    [bb setItemsArray:items];
    [wb setBody:[bb build]];
    
    PBSendWaveReq* req = [[[[PBSendWaveReq builder] setWave:[wb build]] setParkId:[Context sharedContext].parkId] build];
    
    PBFrame* frame = [[[[PBFrame builder] setCmd:PBFrameCmdCmdSendWave] setExtension:[CircleRoot sendWaveReq] value:req] build];
    
    NSMutableURLRequest* request = [self.client requestWithMethod:@"POST" path:nil parameters:nil];
    [request setHTTPBody:[frame data]];
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PBFrame* respFrame = [PBFrame parseFromData:responseObject extensionRegistry:[CircleRoot extensionRegistry]];
        PBSendWaveResp* respWave = [respFrame getExtension:[CircleRoot sendWaveResp]];
        if ([respWave hasWave]) {
            CCFeedModel *model = [self parseWave:respWave.wave];
            success(model);
        } else {
            failure();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
    [self.client enqueueHTTPRequestOperation:op];
}


@end
