//
//  BYMainViewController.m
//  bityeah
//
//  Created by Sasori on 15/5/18.
//  Copyright (c) 2015年 bityeah. All rights reserved.
//

#import "BYMainViewController.h"
#import "CCMainViewController.h"

@interface BYMainViewController ()
@property (nonatomic, strong) CCMainViewController* aa;
@end

@implementation BYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"circle" bundle:nil];
    CCMainViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CircleMain"];
    vc.navigationController = self.navigationController;
    self.aa = vc;
    self.viewControllers = @[vc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
