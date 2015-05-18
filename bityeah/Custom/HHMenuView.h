//
//  HHMenuView.h
//  HChat
//
//  Created by Sasori on 14-3-13.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM (NSInteger, HHGroupType)
{
    HHMessageType = (1)
};

@class HHMenuView;
@protocol HHMenuViewDelegate <NSObject>
- (void)HHMenuView:(HHMenuView*)view didTapIndex:(NSUInteger)index;
@optional
- (void)HHMenuViewWillHide:(HHMenuView *)view;
- (void)HHMenuViewWillShow:(HHMenuView *)view;
@end

@interface HHMenuView : UIView <UITableViewDelegate, UITableViewDataSource>
- (void)showComplete:(void (^)())complete;
- (void)hideComplete:(void (^)())complete;
- (void)showHomeComplete:(void (^)())complete;
- (void)hideHomeComplete:(void (^)())complete;
- (void)hide;
- (void)homeHide;
- (CGFloat)_maxMenuHeight;
- (CGFloat)_menuCellHeight;
- (CGFloat)_menuContentHeight;
- (void)commonInit;
- (void)updateDataTitles:(NSArray *)titles withImages:(NSArray *)images;
- (instancetype)initWithTitles:(NSArray*)titles images:(NSArray*)images parentView:(UIView*)parentView menuType:(NSInteger)type;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)reloadData;
@property (nonatomic, weak) id<HHMenuViewDelegate> delegate;
@property (nonatomic, weak) UIView* parentView;
@property (nonatomic, strong) NSArray* titles;
@property (nonatomic, strong) NSArray* images;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) BOOL showSelectIndex;
@property (nonatomic, strong) UITableView* topView;
@property (assign, nonatomic) HHGroupType type;
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat showHeight;
@property (nonatomic, assign) BOOL isHidden;
- (UIColor*)_textColor;
@end
