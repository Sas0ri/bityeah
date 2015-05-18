//
//  SINavigationMenuView.h
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIMenuButton.h"

@protocol SIONavigationMenuDelegate <NSObject>

- (void)didTapedOnMen;

@end

@interface SIONavigationMenuView : UIView

@property (nonatomic, weak) id <SIONavigationMenuDelegate> delegate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) SIMenuButton *menuButton;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)setMenuButtonActive:(BOOL)active;

@end
