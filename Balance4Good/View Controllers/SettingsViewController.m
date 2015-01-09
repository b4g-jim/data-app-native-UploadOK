//
//  SettingsViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
    [logInterval setText:[NSString stringWithFormat:@"%d",[[NSUserDefaults standardUserDefaults] integerForKey:@"updateRate"]]];
    
}

-(void)save
{
    if([[[logInterval text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter the Update Rate."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[logInterval text] intValue]<30)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Update Rate cannot be less than 30ms."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[logInterval text] intValue] forKey:@"updateRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
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
