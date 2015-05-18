//
//  CCEncodeUtils.h
//  testCircle
//
//  Created by Sasori on 14/12/5.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEncodeUtils : NSObject
+ (NSString*)getSignature:(NSMutableDictionary*)params;
+ (NSString *)hexStringFromData:(NSData *)data;
@end
