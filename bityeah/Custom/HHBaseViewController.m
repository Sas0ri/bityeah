//
//  HHBaseViewController.m
//  Huhoo
//
//  Created by Sasori on 13-6-13.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import "HHBaseViewController.h"

@interface HHBaseViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSString* backTitle;
@end

@implementation HHBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.backButton = [UIHelper navLeftButtonWithTitle:self.backTitle];
	[self.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (BaseIOS7) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        self.navigationController.interactivePopGestureRecognizer.enabled = [self shouldInteractivePop];
    }
}

- (BOOL)shouldInteractivePop {
    return YES;
}

- (NSString *)backTitle
{
	if ([self _backTitle]) {
		return [self _backTitle];
	} else {
		UIViewController* presentedViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
		if (presentedViewController.navigationItem.title.length > 0) {
			return presentedViewController.navigationItem.title;
		}
		else {
			return @"返回";
		}
	}
	return nil;
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
