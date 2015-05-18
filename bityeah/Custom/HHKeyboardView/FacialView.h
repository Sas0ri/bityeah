//
//  FacialView.h
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDeleteKey @"__delete__"

@protocol FacialViewDelegate
-(void)selectedFacialView:(NSString*)str;
@optional
- (void)sendAction:(id)sender;
@end

@interface FacialView : UIView

@property(nonatomic,weak) id<FacialViewDelegate>delegate;

- (void)loadFacialView:(int)page size:(CGSize)size;

- (void)loadFacialView:(int)page size:(CGSize)size middleSpace:(CGFloat)space;


@end
