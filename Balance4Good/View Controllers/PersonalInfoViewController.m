//
//  PersonalInfoViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "PersonalInfoViewController.h"

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
}

-(void)loadData
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    [tName setText:[data objectForKey:@"name"]];
    [tNumber setText:[data objectForKey:@"number"]];
    [tHeight setText:[data objectForKey:@"height"]];
    [tHipHeight setText:[data objectForKey:@"hipHeight"]];
    [tAge setText:[data objectForKey:@"age"]];
    [tWeight setText:[data objectForKey:@"weight"]];
    if([[data objectForKey:@"gender"] isEqualToString:@"Female"])
        [scGender setSelectedSegmentIndex:1];
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

- (IBAction)save:(UIButton *)sender
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[tName.text,tNumber.text,tHeight.text,tHipHeight.text,tAge.text, tWeight.text,[scGender titleForSegmentAtIndex:[scGender selectedSegmentIndex]]] forKeys:@[@"name",@"number",@"height",@"hipHeight",@"age",@"weight",@"gender"]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"personalInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)keyboardDidAppear
{
    if(self.view.frame.origin.y == 0)
    {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, -150)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
}

-(IBAction)keyboardDidDisappear
{
    if(self.view.frame.origin.y < 0)
    {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, +150)];
    }
}

-(void)done
{
    [self.view endEditing:YES];
    [self keyboardDidDisappear];
}

@end
