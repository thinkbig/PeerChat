//
//  MyProfileViewController.h
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userName;

- (IBAction)saveUserInfo:(id)sender;

@end
