//
//  MPTChatViewController.h
//  MultiPeerTest
//
//  Created by Wayne on 10/29/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CamerHandler)(void);

@interface MPTChatViewController : UITableViewController

@property (nonatomic, strong) NSString *        roomName;

@end
