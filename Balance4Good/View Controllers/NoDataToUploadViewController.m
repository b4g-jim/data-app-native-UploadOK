//
//  NoDataToUploadViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "NoDataToUploadViewController.h"

@interface NoDataToUploadViewController ()

@end

@implementation NoDataToUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES animated:NO];

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

- (IBAction)gotoHomeScreen:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
