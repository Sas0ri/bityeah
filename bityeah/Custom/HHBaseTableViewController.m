//
//  HHBaseTableViewController.m
//  Huhoo
//
//  Created by Sasori on 13-6-13.
//  Copyright (c) 2013年 Huhoo. All rights reserved.
//

#import "HHBaseTableViewController.h"

@interface HHBaseTableViewController ()
@property (nonatomic, strong) NSString* backTitle;
- (void)backAction:(id)sender;
@end

@implementation HHBaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
		else if([presentedViewController isKindOfClass:[UITabBarController class]])
		{
			if ([presentedViewController valueForKey:@"navTitleView"] && [[presentedViewController valueForKey:@"navTitleView"] isKindOfClass:[UILabel class]]) {
				UILabel * titleLabel = [presentedViewController valueForKey:@"navTitleView"];
				return titleLabel.text;
			}
		} else {
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



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
@end
