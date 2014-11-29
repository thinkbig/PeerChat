//
//  PeerStatViewController.h
//  PeerChat
//
//  Created by paul on 14-11-28.
//  Copyright (c) 2014年 Tradeshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerStatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *selfPeerName;
@property (weak, nonatomic) IBOutlet UILabel *inPeerNames;
@property (weak, nonatomic) IBOutlet UILabel *outPeerNames;

@property (nonatomic, strong) NSArray * inPeersArray;
@property (strong,nonatomic) NSArray * outPeersArray;
@property (strong,nonatomic) NSArray * selfNameArray;
@end
