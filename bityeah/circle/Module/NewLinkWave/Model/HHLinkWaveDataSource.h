//
//  HHLinkWaveDataSource.h
//  HChat
//
//  Created by Wong on 15/4/1.
//  Copyright (c) 2015年 Huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBaseDataSource.h"

@interface HHLinkWaveDataSource : CCBaseDataSource

- (void)sendWaveWithTitle:(NSString*)title link:(NSString *)link success:(void (^)(CCFeedModel* model))success failure:(void (^)())failure;
- (void)sendWaveWithTitle:(NSString*)title link:(NSString *)link content:(NSString*)content imageSrc:(NSString*)imageSrc success:(void (^)(CCFeedModel* model))success failure:(void (^)())failure;

@end
