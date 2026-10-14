//
//  PrimaveViewController.m
//  WZLBadgeDemo
//
//  Created by jian jian on 2026/10/14.
//  Copyright © 2026 Weng-Zilin. All rights reserved.
//

#import "PrimaveViewController.h"

@interface PrimaveViewController ()

@end

@implementation PrimaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Notify" style:UIBarButtonItemStylePlain target:self action:@selector(notifyAction)];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"Me" image:UIImage.new tag:100];
    // Do any additional setup after loading the view.
}

- (void)notifyAction {
    
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
