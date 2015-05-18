//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"
#import "MsgDefine.h"

#define RowCount 3
#define ColumnCount 7

@interface FacialView()
@property (nonatomic, strong) NSArray *faces;
@end

@implementation FacialView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
		NSMutableArray* arr = [NSMutableArray arrayWithCapacity:EmotionCount];
		for (int i = 0; i < EmotionCount; i++) {
			[arr addObject:[NSString stringWithFormat:@"face%d",i]];
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
            [button setFrame:CGRectMake(y*size.width, i*size.height, size.width, size.height)];
            if (i == RowCount - 1 && y == ColumnCount - 1) {
                
            }else{
				NSInteger count = i*ColumnCount+y+page*(RowCount*ColumnCount - 1);
				if (count < EmotionCount) {
					NSString* imgStr = [_faces objectAtIndex:count];
					[button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgStr]] forState:UIControlStateNormal];
					button.imageView.contentMode = UIViewContentModeScaleAspectFit;
					button.tag = count;
				} else {
					break;
				}
            }
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundColor:[UIColor clearColor]];
	[button setFrame:CGRectMake((ColumnCount - 1)*size.width, (RowCount - 1)*size.height, size.width, size.height)];
	[button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
	button.tag = 10000;
	[self addSubview:button];
}

- (void)loadFacialView:(int)page size:(CGSize)size middleSpace:(CGFloat)space
{
    for (int i = 0; i < RowCount; i++) {
        //column numer
        for (int y = 0; y < ColumnCount; y++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y*(size.width+space), i*size.height, size.width, size.height)];
            if (i == RowCount - 1 && y == ColumnCount - 1) {
                
            }else{
                NSInteger count = i*ColumnCount+y+page*(RowCount*ColumnCount - 1);
                if (count < EmotionCount) {
                    NSString* imgStr = [_faces objectAtIndex:count];
                    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgStr]] forState:UIControlStateNormal];
                    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    button.tag = count;
                } else {
                    break;
                }
            }
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:CGRectMake((ColumnCount - 1)*(size.width+space), (RowCount - 1)*size.height, size.width, size.height)];
    [button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.tag = 10000;
    [self addSubview:button];

}


- (void)selected:(UIButton*)bt
{
    if (bt.tag == 10000) {
        [_delegate selectedFacialView:kDeleteKey];
    }else{
        NSString *str = [_faces objectAtIndex:bt.tag];
        [_delegate selectedFacialView:str];
    }	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (void)dealloc
{
	
}
@end
