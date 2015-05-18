//
//  HHMenuView.m
//  HChat
//
//  Created by Sasori on 14-3-13.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHMenuView.h"
#import "UIColor+FlatUI.h"

@interface HHMenuView() <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL isFromForm;
@property (assign, nonatomic) NSInteger menuType;
@property (nonatomic, strong) UIView* clipsView;
@end

@implementation HHMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFromForm = NO;
		_bgView = [[UIView alloc] initWithFrame:self.bounds];
		_bgView.backgroundColor = [UIColor blackColor];
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:_bgView];
		
		_topView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 100)];
		_topView.delegate = self;
		_topView.dataSource = self;
        _topView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _topView.backgroundColor = [UIColor colorFromHexCode:@"ececec"];
		
        _clipsView = [[UIView alloc] initWithFrame:self.bounds];
        _clipsView.backgroundColor = [UIColor clearColor];
        _clipsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _clipsView.clipsToBounds = YES;
        [self addSubview:_clipsView];
        [_clipsView addSubview:_topView];
        
		UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tg.delegate = self;
		[self addGestureRecognizer:tg];
    }
    return self;
}

- (void)formSubmitSuccess
{
    _isFromForm = YES;
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [self tableView:self.topView didSelectRowAtIndexPath:path];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGRect r = [self convertRect:self.topView.frame fromView:self.clipsView];
    CGPoint p = [touch locationInView:self];
    if (CGRectContainsPoint(r, p)) {
        return NO;
    }
    return YES;
}

- (void)reloadData
{
	[self.topView reloadData];
	[self commonInit];
}

- (instancetype)initWithTitles:(NSArray *)titles images:(NSArray *)images parentView:(UIView *)parentView menuType:(NSInteger)type
{
	if (self = [self initWithFrame:parentView.bounds]) {
		_parentView = parentView;
		_titles = titles;
		_images = images;
        _showSelectIndex = YES;
        _menuType =  type;
		[self reloadData];
	}
	return self;
}

- (void)updateDataTitles:(NSArray *)titles withImages:(NSArray *)images
{
    _titles = titles;
    _images = images;
    [self commonInit];
    [_topView reloadData];
}

- (void)commonInit
{
	if ([self _menuContentHeight] > [self _maxMenuHeight]) {
		CGRect r = _topView.frame;
		r.size.height = [self _maxMenuHeight];
		_topView.frame = r;
		_topView.scrollEnabled = YES;
	} else {
		CGRect r = _topView.frame;
		r.size.height = [self _menuContentHeight];
		_topView.frame = r;
		_topView.scrollEnabled = NO;
	}
    [self updateClipsView];
}

- (void)setShowHeight:(CGFloat)showHeight {
    _showHeight = showHeight;
    [self updateClipsView];
}

- (void)updateClipsView {
    CGRect r = self.clipsView.frame;
    r.origin.y = self.showHeight;
    r.size.height = self.topView.frame.size.height;
    self.clipsView.frame = r;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self commonInit];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

#define kImageViewTag		235412
#define kTitleLabelTag		235413
#define kSelectedViewTag	235414

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        CGFloat topMargin = ([self _menuCellHeight] - 28)/2;
        if (topMargin < 0) {
            topMargin = 0;
        }
        NSString *imagestring = self.images.count > 0 ? [NSString stringWithFormat:@"%@",self.images[indexPath.row]] : @"";
        UIImage *headImage = [UIImage imageNamed:imagestring];
		UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(20, topMargin+5, headImage.size.width,headImage.size.height)];
		image.tag = kImageViewTag;
		image.image = headImage;
		[cell.contentView addSubview:image];
		
		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200,  [self _menuCellHeight])];
        if (_menuType == 1) {
            label.frame = CGRectMake(46, 0, 200, [self _menuCellHeight]);
        }
		label.font = [UIFont systemFontOfSize:15];
		label.textColor = [self _textColor];
		label.backgroundColor = [UIColor clearColor];
		label.tag = kTitleLabelTag;
		[cell.contentView addSubview:label];
		
		UIImageView* imageSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"task_navi_choose"]];
