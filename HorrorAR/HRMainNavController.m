//
//  HRMainNavController.m
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/12/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import "HRMainNavController.h"
#import "HRCamViewController.h"

@interface HRMainNavController ()

@end

@implementation HRMainNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationBarHidden = YES;
    
//    HRCamViewController *cam = [[HRCamViewController alloc] init];
//    [self pushViewController:cam animated:NO];
    
    HRIntroViewController *intro = [[HRIntroViewController alloc] init];
    [self pushViewController:intro animated:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
