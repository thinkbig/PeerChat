//
//  MPTChatDataSource.h
//  MultiPeerTest
//
//  Created by Wayne on 10/29/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^AttachmentPreviewHandler)(NSString *filePath);

@interface MPTChatDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) AttachmentPreviewHandler attachmentPreviewHandler;

@end
