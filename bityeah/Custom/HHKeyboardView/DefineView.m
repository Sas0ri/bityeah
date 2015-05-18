//
//  DefineView.m
//  HChat
//
//  Created by Sasori on 13-10-11.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import "DefineView.h"

#define EmotionCount 15
#define RowCount 2
#define ColumnCount 4

@interface DefineView()
@property (nonatomic, strong) NSArray* faces;
@end

@implementation DefineView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
		NSMutableArray* arr = [NSMutableArray arrayWithCapacity:EmotionCount];
		for (int i = 0; i < EmotionCount; i++) {
			[arr addObject:[NSString stringWithFormat:@"bface%d",i]];
		}
		_faces = arr;
    }
    return self;
}

- (void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
	for (int i = 0; i < RowCount; i++) {
		//column numer
		for (int y = 0; y < ColumnCount; y++) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            CGFloat originY = i*size.height;
            if (i != 0) {
                originY += 6;
            }
            [button setFrame:CGRectMake(y*size.width, originY, size.width, size.height)];
//            if (i == RowCount - 1 && y == ColumnCount - 1) {
            
//            }else{
				NSInteger count = i*ColumnCount+y+page*(RowCount*ColumnCount);
				if (count < EmotionCount) {
					NSString* imgStr = [_faces objectAtIndex:count];
					[button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgStr]] forState:UIControlStateNormal];
					button.imageView.contentMode = UIViewContentModeScaleAspectFit;
					button.tag = count;
				} else {
					break;
				}
//            }
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
}

- (void)loadFacialView:(int)page size:(CGSize)size middleSpace:(CGFloat)space
{
    //row number
    for (int i = 0; i < RowCount; i++) {
        //column numer
        for (int y = 0; y < ColumnCount; y++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            CGFloat originY = i*size.height;
            if (i != 0) {
                originY += 6;
            }
            [button setFrame:CGRectMake(y*(size.width+space), originY, size.width, size.height)];

//            [button setFrame:CGRectMake(y*size.width, originY, size.width, size.height)];
            NSInteger count = i*ColumnCount+y+page*(RowCount*ColumnCount);
            if (count < EmotionCount) {
                NSString* imgStr = [_faces objectAtIndex:count];
                [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgStr]] forState:UIControlStateNormal];
                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                button.tag = count;
            } else {
                break;
            }
            //            }
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
}



- (void)selected:(UIButton*)bt
{
	NSString *str = [_faces objectAtIndex:bt.tag];
	[_delegate selectedFacialView:str];
}

@end
