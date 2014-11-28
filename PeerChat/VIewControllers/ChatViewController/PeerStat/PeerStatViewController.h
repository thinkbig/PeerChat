//
//  PeerStatViewController.h
//  PeerChat
//
//  Created by paul on 14-11-28.
//  Copyright (c) 2014年 Tradeshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerStatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *inPeersLabel;

@property (nonatomic, strong) NSArray *     inPeers;

@end
