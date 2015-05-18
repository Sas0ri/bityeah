//
//  HHViewController.m
//  CheckInApp
//
//  Created by Albert on 14-6-17.
//  Copyright (c) 2014年 wong. All rights reserved.
//

#import "HHViewController.h"


@interface HHViewController ()
- (void)backAction:(id)sender;
@property (nonatomic, retain) NSString* backTitle;

@end

@implementation HHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationBar];
    [self setLeftBarButton];
}

- (void)setNavigationBar
{
    CGRect rect = CGRectZero ;
    int statusHeight = 0;
    int navBarHeight = 44.0f;
    if (BaseIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        [self setNavigationBarWithColor:[UIColor whiteColor]];

//        [self.navigationController.navigationBar setTranslucent:NO];
//        [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
        statusHeight = 20;
    }else{
//        [[UINavigationBar appearance] setTintColor:[UIColor colorFromHexCode:@"f8f8f8"]];
    }
    rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navBarHeight -statusHeight);
    self.view.frame = rect;
}

-(void)setNavigationBarWithColor:(UIColor *)color
{
    UIImage *image = [self imageWithColor:color];
    
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setLeftBarButton
{
    self.backButton = [UIHelper navLeftButtonWithTitle:[self _backTitle]];
	[self.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)setNavBarTitleColor
{
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"ArialMT" size:16.0], NSFontAttributeName,
//                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,nil]];
}

- (NSString *)_backTitle
{
	return nil;
}

- (void)backAction:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
