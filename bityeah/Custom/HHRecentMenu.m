//
//  HHRecentMenu.m
//  HChat
//
//  Created by Sasori on 14-8-13.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHRecentMenu.h"
#import "UIColor+FlatUI.h"

@interface HHRecentMenu()
@end

@implementation HHRecentMenu

- (CGFloat)_menuCellHeight {
    return 44;
}

- (CGFloat)_menuContentHeight {
    return 44*5+5;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGRect r = self.topView.frame;
        self.topView.backgroundColor = [UIColor clearColor];
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.topView.bounds.size.width, 5)];
        view.backgroundColor = [UIColor clearColor];
        self.topView.tableHeaderView = view;
        self.topView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.topView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"msg_menu_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 60,40)]];
        r.origin.x = CGRectGetWidth(view.frame) - 15 - 140;
        r.size.width = 140.0f;
        self.topView.frame = r;
    }
    return self;
}

#define kSepLineTag 1412412412

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UIView* sepLine = [cell.contentView viewWithTag:kSepLineTag];
    if (sepLine == nil) {
        sepLine = [[UIView alloc] initWithFrame:CGRectMake(15, cell.contentView.bounds.size.height - 0.5, cell.contentView.bounds.size.width-30, 0.5)];
        sepLine.backgroundColor = [UIColor colorFromHexCode:@"4f575d"];
        sepLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        sepLine.tag = kSepLineTag;
        [cell.contentView addSubview:sepLine];
    }
    sepLine.hidden = indexPath.row == self.titles.count - 1;
    UIView* selectedBg = [UIView new];
    selectedBg.backgroundColor = [UIColor colorFromHexCode:@"1d2023"];
    cell.selectedBackgroundView = selectedBg;
    return cell;
}

- (UIColor *)_textColor {
    return [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor clearColor];
}

@end
