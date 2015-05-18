//
//  HHUtilityKeyboardView.m
//  HChat
//
//  Created by Sasori on 14/10/24.
//  Copyright (c) 2014年 Huhoo. All rights reserved.
//

#import "HHUtilityKeyboardView.h"
#import "HHKeyboardLayout.h"
#import "UIColor+FlatUI.h"

#define kUtilityCount 3

@interface HHUtilityKeyboardView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* dataSouce;
@end

@implementation HHUtilityKeyboardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    HHKeyboardLayout* layout = [HHKeyboardLayout new];
    layout.itemSize = CGSizeMake(62, 85);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.contentInset = UIEdgeInsetsMake(20, 29, 0, 0);
    [_collectionView registerClass:[HHUtilityKeyboardCell class] forCellWithReuseIdentifier:@"Cell"];
    [self addSubview:_collectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSouce.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HHUtilityKeyboardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    HHUtilityKeyboardItem* item = self.dataSouce[indexPath.row];
    cell.imageView.image = item.image;
    cell.label.text = item.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self.delegate utilityViewPickImageFromLibrary:self];
            break;
        case 1:
            [self.delegate utilityViewPickImageFromCamara:self];
            break;
        default:
            break;
    }
}

- (NSArray *)dataSouce {
    if (_dataSouce == nil) {
        NSMutableArray* dataSouce = [NSMutableArray array];
        for (int i = 0; i < kUtilityCount; i++) {
            HHUtilityKeyboardItem* item = [HHUtilityKeyboardItem new];
            switch (i) {
                case 0:
                    item.title = @"照片";
                    item.image = [UIImage imageNamed:@"pickimage_library"];
                    break;
                case 1:
                    item.title = @"拍摄";
                    item.image = [UIImage imageNamed:@"pickimage_camera"];
                    break;
                case 2:
                    item.title = @"";
                    item.image = nil;
                default:
                    break;
            }
            [dataSouce addObject:item];
        }
        _dataSouce = [dataSouce copy];
    }
    return _dataSouce;
}

@end


@implementation HHUtilityKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2 - 31, 0, 62, 62)];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2 - 31, 62, 62, 21)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorFromHexCode:@"666666"];
        _label.font = [UIFont systemFontOfSize:12];
        [self addSubview:_label];
    }
    return self;
}

@end

@implementation HHUtilityKeyboardItem


@end