//
//  PeerStatViewController.m
//  PeerChat
//
//  Created by paul on 14-11-28.
//  Copyright (c) 2014年 Tradeshift. All rights reserved.
//

#import "PeerStatViewController.h"

@interface PeerStatViewController ()

@end

@implementation PeerStatViewController

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
    // Do any additional setup after loading the view.
    //when load the view controller,we shoule be can do it right now

//    if(self.selfNameArray){
        self.selfPeerName.text = [self.selfNameArray objectAtIndex:0];
//    }
    NSMutableString *array1 = [NSMutableString string];
    
    if(self.inPeersArray){
        for (NSString *peerName in _inPeersArray) {
            [array1 appendString:peerName];
        }
        self.inPeerNames.text = array1;
    }
    array1 = [NSMutableString string];
    
    if(self.outPeersArray){
        for (NSString *peerName in _inPeersArray) {
            [array1 appendString:peerName];
        }
        self.outPeerNames.text = array1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
