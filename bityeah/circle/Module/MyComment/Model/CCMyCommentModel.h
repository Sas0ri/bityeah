//
//  CCMyCommentModel.h
//  testCircle
//
//  Created by Sasori on 14/12/12.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFeedComment.h"

@interface CCMyCommentModel : NSObject
@property (nonatomic, strong) CCFeedComment* comment;
@property (nonatomic, strong) NSString* feedContent;
@property (nonatomic, strong) NSString* feedPicutre;
@property (nonatomic, strong) NSString* linkPicture;
@end