//        topMargin = ([self _menuCellHeight]-16)/2;
//        if (topMargin < 0) {
//            topMargin = 0;
//        }
		imageSelected.frame = CGRectMake(self.bounds.size.width - 40, 14, 16, 16);
		imageSelected.tag = kSelectedViewTag;
		[cell.contentView addSubview:imageSelected];
    }
	
	if (self.titles.count > indexPath.row) {
		UILabel* label = (UILabel*)[cell.contentView viewWithTag:kTitleLabelTag];
		label.text = self.titles[indexPath.row];
	}
    
    UIImageView* image = (UIImageView*)[cell.contentView viewWithTag:kSelectedViewTag];

	if (self.showSelectIndex) {
        image.hidden = indexPath.row != self.selectIndex;
    } else {
        image.hidden = YES;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self _menuCellHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor =[UIColor colorFromHexCode:@"dfdfdf"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.showSelectIndex) {
        self.selectIndex = indexPath.row;
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView* image = (UIImageView*)[cell.contentView viewWithTag:kSelectedViewTag];
        image.hidden = NO;
        for (UITableViewCell* c in tableView.visibleCells) {
            if (c != cell) {
                UIImageView* i = (UIImageView*)[c.contentView viewWithTag:kSelectedViewTag];
                i.hidden = YES;
            }
        }
    }
    if (_isFromForm == NO) {
        [self.delegate HHMenuView:self didTapIndex:indexPath.row];
    }else{
        _isFromForm = NO;
    }
}

- (UIColor *)_textColor {
    return [UIColor blackColor];
}

- (CGFloat)_menuCellHeight
{
	return 44;
}

- (CGFloat)_maxMenuHeight
{
    if (self.maxHeight > 0) {
        return self.maxHeight;
    }
	return 44*4;
}

- (CGFloat)_menuContentHeight
{
	return self.titles.count*[self _menuCellHeight];
}

- (void)showComplete:(void (^)())complete
{
    self.frame = self.parentView.bounds;
    [self commonInit];

	CGRect fromRect = self.topView.frame;
	CGRect targetRect = fromRect;
    targetRect.origin.y = 0;
    fromRect.origin.y = -fromRect.size.height;

	self.topView.frame = fromRect;
	self.bgView.alpha = 0.0f;
    if ([self.delegate respondsToSelector:@selector(HHMenuViewWillShow:)]) {
        [self.delegate HHMenuViewWillShow:self];
    }
    [self.parentView addSubview:self];

	[UIView animateWithDuration:0.3 animations:^{
		self.topView.frame = targetRect;
		self.bgView.alpha = 0.2f;
	} completion:^(BOOL finished) {
		if (complete) {
			complete();
		}
	}];
}

- (void)hideComplete:(void (^)())complete
{
	CGRect fromRect = self.topView.frame;
	CGRect targetRect = fromRect;
	targetRect.origin.y -= targetRect.size.height;
	self.bgView.alpha = 0.2f;
    if ([self.delegate respondsToSelector:@selector(HHMenuViewWillHide:)]) {
        [self.delegate HHMenuViewWillHide:self];
    }
	[UIView animateWithDuration:0.3 animations:^{
		self.topView.frame = targetRect;
		self.bgView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
		if (complete) {
			complete();
		}
	}];
}

- (void)showHomeComplete:(void (^)())complete
{
    self.frame = self.parentView.bounds;

    [self commonInit];
    
	CGRect fromRect = self.topView.frame;
    fromRect.origin.y = 0;
	CGRect targetRect = fromRect;
    fromRect.origin.y = - self.topView.frame.size.height;

	self.topView.frame = fromRect;
	self.bgView.alpha = 0.0f;
    
    if ([self.delegate respondsToSelector:@selector(HHMenuViewWillShow:)]) {
        [self.delegate HHMenuViewWillShow:self];
    }
    [self.parentView addSubview:self];

	[UIView animateWithDuration:0.3 animations:^{
		self.topView.frame = targetRect;
		self.bgView.alpha = 0.2f;
	} completion:^(BOOL finished) {
		if (complete) {
			complete();
		}
	}];

}
- (void)hideHomeComplete:(void (^)())complete
{
    self.topView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 100);
    CGRect fromRect = self.topView.frame;
	CGRect targetRect = fromRect;
	targetRect.origin.y -= targetRect.size.height;
	self.bgView.alpha = 0.2f;
    if ([self.delegate respondsToSelector:@selector(HHMenuViewWillHide:)]) {
        [self.delegate HHMenuViewWillHide:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
		self.topView.frame = targetRect;
		self.bgView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
		if (complete) {
			complete();
		}
	}];

}

- (void)homeHide
{
    [self hideHomeComplete:nil];
}

- (void)hide
{
	[self hideComplete:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
