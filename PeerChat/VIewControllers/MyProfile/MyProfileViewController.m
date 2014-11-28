//
//  MyProfileViewController.m
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import "MyProfileViewController.h"
#import "UserWrapper.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userName.text = [[UserWrapper sharedInst] nameOfMine];
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

- (IBAction)saveUserInfo:(id)sender {
    [[UserWrapper sharedInst] setUserName:self.userName.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
